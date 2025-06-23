# ValidRLink

**ValidRLink** is a Godot plugin that supports 4.1+ version.
Adds ability to validate exported values and workable non-tool buttons.
Everything is workable in a non-tool class

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

### Add Button

```gdscript
@export var hello_world := RLinkButton.new(hello_world_impl)
func hello_world_impl() -> void:
    print("Hello World")
```

## License

[MIT](https://github.com/NoctemCat/ValidRLink/blob/main/LICENSE)

Copyright (c) 2025 NoctemCat