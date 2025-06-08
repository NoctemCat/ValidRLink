@tool
extends RefCounted

const Context = preload("./../context.gd")

var _created_objects_ids: Array[int]
var _tool_ids_table: Dictionary 
var _runtime_ids_table: Dictionary


func tool_from_obj(runtime: Object) -> Object:
    var tool_id: int = _tool_ids_table.get(runtime.get_instance_id(), 0)
    if tool_id == 0: return null
    return instance_from_id(tool_id)
    
    
func tool_from_id(runtime_id: int) -> Object:
    var tool_id: int = _tool_ids_table.get(runtime_id, 0)
    if tool_id == 0: return null
    return instance_from_id(tool_id)
    
    
func tool_id_from_id(runtime_id: int) -> int:
    return _tool_ids_table.get(runtime_id, 0)


func runtime_from_obj(tool: Object) -> Object:
    var runtime_id: int = _runtime_ids_table.get(tool.get_instance_id(), 0)
    if runtime_id == 0: return null
    return instance_from_id(runtime_id)
    
    
func runtime_from_id(tool_id: int) -> Object:
    var runtime_id: int = _runtime_ids_table.get(tool_id, 0)
    if runtime_id == 0: return null
    return instance_from_id(runtime_id)
    
    
func runtime_id_from_id(tool_id: int) -> int:
    return _runtime_ids_table.get(tool_id, 0)


func add_pair(runtime: Object, tool: Object) -> void:
    var runtime_id := runtime.get_instance_id()
    var tool_id := tool.get_instance_id()
    _tool_ids_table[runtime_id] = tool_id
    _runtime_ids_table[tool_id] = runtime_id
    _created_objects_ids.push_back(tool_id)
    
    
func add_pair_id(runtime_id: int, tool_id: int) -> void:
    _tool_ids_table[runtime_id] = tool_id
    _runtime_ids_table[tool_id] = runtime_id
    _created_objects_ids.push_back(tool_id)


func add_pair_no_tracking(runtime: Object, tool: Object) -> void:
    var runtime_id := runtime.get_instance_id()
    var tool_id := tool.get_instance_id()
    _tool_ids_table[runtime_id] = tool_id
    _runtime_ids_table[tool_id] = runtime_id


func erase_pair(runtime: Object, tool: Object) -> void:
    var runtime_id := runtime.get_instance_id()
    var tool_id := tool.get_instance_id()
    _tool_ids_table.erase(runtime_id)
    _runtime_ids_table.erase(tool_id)
    
    
func erase_pair_id(runtime_id: int, tool_id: int) -> void:
    _tool_ids_table.erase(runtime_id)
    _runtime_ids_table.erase(tool_id)


func is_tool(object: Object) -> bool:
    return _runtime_ids_table.has(object.get_instance_id())
    
    
func is_runtime(object: Object) -> bool:
    return _tool_ids_table.has(object.get_instance_id())


func clear() -> void:
    for tool_id in _created_objects_ids:
        var tool_obj := instance_from_id(tool_id)
        if tool_obj != null and not tool_obj is Resource: 
            tool_obj.free()

    _created_objects_ids.clear()
    _tool_ids_table.clear()
    _runtime_ids_table.clear()
