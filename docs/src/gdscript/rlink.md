---
title: ValidRLink Docs | RLink
description: Documentation for RLink
outline: [2, 4]
---

# RLink

Adds common operations with history support. Any changes to
[`placeholder`](#placeholder-Object) directly won't be included in editor history

## Properties

### placeholder: `Object`

The current placeholder object

## Methods

### get_tree()

Returns current tree

```gdscript
func get_tree() -> SceneTree
```

---

### is_edited_scene_root()

Compares current node with edited_scene_root

```gdscript
func is_edited_scene_root() -> bool
```

---

### get_tool_from()

Retrieves tool object if exist, if it doesn't returns null

```gdscript
func get_tool_from(runtime: Object) -> Object
```

---

### get_runtime_from()

Retrieves placeholder object if exist, if it doesn't returns null

```gdscript
func get_runtime_from(tool_obj: Object) -> Object
```

---

### convert_to_tool()

Converts placeholder to a tool object

```gdscript
func convert_to_tool(runtime: Object, custom_depth: int = 1) -> Object
```

---

### convert_to_runtime()

Converts tool object to placeholder

```gdscript
func convert_to_runtime(tool_obj: Object, custom_depth: int = 1, track_instances: bool = true) -> Object
```

---

### is_pair_invalid()

Check if the registered pair is invalid. For runtime nodes being outside of tree counts as invalid

```gdscript
func is_pair_invalid(obj: Object, delete_if_invalid: bool = true) -> bool
```

---

### is_pair_valid()

Check if the registered pair is valid. For runtime nodes being outside of tree counts as invalid

```gdscript
func is_pair_valid(obj: Object, delete_if_invalid: bool = true) -> bool
```

---

### instantiate_file()

Instantiates scene and converts root node to real type

```gdscript
func instantiate_file(path: String) -> Node
```

---

### instantiate_packed()

Instantiates scene and converts root node to real type

```gdscript
func instantiate_packed(scene: PackedScene) -> Node
```

---

### get_parent()

Gets parent as real type

```gdscript
func get_parent() -> Node
```

---

### get_parent_for()

Gets parent for node as real type

```gdscript
func get_parent_for(tool_node: Node) -> Node
```

---

### get_node_or_null()

Gets node as real type from current

```gdscript
func get_node_or_null(path: NodePath) -> Node
```

---

### get_node_or_null_from()

Gets node from node as real type

```gdscript
func get_node_or_null_from(tool_node: Node, path: NodePath) -> Node
```

---

### has_node()

Checks if node exist

```gdscript
func has_node(path: NodePath) -> bool
```

---

### has_node_from()

Checks if node exist from node

```gdscript
func has_node_from(tool_node: Node, path: NodePath) -> bool
```

---

### add_child()

Adds child to current node

```gdscript
func add_child(child: Node) -> void
```

---

### add_child_to()

Adds child to `tool_node` node

```gdscript
func add_child_to(tool_node: Node, child: Node) -> void
```

---

### add_child_path()

Gets the node before last segment and adds a child to it with the name from the last segment
When the last parameter is true, frees passed `child` if node before last segment  
from `path` is not found

```gdscript
func add_child_path(path: NodePath, child: Node, free_if_not_found: bool = true) -> void
```

---

### remove_child()

Removes child from current node

```gdscript
func remove_child(child: Node) -> void
```

---

### remove_child_from()

Removes child from node

```gdscript
func remove_child_from(tool_node: Node, child: Node) -> void
```

---

### remove_child_path()

Removes the node at the end of the path from current

```gdscript
func remove_child_path(path: NodePath) -> void
```

---

### remove_all_children()

Removes all children from current node

```gdscript
func remove_all_children() -> void
```

---

### remove_all_children_from()

Removes all children from `tool_node`

```gdscript
func remove_all_children_from(tool_node: Node) -> void
```

---

### remove_all_children_path()

Removes all children from the node at path

```gdscript
func remove_all_children_path(path: NodePath) -> void
```

---

### signal_connect()

Connects them persistingly, bound arguments get added first, then unbind. Callables are treated as connected if
they have the same object and method, so different binds are treated as the same callable

```gdscript
func signal_connect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void
```

---

### signal_disconnect()

Disconnects them, bound arguments get added first, then unbind. Callables are treated as connected if
they have the same object and method, so different binds are treated as the same callable

```gdscript
func signal_disconnect(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void
```

---

### signal_is_connected()

Check if callable connected to the signal. Callables are treated as connected if
they have the same object and method, so different binds are treated as the same callable

```gdscript
func signal_is_connected(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> bool
```

---

### signal_toggle()

Checks if connected, if connected disconnects callable, if not callable is connected

```gdscript
func signal_toggle(signal_value: Signal, callable: Callable, bindv_args: Array = [], unbind: int = 0) -> void
```

---

### add_changes()

The added changes will be added to buffer and added to history. In the case of checked
call, if the check fails, all changes gets discarded

```gdscript
func add_changes(object: Object, property: StringName, old_value: Variant, value: Variant) -> void
```

---

### add_do_method()

Only works with native resources. Other objects get duplicated, so they are alive only
for a limited time, so general do methods for them won't be supported

```gdscript
func add_do_method(object: Resource, method: StringName, args: Array = []) -> void
```

---

### add_undo_method()

Only works with native resources. Other objects get duplicated, so they are alive only
for a limited time, so general do methods for them won't be supported

```gdscript
func add_undo_method(object: Resource, method: StringName, args: Array = []) -> void
```
