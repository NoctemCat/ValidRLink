@tool
extends "./converter_base.gd"

const RLinkMap = preload("./rlink_map.gd")
const RLinkUndoRedo = preload("./rlink_undo_redo.gd")

var __map: RLinkMap
var __undo_redo: RLinkUndoRedo
var _visit: Dictionary
var _script_error := false
var _register_tool_instances := false


func _init(context: Context) -> void:
    super(context)
    __map = context.rlink_map
    __undo_redo = context.undo_redo
    
    
func convert_value(tool: Variant, depth: int = 0, register_tool_instances := true) -> Variant:
    if depth == -1: depth = __setting.max_depth - 1
    _script_error = false
    _visit.clear()
    _register_tool_instances = register_tool_instances
    var runtime: Variant = _get_runtime_value(tool, depth)
    _register_tool_instances = false
    if _script_error: 
        push_warning("ValidRLink: Detected error in script [converter_to_runtime.convert_value]")
    return runtime
    
    
func _get_runtime_value(tool_value: Variant, depth: int) -> Variant: 
    if _script_error: return null
    if tool_value == null: return tool_value
    
    var runtime_value
    var type := typeof(tool_value)
    if type == TYPE_OBJECT:
        var new_runtime := _get_runtime_object(tool_value)
        if new_runtime == null:
            _script_error = true
            return null
        if not is_same(tool_value, new_runtime):
            _set_runtime_object(new_runtime, tool_value, depth)
        runtime_value = new_runtime
    elif type == TYPE_DICTIONARY:
        runtime_value = _get_runtime_dictionary(tool_value, depth)
    elif type == TYPE_ARRAY:
        runtime_value = _get_runtime_array(tool_value, depth)
    else:
        runtime_value = tool_value

    return runtime_value
    
    
func _get_runtime_object(tool: Object) -> Object:
    var runtime: Object = __map.runtime_from_obj(tool)
    if runtime != null: 
         return runtime
    
    if _pass_directly(tool):
        return tool
    
    var script: Script = tool.get_script()
    runtime = ClassDB.instantiate(tool.get_class())
    if script != null: runtime.set_script(script)
    if script != null and runtime == null:
        _script_error = true
        return null
    
    if _register_tool_instances:
        __map.add_pair(runtime, tool)
    else:
        __map.add_pair_no_tracking(runtime, tool)
    return runtime
    
    
func _set_runtime_object(runtime: Object, tool: Object, depth: int) -> void:
    if _script_error: return
    var from_id := tool.get_instance_id()
    if _visit.has(from_id): return
    _visit[from_id] = true
    
    var res := __scan_cache.get_search(runtime)
    var to_skip: PackedStringArray = res.skip_properties
        
    if tool is Node: _copy_groups(runtime, tool)
    
    for prop in tool.get_property_list():
        if(_skip_property(to_skip, prop)): continue
        var prop_name: StringName = prop["name"]
        var prop_type: int = prop["type"]
        var tool_value: Variant = tool.get(prop_name)
        
        if _skip_value(tool_value, prop_type, depth): continue
            
        var original_value: Variant = runtime.get(prop_name)
        if original_value is Resource and _skip_resource(original_value):
            #from.set(prop_name, null)
            continue
            
        var new_runtime_value: Variant = _get_runtime_value(tool_value, depth + 1)
        if _script_error: return
        
        if original_value != new_runtime_value:
            __undo_redo.add_changes(runtime, prop_name, original_value, new_runtime_value)


func _copy_groups(runtime: Node, tool: Node) -> void:
    var to_erase: Array[StringName]
    for group in runtime.get_groups():
        if "_root_canvas" in group: continue 
        to_erase.push_back(group)
        
    var to_add: Array[StringName]
    for group in tool.get_groups():
        var idx := to_erase.find(group)
        if idx != -1:
            to_erase.remove_at(idx)
        else:
            to_add.push_back(group)
            
    __undo_redo.node_add_groups(runtime, to_add)
    __undo_redo.node_remove_groups(runtime, to_erase)


func _get_runtime_array(array: Array, depth: int) -> Array:
    var copy := array.duplicate()
    for i in array.size():
        copy[i] = _get_runtime_value(array[i], depth)
    return copy


func _get_runtime_dictionary(dict: Dictionary, depth: int) -> Dictionary:
    var copy := dict.duplicate()
    copy.clear()
    @warning_ignore("untyped_declaration")
    for key in dict:
        copy[_get_runtime_value(key, depth)] = _get_runtime_value(dict[key], depth)
    return copy
    
