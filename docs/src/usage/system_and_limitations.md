---
title: ValidRLink Docs
description: System and Limitations
outline: [2, 4]
---

# System and Limitations

## System

You can load non-tool script and directly instantiate them
::: code-group

```gdscript [tool_node.gd]
@tool
extends Node

func _ready() -> void:
  	var node: Node = preload("res://my_node.gd").new()
    print(node.get_text())
    node.queue_free()
```

```gdscript [my_node.gd]
extends Node

func get_text() -> String:
    return "Text from my_node"
```

:::

```ansi
[0;2mText from my_node[0m

```

Using this it is possible to build a setup that will instantiate and
copy data to it using `get_property_list`.

To get the placeholder you can use `set_script`

::: code-group

```gdscript [tool_node.gd]
@tool
extends Node

func _ready() -> void:
  	var node_script: Script = preload("res://my_node.gd")
    var node: Node = ClassDB.instantiate("Node")
    node.set_script(node_script)
    print(node.get_text())
    node.queue_free()
```

```gdscript [my_node.gd]
extends Node

func get_text() -> String:
    return "Text from my_node"
```

:::

```ansi
[0;31mERROR: res://tool_node.gd:8 - Invalid call function 'get_text' in base 'Node (my_node.gd)': Attempt to call a method on a placeholder instance. Check if the script is in tool mode.[0m
```

You can still set their exported properties, be it directly or
through `get` and `set`. So using this the data will be copied
back

## Limitations

- Only copying of exported properties will be supported
- `Node` won't have any children or parents in the methods, use
  [`RLink`](./../gdscript/rlink) helper for operations on the tree.
  Any changes to [`placeholder`](./../gdscript/rlink#placeholder-object)
  directly won't be included in editor history
- Can be slow. Set plugin's [max depth](./plugin_settings.html#copy-max-depth)
  or [local settings](./local_settings)
- Support for turning `Callable` with already bound arguments and unbind is very
  spotchy. Pass unmodified `Callable` to [`RLinkButton`](./../gdscript/rlink_button)
  and use its methods to bind values and unbind
- C#: Can't bind variable directly to `Callable`. It is still possible through
  `GodotHelper.Callable`, see `editot_csharp/csharp_scripts/ToolTestingCallable.cs`,
  prefer to use [`RLinkButtonCS`](./../csharp/RLinkButtonCS)
- C#: Callables created through `Callable.From` will cause assembly unload
  error, prefer to use [`RLinkButtonCS`](./../csharp/RLinkButtonCS)
- C#: Can't create `Callable` to static methods, prefer to use
  [`RLinkButtonCS`](./../csharp/RLinkButtonCS)

### Version Limitations

#### 4.1

- `get_argument_count` doesn't exist, so [`RLink`](./../gdscript/rlink) will
  always be passed to `Callable` with bound arguments or unbind. Add `unbind(1)`
  to ignore it
- C#: Can't export `Callable`. Only `_Get` is supported for `Callable`, see
  `editot_csharp/csharp_scripts/ToolTestingCallable.cs`, prefer to use
  [`RLinkButtonCS`](./../csharp/RLinkButtonCS)

#### 4.2

- `get_argument_count` doesn't exist, so [`RLink`](./../gdscript/rlink) will
  always be passed to `Callable` with bound arguments or unbind. Add `unbind(1)`
  to ignore it
