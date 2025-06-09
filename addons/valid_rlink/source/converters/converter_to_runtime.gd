@tool
extends "./converter_base.gd"

#const RLinkUndoRedo = preload("./rlink_undo_redo.gd")
#
#var __undo_redo: RLinkUndoRedo

var _register_tool_instances := false


func _init(context: Context) -> void:
    super (context)
    #__undo_redo = context.undo_redo
    
    
func convert_value(data: RLinkData, tool_value: Variant, depth: int = 0, register_tool_instances := true) -> Variant:
    data.converter_converted_object = false
    data.script_error = false
    if depth == -1: depth = data.max_depth - 1
    _register_tool_instances = register_tool_instances
    var runtime: Variant = _get_runtime_value(data, tool_value, depth)
    _register_tool_instances = false
    if data.script_error:
        push_warning("ValidRLink: Detected error in script [converter_to_runtime.convert_value]")
    data.visit.clear()
    return runtime
    
    
func _get_runtime_value(data: RLinkData, tool_value: Variant, depth: int) -> Variant:
    if data.script_error: return null
    if tool_value == null: return tool_value
    
    var runtime_value: Variant
    var type := typeof(tool_value)
    if type == TYPE_OBJECT:
        var new_runtime := _get_runtime_object(data, tool_value)
        if new_runtime == null:
            data.script_error = true
            return null
        if not is_same(tool_value, new_runtime):
            _set_runtime_object(data, new_runtime, tool_value, depth)
        runtime_value = new_runtime
    elif type == TYPE_DICTIONARY:
        runtime_value = _get_runtime_dictionary(data, tool_value, depth)
    elif type == TYPE_ARRAY:
        runtime_value = _get_runtime_array(data, tool_value, depth)
    else:
        runtime_value = tool_value

    return runtime_value
    
    
func _get_runtime_object(data: RLinkData, tool_obj: Object) -> Object:
    data.converter_converted_object = true
    var runtime: Object = __map.runtime_from_obj(tool_obj)
    if runtime != null:
         return runtime
    
    if _pass_directly(tool_obj):
        return tool_obj
    
    var script: Script = tool_obj.get_script()
    runtime = ClassDB.instantiate(tool_obj.get_class())
    if script != null: runtime.set_script(script)
    if script != null and runtime == null:
        data.script_error = true
        return null
    
    if _register_tool_instances:
        __map.add_pair(runtime, tool_obj)
    else:
        __map.add_pair_no_tracking(runtime, tool_obj)
    __scan_cache.add_pair(runtime, tool_obj)
    return runtime
    
    
func _set_runtime_object(data: RLinkData, runtime: Object, tool_obj: Object, depth: int) -> void:
    if data.script_error: return
    var from_id := tool_obj.get_instance_id()
    if data.visit.has(from_id): return
    data.visit[from_id] = true
    
    var res := __scan_cache.get_search(runtime)
    if tool_obj is Node:
        if tool_obj.name: runtime.name = tool_obj.name
        _copy_groups(data, runtime, tool_obj)
    
    for prop in tool_obj.get_property_list():
        if (_skip_property(res.skip_properties, res.allowed_properties, prop)):
            continue
            
        var prop_name: StringName = prop["name"]
        var tool_value: Variant = tool_obj.get(prop_name)
        
        if _skip_value(data, prop, tool_value, depth):
            continue
        var original_value: Variant = runtime.get(prop_name)
        if original_value is Object and original_value.get_meta(&"rlink_skip", false):
            continue
            
        var new_runtime_value: Variant = _get_runtime_value(data, tool_value, depth + 1)
        if data.script_error: return
        
        if original_value != new_runtime_value:
            if !__settings.apply_changes_to_external_user_resources and _is_external_resource(runtime):
                push_warning(
                    ("ValidRLink: Trying to apply changes to external resource in %s, if this "
                    +"is intended set `apply_changes_to_external_user_resources` to true "
                    +"in project settings [converter_to_runtime._set_runtime_object]")
                    % data.runtime
                )
                return
            data.object_add_changes(runtime, prop_name, original_value, new_runtime_value)
    
    var to_remove := runtime.get_meta_list()
    for meta in tool_obj.get_meta_list():
        var idx := to_remove.find(meta)
        if idx != -1: to_remove.remove_at(idx)
    
    for meta in to_remove:
        data.object_remove_meta(runtime, meta)


func _copy_groups(data: RLinkData, runtime: Node, tool_obj: Node) -> void:
    var to_erase: Array[StringName]
    for group in runtime.get_groups():
        if "_root_canvas" in group: continue
        to_erase.push_back(group)
        
    var to_add: Array[StringName]
    for group in tool_obj.get_groups():
        var idx := to_erase.find(group)
        if idx != -1:
            to_erase.remove_at(idx)
        else:
            to_add.push_back(group)
    
    if to_add.size() > 0: data.node_add_groups(runtime, to_add)
    if to_erase.size() > 0: data.node_remove_groups(runtime, to_erase)


func _get_runtime_array(data: RLinkData, array: Array, depth: int) -> Array:
    var copy := array.duplicate()
    for i in array.size():
        copy[i] = _get_runtime_value(data, array[i], depth)
    return copy


func _get_runtime_dictionary(data: RLinkData, dict: Dictionary, depth: int) -> Dictionary:
    var copy := dict.duplicate()
    copy.clear()
    @warning_ignore("untyped_declaration")
    for key in dict:
        copy[_get_runtime_value(data, key, depth)] = _get_runtime_value(data, dict[key], depth)
    return copy
