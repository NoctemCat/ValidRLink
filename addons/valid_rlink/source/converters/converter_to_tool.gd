@tool
extends "./converter_base.gd"


func _init(context: Context) -> void:
    super (context)
    

func _convert_value(buffer: RLinkBuffer, runtime_value: Variant, depth: int = 0, search_ctx: Object = null) -> Variant:
    buffer.converter_converted_object = false
    buffer.script_error = false
    buffer.visit.clear()
    if runtime_value == null: return null
    
    if search_ctx != null: buffer.result = __scan_cache.get_search(search_ctx)
    else: buffer.result = __scan_cache.get_search(runtime_value)   
    if depth == -1: depth = buffer.max_depth - 1
    
    var tool: Variant = _get_tool_value(buffer, runtime_value, depth)
    if buffer.script_error:
        push_warning("ValidRLink: Detected error in script [converter_to_tool.convert_value]")
    buffer.visit.clear()
    return tool
    
    
func _get_tool_value(buffer: RLinkBuffer, runtime_value: Variant, depth: int) -> Variant:
    if buffer.script_error: return null
    if runtime_value == null: return runtime_value
    
    var tool_value: Variant
    var type := typeof(runtime_value)
    if type == TYPE_OBJECT:
        var new_tool_value := _get_tool_object(buffer, runtime_value, depth)
        if new_tool_value == null:
            buffer.script_error = true
            return null
        if not is_same(runtime_value, new_tool_value):
            _set_tool_object(buffer, runtime_value, new_tool_value, depth)
        tool_value = new_tool_value
    elif type == TYPE_DICTIONARY:
        tool_value = _get_tool_dictionary(buffer, runtime_value, depth)
    elif type == TYPE_ARRAY:
        tool_value = _get_tool_array(buffer, runtime_value, depth)
    elif __settings.duplicate_packed_arrays and type >= TYPE_PACKED_BYTE_ARRAY and type <= 38:
        tool_value = runtime_value.duplicate()
    else:
        tool_value = runtime_value
    return tool_value


func _get_tool_object(buffer: RLinkBuffer, runtime: Object, depth: int) -> Object:
    buffer.converter_converted_object = true
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
        buffer.script_error = true
        return null
    
    _tool_register_defaults(buffer, runtime, tool_obj, depth)
    return tool_obj


func _tool_register_defaults(buffer: RLinkBuffer, runtime: Object, tool_obj: Object, depth: int) -> void:
    if __map.is_runtime(runtime): return
    __map.add_pair(runtime, tool_obj)

    if __ctx.object_is_button(runtime):
        _connect_rlink_buttons(buffer, runtime)

    var res := __scan_cache.get_search(runtime)
    __scan_cache.add_pair(runtime, tool_obj)
    
    for prop in runtime.get_property_list():
        if (_skip_property(res.skip_properties, res.allowed_properties, prop)):
            continue
        var prop_name: StringName = prop["name"]
        if prop["type"] != TYPE_OBJECT or prop_name == &"script": continue
        
        var runtime_value: Object = runtime.get(prop_name)
        if runtime_value == null: continue
        if _skip_value(buffer, prop, runtime_value, depth): continue
        
        var tool_value: Object = tool_obj.get(prop_name)
        if tool_value == null: continue
        if _skip_value(buffer, prop, tool_value, depth): continue

        var script: Script = tool_value.get_script()
        if script == null or script.is_tool():
            _tool_register_defaults(buffer, runtime_value, tool_value, depth + 1)


func _connect_rlink_buttons(buffer: RLinkBuffer, runtime: Resource) -> void:
    #if not runtime.changed.is_connected(buffer.reflect_to_tool.bind(runtime, 1)):
        #runtime.changed.connect(buffer.reflect_to_tool.bind(runtime, 1))
    if not runtime.changed.is_connected(_convert_value.bind(buffer, runtime, 1)):
        runtime.changed.connect(_convert_value.bind(buffer, runtime, 1))
        

func _set_tool_object(buffer: RLinkBuffer, runtime: Object, tool_obj: Object, depth: int) -> void:
    if buffer.script_error: return
    var runtime_id := runtime.get_instance_id()
    if buffer.visit.has(runtime_id): return
    buffer.visit[runtime_id] = true
    
    var res := __scan_cache.get_search(runtime)
    if runtime is Node:
        if runtime.name: tool_obj.name = runtime.name
        _copy_groups(runtime, tool_obj)
    
    for prop in runtime.get_property_list():
        if _skip_type(buffer, prop["type"], depth): continue
        if _skip_property(res.skip_properties, res.allowed_properties, prop): continue
        
        var prop_name: StringName = prop["name"]
        var value: Variant = runtime.get(prop_name)
        if _skip_object(value): continue
        if value == null and _is_rlink_button(prop): continue
        
        var tool_value: Variant
        if value is Node and not value.is_inside_tree():
            # exported nodes should always be inside tree
            tool_value = null
        else:
            tool_value = _get_tool_value(buffer, value, depth + 1)
            if buffer.script_error: return
        
        tool_obj.set(prop_name, tool_value)


func _copy_groups(runtime: Node, tool_obj: Node) -> void:
    for group in tool_obj.get_groups():
        tool_obj.remove_from_group(group)
    for group in runtime.get_groups():
        if "_root_canvas" in group: continue
        tool_obj.add_to_group(group, true)
        

func _get_tool_array(buffer: RLinkBuffer, array: Array, depth: int) -> Array:
    var copy := array.duplicate()
    for i in array.size():
        copy[i] = _get_tool_value(buffer, array[i], depth)
    return copy


func _get_tool_dictionary(buffer: RLinkBuffer, dict: Dictionary, depth: int) -> Dictionary:
    var copy := dict.duplicate()
    copy.clear()
    @warning_ignore("untyped_declaration")
    for key in dict:
        copy[_get_tool_value(buffer, key, depth)] = _get_tool_value(buffer, dict[key], depth)
    return copy
