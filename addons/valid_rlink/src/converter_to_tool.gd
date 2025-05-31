@tool
extends "./converter_base.gd"

const RLinkMap = preload("./rlink_map.gd")

var __map: RLinkMap
var _visit: Dictionary
var _script_error := false


func _init(context: Context) -> void:
    super(context)
    __map = context.rlink_map
    

func convert_value(runtime: Variant, depth: int = 0) -> Variant:
    if depth == -1: depth = __setting.max_depth - 1
    _script_error = false
    _visit.clear()
    var tool: Variant = _get_tool_value(runtime, depth)
    if _script_error: 
        push_warning("ValidRLink: Detected error in script [converter_to_tool.convert_value]")
    return tool
    
    
func _get_tool_value(runtime_value: Variant, depth: int) -> Variant: 
    if _script_error: return null
    if runtime_value == null: return runtime_value
    
    var tool_value: Variant 
    var type := typeof(runtime_value)
    if type == TYPE_OBJECT:
        var new_tool_value := _get_tool_object(runtime_value)
        if new_tool_value == null:
            _script_error = true
            return null
        if not is_same(runtime_value, new_tool_value):
            _set_tool_object(runtime_value, new_tool_value, depth)
        tool_value = new_tool_value
    elif type == TYPE_DICTIONARY:
        tool_value = _get_tool_dictionary(runtime_value, depth)
    elif type == TYPE_ARRAY:
        tool_value = _get_tool_array(runtime_value, depth)
    elif __setting.duplicate_packed_arrays and type >= TYPE_PACKED_BYTE_ARRAY and type <= 38:
        tool_value = runtime_value.duplicate()
    else:
        tool_value = runtime_value
    return tool_value


func _get_tool_object(runtime: Object) -> Object:
    var tool: Object = __map.tool_from_obj(runtime)
    if tool != null: 
        return tool
    
    if _pass_directly(runtime):
        return runtime
    
    var script: Script = runtime.get_script()
    tool = (
        script.new() if script != null 
        else ClassDB.instantiate(runtime.get_class())
    )
    if script != null and tool == null:
        _script_error = true
        return null
    
    __map.add_pair(runtime, tool)
    if runtime is RLinkButton: _connect_rlink_buttons(runtime)
    _tool_register_defaults({}, runtime, tool)
    return tool


func _tool_register_defaults(local_visit: Dictionary, runtime: Object, tool: Object) -> void:
    var tool_id := tool.get_instance_id()
    if local_visit.has(tool_id): return
    local_visit[tool_id] = true
    
    var res := __scan_cache.get_search(runtime)
    var to_skip: PackedStringArray = res.skip_properties
    for prop in tool.get_property_list():
        if(_skip_property(to_skip, prop)): continue
        var prop_name: StringName = prop["name"]
        if prop["type"] != TYPE_OBJECT or prop_name == &"script": continue
        
        var runtime_value: Object = runtime.get(prop_name)
        var tool_value: Object = tool.get(prop_name)
        if runtime_value == null or tool_value == null: continue
            
        var script: Script = tool_value.get_script()
        if script == null or script.is_tool():
            __map.add_pair(runtime_value, tool_value)
            _tool_register_defaults(local_visit, runtime_value, tool_value)
            if runtime_value is RLinkButton: _connect_rlink_buttons(runtime_value)


func _connect_rlink_buttons(runtime: RLinkButton) -> void:
    if not runtime.changed.is_connected(_on_runtime_changed.bind(runtime)): 
        runtime.changed.connect(_on_runtime_changed.bind(runtime))


func _on_runtime_changed(runtime: RLinkButton) -> void:
    var tool: Object = convert_value(runtime, 1)
    if tool == null: 
        push_warning("ValidRLink: Detected error in script [converter_to_tool._on_runtime_changed]")
        return


func _set_tool_object(runtime: Object, tool: Object, depth: int) -> void:
    if _script_error: return
    var runtime_id := runtime.get_instance_id()
    if _visit.has(runtime_id): return
    _visit[runtime_id] = true
    
    var res := __scan_cache.get_search(runtime)
    var to_skip: PackedStringArray = res.skip_properties
    if runtime is Node: _copy_groups(runtime, tool)

    for prop in runtime.get_property_list():
        if(_skip_property(to_skip, prop)): continue
        var prop_name: StringName = prop["name"]
        var value: Variant = runtime.get(prop_name)

        if _skip_value(value, prop["type"], depth): continue
        if value == null and prop["type"] == TYPE_OBJECT and prop["hint_string"] == RLinkButton.CLASS_NAME: 
            continue
        
        var tool_value: Variant = _get_tool_value(value, depth + 1)
        if _script_error: return
        
        tool.set(prop_name, tool_value)


func _copy_groups(runtime: Node, tool: Node) -> void:
    for group in tool.get_groups():
        tool.remove_from_group(group)
    for group in runtime.get_groups():
        if "_root_canvas" in group: continue 
        tool.add_to_group(group, true)
        

func _get_tool_array(array: Array, depth: int) -> Array:
    var copy := array.duplicate()
    for i in array.size():
        copy[i] = _get_tool_value(array[i], depth)
    return copy


func _get_tool_dictionary(dict: Dictionary, depth: int) -> Dictionary:
    var copy := dict.duplicate()
    copy.clear()
    @warning_ignore("untyped_declaration")
    for key in dict:
        copy[_get_tool_value(key, depth)] = _get_tool_value(dict[key], depth)
    return copy
