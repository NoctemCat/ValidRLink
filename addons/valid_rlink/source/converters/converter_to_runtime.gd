@tool
extends "./converter_base.gd"


func _init(context: Context) -> void:
    super (context)
    
    
func _convert_value(buffer: RLinkBuffer, tool_value: Variant, depth: int = 0, _search_ctx: Object = null) -> Variant:
    buffer.converter_converted_object = false
    buffer.script_error = false
    buffer.visit.clear()
    if tool_value == null: return null
    
    if _search_ctx != null: buffer.result = __scan_cache.get_search(_search_ctx)
    else: buffer.result = __scan_cache.get_search(tool_value)
    if depth == -1: depth = buffer.max_depth - 1
    
    var runtime: Variant = _get_runtime_value(buffer, tool_value, depth)
    if buffer.script_error:
        push_warning("ValidRLink: Detected error in script [converter_to_runtime.convert_value]")
    buffer.visit.clear()
    return runtime
    
    
func _get_runtime_value(buffer: RLinkBuffer, tool_value: Variant, depth: int) -> Variant:
    if buffer.script_error: return null
    if tool_value == null: return tool_value
    
    var runtime_value: Variant
    var type := typeof(tool_value)
    if type == TYPE_OBJECT:
        var new_runtime := _get_runtime_object(buffer, tool_value)
        if new_runtime == null:
            buffer.script_error = true
            return null
        if not is_same(tool_value, new_runtime):
            _set_runtime_object(buffer, new_runtime, tool_value, depth)
        runtime_value = new_runtime
    elif type == TYPE_DICTIONARY:
        runtime_value = _get_runtime_dictionary(buffer, tool_value, depth)
    elif type == TYPE_ARRAY:
        runtime_value = _get_runtime_array(buffer, tool_value, depth)
    else:
        runtime_value = tool_value

    return runtime_value
    
    
func _get_runtime_object(buffer: RLinkBuffer, tool_obj: Object) -> Object:
    buffer.converter_converted_object = true
    var runtime: Object = __map.runtime_from_obj(tool_obj)
    if runtime != null:
         return runtime
    
    if _pass_directly(tool_obj):
        return tool_obj
    
    var script: Script = tool_obj.get_script()
    runtime = ClassDB.instantiate(tool_obj.get_class())
    if script != null: runtime.set_script(script)
    if script != null and runtime == null:
        buffer.script_error = true
        return null
        
    if buffer.track_tool_instances:
        __map.add_pair(runtime, tool_obj)
    else:
        __map.add_pair_no_tracking(runtime, tool_obj)
    return runtime
    
    
func _set_runtime_object(buffer: RLinkBuffer, runtime: Object, tool_obj: Object, depth: int) -> void:
    if buffer.script_error: return
    var from_id := tool_obj.get_instance_id()
    if buffer.visit.has(from_id): return
    buffer.visit[from_id] = true
    
    var res := __scan_cache.get_search(runtime)
    if tool_obj is Node:
        if tool_obj.name and runtime.name != tool_obj.name:
            buffer.object_add_changes(runtime, &"name", runtime.name, tool_obj.name)
        _copy_groups(buffer, runtime, tool_obj)
    
    for prop in tool_obj.get_property_list():
        if _skip_type(buffer, prop["type"], depth): continue
        if _skip_property(res.skip_properties, res.allowed_properties, prop): continue

        var prop_name: StringName = prop["name"]
        var original_value: Variant = runtime.get(prop_name)
        if _skip_object(original_value): continue
        var tool_value: Variant = tool_obj.get(prop_name)
        if _skip_object(tool_value): continue
        
        var new_runtime_value: Variant = _get_runtime_value(buffer, tool_value, depth + 1)
        if buffer.script_error: return
        
        if original_value != new_runtime_value:
            if !__settings.apply_changes_to_external_user_resources and _is_external_resource(runtime):
                push_warning(
                    ("ValidRLink: Trying to apply changes to external resource in %s, if this "
                    +"is intended set `apply_changes_to_external_user_resources` to true "
                    +"in project settings [converter_to_runtime._set_runtime_object]")
                    % buffer.object_name
                )
                return
            buffer.object_add_changes(runtime, prop_name, original_value, new_runtime_value)
    
    var to_remove := runtime.get_meta_list()
    for meta in tool_obj.get_meta_list():
        var idx := to_remove.find(meta)
        if idx != -1: to_remove.remove_at(idx)
    
    for meta in to_remove:
        buffer.object_remove_meta(runtime, meta)


func _copy_groups(buffer: RLinkBuffer, runtime: Node, tool_obj: Node) -> void:
    var to_erase: Array[StringName] = []
    for group in runtime.get_groups():
        if "_root_canvas" in group: continue
        to_erase.push_back(group)
        
    var to_add: Array[StringName] = []
    for group in tool_obj.get_groups():
        var idx := to_erase.find(group)
        if idx != -1:
            to_erase.remove_at(idx)
        else:
            to_add.push_back(group)
    
    if to_add.size() > 0: buffer.node_add_groups(runtime, to_add)
    if to_erase.size() > 0: buffer.node_remove_groups(runtime, to_erase)


func _get_runtime_array(buffer: RLinkBuffer, array: Array, depth: int) -> Array:
    var copy := array.duplicate()
    for i in array.size():
        copy[i] = _get_runtime_value(buffer, array[i], depth)
    return copy


func _get_runtime_dictionary(buffer: RLinkBuffer, dict: Dictionary, depth: int) -> Dictionary:
    var copy := dict.duplicate()
    copy.clear()
    for key in dict:
        copy[_get_runtime_value(buffer, key, depth)] = _get_runtime_value(buffer, dict[key], depth)
    return copy
