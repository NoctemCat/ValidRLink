---
title: ValidRLink Docs | RLinkButton
description: Documentation for RLinkButton
outline: [2, 4]
---

# RLinkButton

Turns a method from non-tool class into a button in editor

```gdscript
@export var hello_world := RLinkButton.new(hello_world_impl)
func hello_world_impl() -> void:
    print("Hello World")
```

## Properties

### text: `String`

The button's text that will be displayed inside the button's area

---

### tooltip_text: `String`

Sets `Control.tooltip_text`

---

### icon: `String`

Sets editor icon by name, setting it unsets [`icon_texture`](#icon-texture-texture2d)

---

### icon_texture: `Texture2D`

Sets texture as icon, unsets [`icon`](#icon-string)

---

### icon_alignment: `HorizontalAlignment`

Icon behavior for `Button.icon_alignment`

---

### icon_alignment_vertical: `VerticalAlignment`

Icon behavior for `Button.vertical_icon_alignment`

---

### modulate: `Color`

Sets `CanvasItem.modulate` on button

---

### max_width: `int`

Sets maximum width, can be shrunk

---

### min_height: `int`

Sets minimum height, can't be shrunk

---

### margin_left: `int`

Sets left margin

---

### margin_top: `int`

Sets top margin

---

### margin_right: `int`

Sets right margin

---

### margin_bottom: `int`

Sets bottom margin

---

### disabled: `bool`

Sets `BaseButton.disabled` on the button

---

### clip_text: `bool`

Sets `Button.clip_text` on the button

---

### size_flags: `ControlSizes`

If size is less than max width the flag is always `SIZE_FILL`, else it's
`SIZE_SHRINK_CENTER`. This allows to override the flag to other when the size
of container is more than its max width

---

### bound_args: `Array`

The args that will be passed to method using Callable rules

---

### unbind_next: `int`

Unbind next args using normal Callable rules

---

### callable_method_name: `StringName`

Method that will be called

## Methods

### Constructor

`method` can be either `Callable` or method name as a `String`. Doesn't
support lambdas. Optionally can accept properties as dictionary
::: info Information
When method is string it can't be called until [`set_object`](#set-object)
was called
:::

```gdscript
func _init(method: Variant = null, properties: Dictionary = Dictionary()) -> void
```

---

### set_object()

Sets object and, optionally, method to prepare it for calling

```gdscript
func set_object(object: Object, method: StringName = "") -> RLinkButton
```

---

### rlink_call()

Calls stored method without waiting

```gdscript
func rlink_call(arg: Variant = null) -> Variant
```

---

### rlink_callv()

Calls stored method without waiting

```gdscript
func rlink_callv(args: Array) -> Variant
```

---

### rlink_call_await()

Calls stored method with waiting

```gdscript
func rlink_call_await(arg: Variant = null) -> Variant
```

---

### rlink_callv_await()

Calls stored method with waiting

```gdscript
func rlink_callv_await(args: Array) -> Variant
```

---

### bind()

Adds argument that method will be called with and returns
current instance

```gdscript
func bind(arg: Variant) -> RLinkButton
```

---

### bindv()

Adds arguments that method will be called with and returns
current instance

```gdscript
func bindv(args: Array) -> RLinkButton
```

---

### unbind()

Next arguments passed to bind or call will be ignored and returns
current instance

```gdscript
func unbind(argcount: int) -> RLinkButton
```

---

### get_arg_count()

Returns calculated argument count

```gdscript
func get_arg_count() -> int
```

---

### get_method_name()

Returns method that will be called

```gdscript
func get_method_name() -> StringName
```

---

### set_dictioanary()

Sets exported properties by name from dictionary
and returns current instance

```gdscript
func set_dictioanary(properties: Dictionary) -> RLinkButton
```

---

### set_text()

Sets [`text`](#text-string) and returns current instance

```gdscript
func set_text(in_text: String) -> RLinkButton
```

---

### set_tooltip_text()

Sets [`tooltip_text`](#tooltip-text-string) and returns current instance

```gdscript
func set_tooltip_text(in_text: String) -> RLinkButton
```

---

### set_icon()

Sets [`icon`](#icon-string) and returns current instance

```gdscript
func set_icon(in_icon: String) -> RLinkButton
```

---

### set_icon_texture()

Sets [`icon_texture`](#icon-texture-texture2d) and returns current instance

```gdscript
func set_icon_texture(in_icon: Texture2D) -> RLinkButton
```

---

### set_icon_alignment()

Sets [`icon_alignment`](#icon-alignment-horizontalalignment) and returns current instance

```gdscript
func set_icon_alignment(alignment: HorizontalAlignment) -> RLinkButton
```

---

### set_icon_alignment_vertical()

Sets [`icon_alignment_vertical`](#icon-alignment-vertical-verticalalignment) and returns current instance

```gdscript
func set_icon_alignment_vertical(alignment: HorizontalAlignment) -> RLinkButton
```

---

### set_modulate()

Sets [`modulate`](#modulate-color) and returns current instance

```gdscript
func set_modulate(color: Color) -> RLinkButton
```

---

### set_max_width()

Sets [`max_width`](#max-width-int) and returns current instance

```gdscript
func set_max_width(width: int) -> RLinkButton
```

---

### set_min_height()

Sets [`min_height`](#min-height-int) and returns current instance

```gdscript
func set_min_height(height: int) -> RLinkButton
```

---

### set_margin_left()

Sets [`margin_left`](#margin-left-int) and returns current instance

```gdscript
func set_margin_left(margin: int) -> RLinkButton
```

---

### set_margin_top()

Sets [`margin_top`](#margin-top-int) and returns current instance

```gdscript
func set_margin_top(margin: int) -> RLinkButton
```

---

### set_margin_right()

Sets [`margin_right`](#margin-right-int) and returns current instance

```gdscript
func set_margin_right(margin: int) -> RLinkButton
```

---

### set_margin_bottom()

Sets [`margin_bottom`](#margin-bottom-int) and returns current instance

```gdscript
func set_margin_bottom(margin: int) -> RLinkButton
```

---

### set_disabled()

Sets [`disabled`](#disabled-bool) and returns current instance

```gdscript
func set_disabled(in_disabled: bool = true) -> RLinkButton
```

---

### set_size_flags()

Sets [`size_flags`](#size-flags-controlsizes) and returns current instance

```gdscript
func set_size_flags(in_size_flags: ControlSizes) -> RLinkButton
```

---

### set_size_flags_control()

Sets [`size_flags`](#size-flags-controlsizes) and returns current instance

```gdscript
func set_size_flags_control(in_size_flags: Control.SizeFlags) -> RLinkButton
```

---

### toggle_disabled()

Toggles [`disabled`](#disabled-bool) and returns current instance

```gdscript
func toggle_disabled() -> RLinkButton
```

---

### set_current_as_default()

Stores current exported properties as default

```gdscript
func set_current_as_default() -> void
```

---

### restore_default()

Sets exported properties to stored defaults

```gdscript
func restore_default() -> void
```

## Enums

### enum ControlSizes

Sizes from `Control` with added unset

- **SIZE_UNSET** = -1
- **SIZE_SHRINK_BEGIN** = 0
- **SIZE_FILL** = 1
- **SIZE_EXPAND** = 2
- **SIZE_EXPAND_FILL** = 3
- **SIZE_SHRINK_CENTER** = 4
- **SIZE_SHRINK_END** = 8
