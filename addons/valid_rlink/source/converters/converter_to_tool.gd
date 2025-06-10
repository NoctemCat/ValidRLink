@tool
extends "./converter_base.gd"


func _init(context: Context) -> void:
    super (context)
    

func _convert_value(data: RLinkData, runtime_value: Variant, depth: int = 0) -> Variant:
    data.converter_converted_object = false
    data.script_error = false
    data.visit.clear()
    if depth == -1: depth = data.max_depth - 1
    
    var tool: Variant = _get_tool_value(data, runtime_value, depth)
    if data.script_error:
        push_warning("ValidRLink: Detected error in script [converter_to_tool.convert_value]")
    data.visit.clear()
    return tool
    
    
func _get_tool_value(data: RLinkData, runtime_value: Variant, depth: int) -> Variant:
    if data.script_error: return null
    if runtime_value == null: return runtime_value
    
    var tool_value: Variant
    var type := typeof(runtime_value)
    if type == TYPE_OBJECT:
        var new_tool_value := _get_tool_object(data, runtime_value, depth)
        if new_tool_value == null:
            data.script_error = true
            return null
        if not is_same(runtime_value, new_tool_value):
            _set_tool_object(data, runtime_value, new_tool_value, depth)
        tool_value = new_tool_value
    elif type == TYPE_DICTIONARY:
        tool_value = _get_tool_dictionary(data, runtime_value, depth)
    elif type == TYPE_ARRAY:
        tool_value = _get_tool_array(data, runtime_value, depth)
    elif __settings.duplicate_packed_arrays and type >= TYPE_PACKED_BYTE_ARRAY and type <= 38:
        tool_value = runtime_value.duplicate()
    else:
        tool_value = runtime_value
    return tool_value


func _get_tool_object(data: RLinkData, runtime: Object, depth: int) -> Object:
    data.converter_converted_object = true
    var tool_obj: Object = __map.tool_from_obj(runtime)
    if tool_obj != null:
        return tool_obj
    
    if _pass_directly(runtime):
        return runtime
    
    var script: Script = runtime.get_script()
    tool_obj = (
        script.new() if script != null
        else ClassDB.instantiate(runtime.get_class())
    )
    if script != null and tool_obj == null:
        data.script_error = true
        return null
    
    _tool_register_defaults(data, runtime, tool_obj, depth)
    return tool_obj


func _tool_register_defaults(data: RLinkData, runtime: Object, tool_obj: Object, depth: int) -> void:
    if __map.is_runtime(runtime): return
    __map.add_pair(runtime, tool_obj)

    if __ctx.object_is_button(runtime):
        _connect_rlink_buttons(data, runtime)

    var res := __scan_cache.get_search(runtime)
    __scan_cache.add_pair(runtime, tool_obj)
    
    for prop in runtime.get_property_list():
        if (_skip_property(res.skip_properties, res.allowed_properties, prop)):
            continue
        var prop_name: StringName = prop["name"]
        if prop["type"] != TYPE_OBJECT or prop_name == &"script":
            continue
        var runtime_value: Object = runtime.get(prop_name)
        var tool_value: Object = tool_obj.get(prop_name)
        if runtime_value == null or tool_value == null or _skip_value(data, prop, tool_value, depth):
            continue
            
        var script: Script = tool_value.get_script()
        if script == null or script.is_tool():
            _tool_register_defaults(data, runtime_value, tool_value, depth + 1)


func _connect_rlink_buttons(data: RLinkData, runtime: Resource) -> void:
    if not runtime.changed.is_connected(data.reflect_to_tool.bind(runtime, 1)):
        runtime.changed.connect(data.reflect_to_tool.bind(runtime, 1))


func _set_tool_object(data: RLinkData, runtime: Object, tool_obj: Object, depth: int) -> void:
    if data.script_error: return
    var runtime_id := runtime.get_instance_id()
    if data.visit.has(runtime_id): return
    data.visit[runtime_id] = true
    
    var res := __scan_cache.get_search(runtime)
    if runtime is Node:
        if runtime.name: tool_obj.name = runtime.name
        _copy_groups(runtime, tool_obj)
    
    for prop in runtime.get_property_list():
        if (_skip_property(res.skip_properties, res.allowed_properties, prop)):
            continue
        var is_button := _is_rlink_button(prop)
        var prop_name: StringName = prop["name"]
        var value: Variant = runtime.get(prop_name)

        if _skip_value(data, prop, value, depth):
            continue
        if is_button and value == null: continue
        
        var tool_value: Variant
        if value is Node and not value.is_inside_tree():
            # exported nodes should always be inside tree
            tool_value = null
        else:
            tool_value = _get_tool_value(data, value, depth + 1)
            if data.script_error: return
        
        tool_obj.set(prop_name, tool_value)


func _copy_groups(runtime: Node, tool_obj: Node) -> void:
    for group in tool_obj.get_groups():
        tool_obj.remove_from_group(group)
    for group in runtime.get_groups():
        if "_root_canvas" in group: continue
        tool_obj.add_to_group(group, true)
        

func _get_tool_array(data: RLinkData, array: Array, depth: int) -> Array:
    var copy := array.duplicate()
    for i in array.size():
        copy[i] = _get_tool_value(data, array[i], depth)
    return copy


func _get_tool_dictionary(data: RLinkData, dict: Dictionary, depth: int) -> Dictionary:
    var copy := dict.duplicate()
    copy.clear()
    @warning_ignore("untyped_declaration")
    for key in dict:
        copy[_get_tool_value(data, key, depth)] = _get_tool_value(data, dict[key], depth)
    return copy
