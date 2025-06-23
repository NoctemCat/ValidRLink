---
title: ValidRLink Docs | RLinkButton
description: Documentation for RLinkButton
outline: [2, 4]
---

# RLinkSettings

Turns a method from non-tool class into a button in editor.
Must be accessible from `obj.GetType().GetMethod(name)`

```csharp
[Export] public RLinkButtonCS HelloWorld = new(nameof(HelloWorldImpl));
public void HelloWorldImpl()
{
    GD.Print("Hello World");
}
```

## Properties

### Text: `string`

The button's text that will be displayed inside the button's area

---

### TooltipText: `string`

Sets `Control.TooltipText`

---

### Icon: `string`

Sets editor icon by name, setting it unsets [`IconTexture`](#icontexture-texture2d)

---

### IconTexture: `Texture2D`

Sets texture as icon, unsets [`Icon`](#icon-string)

---

### IconAlignment: `HorizontalAlignment`

Icon behavior for `Button.IconAlignment`

---

### IconAlignmentVertical: `VerticalAlignment`

Icon behavior for `Button.VerticalIconAlignment`

---

### Modulate: `Color`

Sets `CanvasItem.Modulate` on button

---

### MaxWidth: `int`

Sets maximum width, can be shrunk

---

### MinHeight: `int`

Sets minimum height, can't be shrunk

---

### MarginLeft: `int`

Sets left margin

---

### MarginTop: `int`

Sets top margin

---

### MarginRight: `int`

Sets right margin

---

### MarginBottom: `int`

Sets bottom margin

---

### Disabled: `bool`

Sets `BaseButton.Disabled` on the button

---

### ClipText: `bool`

Sets `Button.ClipText` on the button

---

### SizeFlags: `ControlSizes`

If size is less than max width the flag is always `SIZE_FILL`, else it's
`SIZE_SHRINK_CENTER`. This allows to override the flag to other when the size
of container is more than its max width

---

### BoundArgs: `Godot.Collections.Array`

The args that will be passed to method using Callable rules

---

### UnbindNext: `int`

Unbind next args using normal Callable rules

---

### CallableMethodName: `StringName`

Method that will be called

---

## Methods

### Constructor()

Required for `[Tool]` support, creates it without defaults

```csharp
public RLinkButtonCS();
```

---

### Constructor(Callable, Godot.Collections.Dictionary?)

Callable must be from method, tries to extract bound arguments and unbound if supported.
Optionally can accept properties as dictionary

```csharp
public RLinkButtonCS(Callable callable, Godot.Collections.Dictionary? properties = null);
```

---

### Constructor(CallGodotObject, StringName, Godot.Collections.Dictionary?)

Creates RLinkButtonCS for `method`. Optionally can accept properties as dictionary

```csharp
public RLinkButtonCS(GodotObject target, StringName method, Godot.Collections.Dictionary? properties = null);
```

---

### Constructor(StringName, Dictionary<StringName, Variant>?)

Sets method name, will retrieve method info when [`SetObject`](#setobject) is called.
Supports static methods from current type. Optionally can accept properties as dictionary

```csharp
public RLinkButtonCS(StringName method, Dictionary<StringName, Variant>? properties = null);
```

---

### Constructor(Delegate, Dictionary<StringName, Variant>?)

`Delegate` must be accessible from `obj.GetType().GetMethod(name)`.
Optionally can accept properties as dictionary
::: info
Can be created from lambda that only captures `this` in constructor

```csharp
ClearModulationAction = new RLinkButtonCS((Color color) => SelfModulate = color)
    .Bind(Colors.White);
```

:::

```csharp
public RLinkButtonCS(Delegate method, Dictionary<StringName, Variant>? properties = null);
```

---

### SetObject()

Sets object and, optionally, method to prepare it for calling.
If possible stores `MethodInfo` from `GetMethod`. If no `MethodInfo`
is found checks if it exist in `GDScript`

```csharp
public RLinkButtonCS SetObject(GodotObject obj, StringName? newMethod = null);
```

---

### RLinkCall()

Calls stored method without waiting. Tries to convert the result to Variant,
doesn't emit `Completed` signal

```csharp
public Variant RLinkCall();
public Variant RLinkCall(Variant arg);
```

---

### RLinkCallv()

Calls stored method without waiting. Tries to convert the result to Variant,
doesn't emit `Completed` signal

```csharp
public Variant RLinkCallv(Godot.Collections.Array args);
```

---

### RLinkCallAwait()

Begin task without waiting, and returns a `Signal` [`Completed`](#completed) that
will be emitted on task complition

```csharp
public Signal RLinkCallAwait();
public Signal RLinkCallAwait(Variant arg);
```

---

### RLinkCallvAwait()

Begin task without waiting, and returns a `Signal` [`Completed`](#completed) that
will be emitted on task complition

```csharp
public Signal RLinkCallvAwait(Godot.Collections.Array args);
```

---

### RLinkCallvAwaitTask()

Calls and awaits stored method. Gets result using reflection if exist. Emits
[`Completed`](#completed) signal with deferred on any result, if the result
is convertible to `Variant` it gets emitted with signal, if not `null` `Variant`
gets emitted instead

```csharp
public async Task RLinkCallvAwaitTask(Godot.Collections.Array args);
```

---

### CancelTask()

Communicates a request for cancellation to a running task if it exists

```csharp
public void CancelTask();
```

---

### Bind()

Adds argument that method will be called with and returns
current instance

```csharp
public RLinkButtonCS Bind(Variant arg);
```

---

### Bindv()

Adds arguments that method will be called with and returns
current instance

```csharp
public RLinkButtonCS Bindv(Godot.Collections.Array args);
public RLinkButtonCS Bindv(params Variant[] args);
```

---

### Unbind()

Next arguments passed to bind or call will be ignored and returns
current instance

```csharp
public RLinkButtonCS Unbind(int argCount);
```

---

### GetArgCount()

Returns calculated argument count

```csharp
public int GetArgCount();
```

---

### GetMethodName()

Returns method that will be called

```csharp
public StringName GetMethodName();
```

---

### SetDictionary()

Sets exported properties by name from dictionary
and returns current instance

```csharp
public RLinkButtonCS SetDictionary(Godot.Collections.Dictionary properties);
public RLinkButtonCS SetDictionary(IDictionary<StringName, Variant> properties)
```

---

### SetText()

Sets [`Text`](#text-string) and returns current instance

```csharp
public RLinkButtonCS SetText(string text);
```

---

### SetTooltipText()

Sets [`TooltipText`](#tooltiptext-string) and returns current instance

```csharp
public RLinkButtonCS SetTooltipText(string text);
```

---

### SetIcon()

Sets [`Icon`](#icon-string) and returns current instance

```csharp
public RLinkButtonCS SetIcon(string editorIcon);
```

---

### SetIconTexture()

Sets [`IconTexture`](#icontexture-texture2d) and returns current instance

```csharp
public RLinkButtonCS SetIconTexture(Texture2D icon);
```

---

### SetIconAlignment()

Sets [`IconAlignment`](#iconalignment-horizontalalignment) and returns current instance

```csharp
public RLinkButtonCS SetIconAlignment(HorizontalAlignment alignment);
```

---

### SetIconAlignmentVertical()

Sets [`IconAlignmentVertical`](#iconalignmentvertical-verticalalignment) and returns current instance

```csharp
public RLinkButtonCS SetIconAlignmentVertical(VerticalAlignment alignment)
```

---

### SetModulate()

Sets [`Modulate`](#modulate-color) and returns current instance

```csharp
public RLinkButtonCS SetModulate(Color color);
```

---

### SetMaxWidth()

Sets [`MaxWidth`](#maxwidth-int) and returns current instance

```csharp
public RLinkButtonCS SetMaxWidth(int width);
```

---

### SetMinHeight()

Sets [`MinHeight`](#minheight-int) and returns current instance

```csharp
public RLinkButtonCS SetMinHeight(int height);
```

---

### SetMarginLeft()

Sets [`MarginLeft`](#marginleft-int) and returns current instance

```csharp
public RLinkButtonCS SetMarginLeft(int margin);
```

---

### SetMarginTop()

Sets [`MarginTop`](#margintop-int) and returns current instance

```csharp
public RLinkButtonCS SetMarginTop(int margin);
```

---

### SetMarginRight()

Sets [`MarginRight`](#marginright-int) and returns current instance

```csharp
public RLinkButtonCS SetMarginRight(int margin);
```

---

### SetMarginBottom()

Sets [`MarginBottom`](#marginbottom-int) and returns current instance

```csharp
public RLinkButtonCS SetMarginBottom(int margin);
```

---

### SetDisabled()

Sets [`Disabled`](#disabled-bool) and returns current instance

```csharp
public RLinkButtonCS SetDisabled(bool disabled = true);
```

---

### SetSizeFlags()

Sets [`SizeFlags`](#sizeflags-controlsizes) and returns current instance

```csharp
public RLinkButtonCS SetSizeFlags(ControlSizes sizeFlags);
```

---

### SetSizeFlagsControl()

Sets [`SizeFlags`](#sizeflags-controlsizes) and returns current instance

```csharp
public RLinkButtonCS SetSizeFlagsControl(Control.SizeFlags sizeFlags);
```

---

### ToggleDisabled()

Toggles [`Disabled`](#disabled-bool) and returns current instance

```csharp
public RLinkButtonCS ToggleDisabled();
```

---

### SetCurrentAsDefault()

Stores current exported properties as default

```csharp
public void SetCurrentAsDefault();
```

---

### restore_default()

Sets exported properties to stored defaults

```csharp
public void RestoreDefault();
```

---

## Signals

### Completed

Fires after [`RLinkCallvAwaitTask`](#rlinkcallvawaittask). [`RLinkCallAwait`](#rlinkcallawait)
and [`RLinkCallvAwait`](#rlinkcallvawait) calls [`RLinkCallvAwaitTask`](#rlinkcallvawaittask)
and return this `Signal` without waiting

## Enums

### public enum ControlSizes

Sizes from `Control` with added unset

- **SizeUnset** = -1
- **SizeShrinkBegin** = 0
- **SizeFill** = 1
- **SizeExpand** = 2
- **SizeExpandFill** = 3
- **SizeShrinkCenter** = 4
- **SizeShrinkEnd** = 8
