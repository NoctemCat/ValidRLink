---
title: Introduction
description: Introduction
outline: [2, 4]
---

# Introduction

**ValidRLink** is a Godot plugin that supports 4.1+ version

If it detects any changes in inspector it will call your own method where
you can check exported values or set them, you can change the method name in settings.

You can also export buttons that will call your methods, similar to
`@export_tool_button` only your classes doesn't need to be `@tool`

By the nature of how it works, it will only work with exported data, while
inside your methods the instance doesn't have any children or parents and
it's not in the tree. To work with the scene your method can accept helper
class [`RLink`](./usage/#working-with-scene),
which provides common operations on the tree

## Main Goals

### Validation of Changes

User can add a function that will be called when exported value
in inspector changes, even in a non-tool class

::: code-group

```gdscript [example.gd]
@export var int_var: int

func validate_changes() -> void:
    if int_var < 0: int_var = 0
    elif int_var > 100: int_var = 100
```

```csharp [Example.cs]
[Export] public int IntVar { get; set; }

public void ValidateChanges()
{
    if (IntVar < 0) { IntVar = 0; }
    else if (IntVar > 100) { IntVar = 100; }
}
```

:::

This function will be called when inspector updates exported variable.
The names can be changed in Plugin settings and local settings

### Runnable Buttons

As close as possible to `@export_tool_button` button, with the main
difference being that they could be called from non-tool class
using `ValidRLink` underlying system

### Optional C# support

As plugin, at first, tried to replicate Unity's `OnValidate`,
`C#` support was very important. Despite making it as seamless
as possible, the support is fully optional and this plugin
will work even in non-mono version
