@tool
class_name RLink
extends RefCounted


var _data_id: int
var _data: RefCounted:
    get: return instance_from_id(_data_id)
var placeholder: Object:
    get: return instance_from_id(_data.object_id)
    
    
func _init(in_data: RefCounted) -> void: 
    _data_id = in_data.get_instance_id()


func get_tree() -> SceneTree:
    return Engine.get_main_loop()
    
    
func get_tool_from(runtime: Object) -> Object:
    return _data.get_tool(runtime)

    
func get_runtime_from(tool: Object) -> Object:
    return _data.get_runtime(tool)


func convert_to_tool(runtime: Object, custom_depth: int = 1) -> Object:
    return _data.convert_to_tool(runtime, custom_depth)

    
func convert_to_runtime(tool: Object, custom_depth: int = 1, track_instances: bool = true) -> Object:
    return _data.convert_to_runtime(tool, custom_depth, track_instances)
    
    
func is_pair_valid(obj: Object, delete_if_invalid: bool = true) -> bool:
    return _data.is_pair_valid(obj, delete_if_invalid)


func is_pair_invalid(obj: Object, delete_if_invalid: bool = true) -> bool:
    return not _data.is_pair_valid(obj, delete_if_invalid)
    
    
func instantiate_file(path: String) -> Node:
    return instantiate_packed(load(path))
    
    
func instantiate_packed(scene: PackedScene) -> Node:
    var instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
    return _data.convert_to_tool(instance, 1)


func get_node_or_null(path: NodePath) -> Node:
    if not placeholder is Node: return null
    
    var runtime: Node = placeholder.get_node_or_null(path)
    return _data.convert_to_tool(runtime, 1)
    
    
func get_node_or_null_from(tool_node: Node, path: NodePath) -> Node:
    var runtime_node: Node = _data.get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: runtime pair is not registered")
        return null
        
    var runtime: Node = runtime_node.get_node_or_null(path)
    return _data.convert_to_tool(runtime, 1)


func has_node(path: NodePath) -> bool:
    if not placeholder is Node: return false
    return placeholder.has_node(path)
    
    
func has_node_from(tool_node: Node, path: NodePath) -> bool:
    var runtime_node: Node = _data.get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: runtime pair is not registered")
        return false
    return runtime_node.has_node(path)
    
    
func add_child(child: Node) -> void:
    if not placeholder is Node: return 
    
    var runtime_child: Node = _data.convert_to_runtime(child, 1, true)
    _data.add_child_to(placeholder, runtime_child)
    
    
func add_child_to(tool_node: Node, child: Node) -> void:
    var runtime_node: Node = _data.get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: runtime pair is not registered")
        return 
        
    var runtime_child: Node = _data.convert_to_runtime(child, 1, true)
    _data.add_child_to(runtime_node, runtime_child)
    
    
func add_child_path(path: NodePath, child: Node) -> void:
    if not placeholder is Node: return 
    var runtime_node: Node = placeholder.get_node_or_null(path)
    if runtime_node == null:
        return
        
    var runtime_child: Node = _data.convert_to_runtime(child, 1, true)
    _data.add_child_to(runtime_node, runtime_child)
    

func remove_child(child: Node) -> void:
    if not placeholder is Node: return 
    var runtime_child: Node = _data.get_runtime(child)
    if runtime_child == null:
        push_error("ValidRLink: runtime pair is not registered")
        return 
    
    _data.remove_child_from(placeholder, runtime_child)


func remove_child_from(tool_node: Node, child: Node) -> void:
    var runtime_node: Node = _data.get_runtime(tool_node)
    var runtime_child: Node = _data.get_runtime(child)
    if runtime_node == null or runtime_child == null:
        push_error("ValidRLink: runtime pair is not registered")
        return 
    _data.remove_child_from(runtime_node, runtime_child)


func remove_child_path(path: NodePath, child: Node) -> void:
    if not placeholder is Node: return 
    var runtime_node: Node = placeholder.get_node_or_null(path)
    if runtime_node == null:
        return
    var runtime_child: Node = _data.get_runtime(child)
    if runtime_child == null:
        push_error("ValidRLink: runtime pair is not registered")
        return 
    _data.remove_child_from(runtime_node, runtime_child)


func signal_connect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    _data.signal_connect(signal_value, callable, bindv_args, unbind)


func signal_disconnect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    _data.signal_disconnect(signal_value, callable, bindv_args, unbind)


func signal_is_connected(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> bool: 
    return _data.signal_is_connected(signal_value, callable, bindv_args, unbind)


func add_do_property(object: Object, property: StringName, value: Variant) -> void:
    _data.add_do_property(object, property, value)
    
    
func add_undo_property(object: Object, property: StringName, value: Variant) -> void:
    _data.add_undo_property(object, property, value)
