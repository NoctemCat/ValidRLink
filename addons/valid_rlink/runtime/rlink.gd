@tool
class_name RLink
extends RefCounted
## Adds common operations with history support

var _data_id: int
var _object_id: int
var _data: RefCounted:
    get: return instance_from_id(_data_id)
var placeholder: Object: ## The current placeholder object
    get: return instance_from_id(_object_id)
    
    
func _init(in_data: RefCounted) -> void:
    _data_id = in_data.get_instance_id()
    _object_id = in_data._object_id


func get_tree() -> SceneTree:
    return Engine.get_main_loop()


## Compares current node with edited_scene_root
func is_edited_scene_root() -> bool:
    return placeholder == get_tree().edited_scene_root


## Retrieves tool object if exist
func get_tool_from(runtime: Object) -> Object:
    return _data.rlink_get_tool(runtime)


## Retrieves placeholder object if exist
func get_runtime_from(tool_obj: Object) -> Object:
    return _data.rlink_get_runtime(tool_obj)


## Converts placeholder to a tool object
func convert_to_tool(runtime: Object, custom_depth: int = 1) -> Object:
    return _data.rlink_convert_to_tool(runtime, custom_depth)


## Converts tool object to placeholder
func convert_to_runtime(tool_obj: Object, custom_depth: int = 1, track_instances: bool = true) -> Object:
    return _data.rlink_convert_to_runtime(tool_obj, custom_depth, track_instances)


## Check if the registered pair is invalid. For nodes being outside of tree counts as invalid
func is_pair_invalid(obj: Object, delete_if_invalid: bool = true) -> bool:
    return not _data.rlink_is_pair_valid(obj, delete_if_invalid)


## Check if the registered pair is valid. For nodes being outside of tree counts as invalid
func is_pair_valid(obj: Object, delete_if_invalid: bool = true) -> bool:
    return _data.rlink_is_pair_valid(obj, delete_if_invalid)


## Instantiates scene and converts root node to real type
func instantiate_file(path: String) -> Node:
    return instantiate_packed(load(path))


## Instantiates scene and converts root node to real type
func instantiate_packed(scene: PackedScene) -> Node:
    var instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
    return _data.rlink_convert_to_tool(instance, 1)


## Gets parent as real type
func get_parent() -> Node:
    if not placeholder is Node: return null
    var parent: Node = placeholder.get_parent()
    if parent == null: return null
    return convert_to_tool(parent)


## Gets parent for node as real type
func get_parent_for(tool_node: Node) -> Node:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: Runtime pair is not registered [rlink.get_parent_for]")
        return null
    var parent: Node = runtime_node.get_parent()
    if parent == null: return null
    return convert_to_tool(parent)


## Gets node as real type
func get_node_or_null(path: NodePath) -> Node:
    if not placeholder is Node: return null
    
    var runtime: Node = placeholder.get_node_or_null(path)
    return _data.rlink_convert_to_tool(runtime, 1)


## Gets node from node as real type
func get_node_or_null_from(tool_node: Node, path: NodePath) -> Node:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: Runtime pair is not registered [rlink.get_node_or_null_from]")
        return null
        
    var runtime: Node = runtime_node.get_node_or_null(path)
    return _data.rlink_convert_to_tool(runtime, 1)


## Checks if node exist
func has_node(path: NodePath) -> bool:
    if not placeholder is Node: return false
    return placeholder.has_node(path)


## Checks if node exist from node
func has_node_from(tool_node: Node, path: NodePath) -> bool:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: Runtime pair is not registered [rlink.has_node_from]")
        return false
    return runtime_node.has_node(path)


## Adds child to current node
func add_child(child: Node) -> void:
    if not placeholder is Node: return
    
    var runtime_child: Node = _data.rlink_convert_to_runtime(child, 1, true)
    _data.rlink_add_child_to(placeholder, runtime_child)


## Adds child to tool_node node
func add_child_to(tool_node: Node, child: Node) -> void:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: runtime pair is not registered [rlink.add_child_to]")
        return
        
    var runtime_child: Node = _data.rlink_convert_to_runtime(child, 1, true)
    _data.rlink_add_child_to(runtime_node, runtime_child)


## Gets the node before last segment and adds a child to it with the name from the last segment.
## When the last parameter is true, frees passed [code]child[/code] if node before last segment from 
## [code]path[/code] is not found
func add_child_path(path: NodePath, child: Node) -> void:
    if not placeholder is Node: return
    var names := path.get_concatenated_names()
    var idx := names.rfind("/")
    
    var runtime_node: Node
    if idx == -1: runtime_node = placeholder
    else: runtime_node = placeholder.get_node_or_null(names.substr(0, idx))
    if runtime_node == null:
        return
    
    child.name = path.get_name(path.get_name_count() - 1)
    var runtime_child: Node = _data.rlink_convert_to_runtime(child, 1, true)
    _data.rlink_add_child_to(runtime_node, runtime_child)


## Removes child from current node
func remove_child(child: Node) -> void:
    if not placeholder is Node: return
    var runtime_child: Node = _data.rlink_get_runtime(child)
    if runtime_child == null:
        push_error("ValidRLink: Runtime pair is not registered [rlink.remove_child]")
        return
    
    _data.rlink_remove_child_from(placeholder, runtime_child)


## Removes child from node
func remove_child_from(tool_node: Node, child: Node) -> void:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    var runtime_child: Node = _data.rlink_get_runtime(child)
    if runtime_node == null or runtime_child == null:
        push_error("ValidRLink: Runtime pair is not registered [rlink.remove_child_from]")
        return
    _data.rlink_remove_child_from(runtime_node, runtime_child)


## Removes the node at the end of the path from current
func remove_child_path(path: NodePath) -> void:
    if not placeholder is Node: return
    var runtime_child: Node = placeholder.get_node_or_null(path)
    if runtime_child == null: return
    _data.rlink_remove_child_from(runtime_child.get_parent(), runtime_child)


## Removes all children from current node
func remove_all_children() -> void:
    if not placeholder is Node: return
    # Cast to silence untyped warning for idx on 4.4
    var node: Node = placeholder
    for idx in node.get_child_count():
        _data.rlink_remove_child_from(node, node.get_child(idx))


## Removes all children from tool_node
func remove_all_children_from(tool_node: Node) -> void:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: Runtime pair is not registered [rlink.remove_all_children_from]")
        return
    for idx in runtime_node.get_child_count():
        _data.rlink_remove_child_from(runtime_node, runtime_node.get_child(idx))


## Removes all children from the node at path
func remove_all_children_path(path: NodePath) -> void:
    if not placeholder is Node: return
    var runtime_node: Node = placeholder.get_node_or_null(path)
    for idx in runtime_node.get_child_count():
        _data.rlink_remove_child_from(runtime_node, runtime_node.get_child(idx))


## Connects them persistingly, bound arguments get added first, then unbind. Callables are treated as connected if 
## they have the same object and method, so different binds are treated as the same callable
func signal_connect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    _data.rlink_signal_connect(signal_value, callable, bindv_args, unbind)


## Disconnects them, bound arguments get added first, then unbind. Callables are treated as connected if 
## they have the same object and method, so different binds are treated as the same callable
func signal_disconnect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    _data.rlink_signal_disconnect(signal_value, callable, bindv_args, unbind)


## Check if callable connected to the signal. Callables are treated as connected if 
## they have the same object and method, so different binds are treated as the same callable
func signal_is_connected(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> bool:
    return _data.rlink_signal_is_connected(signal_value, callable, bindv_args, unbind)


## Checks if connected, if connected disconnects callable, if not callable is connected
func signal_toggle(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    if signal_is_connected(signal_value, callable, bindv_args, unbind):
        signal_disconnect(signal_value, callable, bindv_args, unbind)
    else:
        signal_connect(signal_value, callable, bindv_args, unbind)


## The added changes will be added to buffer and added to history. In the case of checked 
## call, if the check fails, discards all changes
func add_changes(object: Object, property: StringName, old_value: Variant, value: Variant) -> void:
    _data.rlink_add_changes(object, property, old_value, value)


## Only works with native resources. Other objects get duplicated, so they are alive only 
## for a limited time, so general do methods for them won't be supported
func add_do_method(object: Resource, method: StringName, args: Array = []) -> void:
    _data.rlink_add_do_method(object, method, args)


## Only works with native resources. Other objects get duplicated, so they are alive only 
## for a limited time, so general undo methods for them won't be supported
func add_undo_method(object: Resource, method: StringName, args: Array = []) -> void:
    _data.rlink_add_undo_method(object, method, args)
