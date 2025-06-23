---
title: How it works?
description: How it works?
outline: [2, 4]
---

# How it works?

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
