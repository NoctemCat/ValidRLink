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


func is_edited_scene_root() -> bool:
    return placeholder == get_tree().edited_scene_root


func get_tool_from(runtime: Object) -> Object:
    return _data.rlink_get_tool(runtime)


func get_runtime_from(tool_obj: Object) -> Object:
    return _data.rlink_get_runtime(tool_obj)


func convert_to_tool(runtime: Object, custom_depth: int = 1) -> Object:
    return _data.rlink_convert_to_tool(runtime, custom_depth)


func convert_to_runtime(tool_obj: Object, custom_depth: int = 1, track_instances: bool = true) -> Object:
    return _data.rlink_convert_to_runtime(tool_obj, custom_depth, track_instances)


func is_pair_valid(obj: Object, delete_if_invalid: bool = true) -> bool:
    return _data.rlink_is_pair_valid(obj, delete_if_invalid)


func is_pair_invalid(obj: Object, delete_if_invalid: bool = true) -> bool:
    return not _data.rlink_is_pair_valid(obj, delete_if_invalid)


func instantiate_file(path: String) -> Node:
    return instantiate_packed(load(path))


func instantiate_packed(scene: PackedScene) -> Node:
    var instance := scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
    return _data.rlink_convert_to_tool(instance, 1)


func get_node_or_null(path: NodePath) -> Node:
    if not placeholder is Node: return null
    
    var runtime: Node = placeholder.get_node_or_null(path)
    return _data.rlink_convert_to_tool(runtime, 1)
    

func get_node_or_null_from(tool_node: Node, path: NodePath) -> Node:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: runtime pair is not registered")
        return null
        
    var runtime: Node = runtime_node.get_node_or_null(path)
    return _data.rlink_convert_to_tool(runtime, 1)


func has_node(path: NodePath) -> bool:
    if not placeholder is Node: return false
    return placeholder.has_node(path)
    

func has_node_from(tool_node: Node, path: NodePath) -> bool:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: runtime pair is not registered")
        return false
    return runtime_node.has_node(path)
    

func add_child(child: Node) -> void:
    if not placeholder is Node: return
    
    var runtime_child: Node = _data.rlink_convert_to_runtime(child, 1, true)
    _data.rlink_add_child_to(placeholder, runtime_child)
    

func add_child_to(tool_node: Node, child: Node) -> void:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    if runtime_node == null:
        push_error("ValidRLink: runtime pair is not registered")
        return
        
    var runtime_child: Node = _data.rlink_convert_to_runtime(child, 1, true)
    _data.rlink_add_child_to(runtime_node, runtime_child)
    

func add_child_to_path(path: NodePath, child: Node) -> void:
    if not placeholder is Node: return
    var runtime_node: Node = placeholder.get_node_or_null(path)
    if runtime_node == null:
        return
        
    var runtime_child: Node = _data.rlink_convert_to_runtime(child, 1, true)
    _data.rlink_add_child_to(runtime_node, runtime_child)


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


func remove_child(child: Node) -> void:
    if not placeholder is Node: return
    var runtime_child: Node = _data.rlink_get_runtime(child)
    if runtime_child == null:
        push_error("ValidRLink: runtime pair is not registered")
        return
    
    _data.rlink_remove_child_from(placeholder, runtime_child)


func remove_child_from(tool_node: Node, child: Node) -> void:
    var runtime_node: Node = _data.rlink_get_runtime(tool_node)
    var runtime_child: Node = _data.rlink_get_runtime(child)
    if runtime_node == null or runtime_child == null:
        push_error("ValidRLink: runtime pair is not registered")
        return
    _data.rlink_remove_child_from(runtime_node, runtime_child)


func remove_child_from_path(path: NodePath, child: Node) -> void:
    if not placeholder is Node: return
    var runtime_node: Node = placeholder.get_node_or_null(path)
    if runtime_node == null:
        return
    var runtime_child: Node = _data.rlink_get_runtime(child)
    if runtime_child == null:
        push_error("ValidRLink: runtime pair is not registered")
        return
    _data.rlink_remove_child_from(runtime_node, runtime_child)
    

func remove_child_path(path: NodePath) -> void:
    if not placeholder is Node: return
    var runtime_child: Node = placeholder.get_node_or_null(path)
    if runtime_child == null: return
    _data.rlink_remove_child_from(runtime_child.get_parent(), runtime_child)
    

func signal_connect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    _data.rlink_signal_connect(signal_value, callable, bindv_args, unbind)


func signal_disconnect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    _data.rlink_signal_disconnect(signal_value, callable, bindv_args, unbind)


func signal_is_connected(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> bool:
    return _data.rlink_signal_is_connected(signal_value, callable, bindv_args, unbind)


func signal_toggle(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void:
    if signal_is_connected(signal_value, callable, bindv_args, unbind):
        signal_disconnect(signal_value, callable, bindv_args, unbind)
    else:
        signal_connect(signal_value, callable, bindv_args, unbind)


## Intended to be used to add changes for native resources, but can be also used to 
## manually add changes with undo support
func add_changes(object: Object, property: StringName, old_value: Variant, value: Variant) -> void:
    _data.rlink_add_changes(object, property, old_value, value)


## Works only with native resources
func add_do_method(object: Resource, method: StringName, args: Array = []) -> void:
    _data.rlink_add_do_method(object, method, args)


## Works only with native resources
func add_undo_method(object: Resource, method: StringName, args: Array = []) -> void:
    _data.rlink_add_undo_method(object, method, args)
