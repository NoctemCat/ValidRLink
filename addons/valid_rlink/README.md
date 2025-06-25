# ValidRLink

**ValidRLink** is a Godot plugin that supports 4.1+ version.
Everything is workable in a non-tool class.

If it detects any changes in inspector it will call your own method where 
you can check exported values or set them, you can change the method name in settings.

You can also export buttons that will call your methods, similar to 
`@export_tool_button` only your classes doesn't need to be `@tool`

By the nature of how it works, it will only work with exported data, while 
inside your methods the instance doesn't have any children or parents and 
it's not in the tree. To work with the scene your method can accept helper 
class [`RLink`](https://noctemcat.github.io/ValidRLink/usage/#working-with-scene), 
which provides common operations on the tree

## Documentation

More detailed info on [Docs](https://noctemcat.github.io/ValidRLink/) 
or you can open `tests/version/tests/editor` and 
`tests/version/tests/editor_csharp` for usage in editor

## How to Use

### Validate Data

```gdscript
@export var int_var: int

func validate_changes() -> void:
    if int_var < 0: int_var = 0
    elif int_var > 100: int_var = 100
```

### Add Buttons

```gdscript
@export var hello_world := RLinkButton.new(hello_world_impl)
func hello_world_impl() -> void:
    print("Hello World")
```

## License

[MIT](https://github.com/NoctemCat/ValidRLink/blob/main/LICENSE)

Copyright (c) 2025 NoctemCat