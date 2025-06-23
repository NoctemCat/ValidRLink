---
title: Limitations
description: Limitations
outline: [2, 4]
---

# Limitations

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

## Version Limitations

### 4.1

- `get_argument_count` doesn't exist, so [`RLink`](./../gdscript/rlink) will
  always be passed to `Callable` with bound arguments or unbind. Add `unbind(1)`
  to ignore it
- C#: Can't export `Callable`. Only `_Get` is supported for `Callable`, see
  `editot_csharp/csharp_scripts/ToolTestingCallable.cs`, prefer to use
  [`RLinkButtonCS`](./../csharp/RLinkButtonCS)

### 4.2

- `get_argument_count` doesn't exist, so [`RLink`](./../gdscript/rlink) will
  always be passed to `Callable` with bound arguments or unbind. Add `unbind(1)`
  to ignore it
