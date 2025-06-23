---
title: ValidRLink Docs | Basic Usage
description: Basic Usage
outline: [2, 4]
---

# Basic Usage

This plugin will only copy exported values, node's name, node's
groups and metadata directly. To add nodes see [working with Scene](#working-with-scene)

## Validation

Create a method with the name:

- `validate_changes`
- `_validate_changes`
- `ValidateChanges`
- `_ValidateChanges`

The names can be customised in [plugin settings](./plugin_settings#validate-changes)
or [local settings](./local_settings)

## Buttons

Export [`RLinkButton`](./../gdscript/rlink_button) in `GDScript` or
[`RLinkButtonCS`](./../csharp/RLinkButtonCS) in `C#`. To set default
values you can set the button in `_init` or use builder pattern

::: code-group

```gdscript [init_node.gd]
@export var clear_modulation_action: RLinkButton

func _init() -> void:
    clear_modulation_action = RLinkButton.new(set_self_modulate)
    clear_modulation_action.text = "Clear Modulation"
    clear_modulation_action.icon = "Clear"
    clear_modulation_action.bind(Color.WHITE)
```

```gdscript [builder_node.gd]
@export var clear_modulation_action := RLinkButton.new(set_self_modulate) \
    .set_text("Clear Modulation") \
    .set_icon("Clear") \
    .bind(Color.WHITE)

```

```csharp [InitNode.cs]
[Export] public RLinkButtonCS ClearModulationAction { get; set; }

public InitNode()
{
    ClearModulationAction = new RLinkButtonCS(SetSelfModulate)
    ClearModulationAction.Text = "Clear Modulation";
    ClearModulationAction.Icon = "Clear";
    ClearModulationAction.Bind(Colors.White);
}
```

```csharp [BuilderNode.cs]
[Export] public RLinkButtonCS ClearModulationAction { get; set; } = new RLinkButtonCS(nameof(SetSelfModulate))
      .SetText("Clear Modulation")
      .SetIcon("Clear")
      .Bind(Colors.White);
```

:::

You can change the buttons state from inside methods. You can also
use context menu to edit them:

- `Edit` will open them in `Inspector` for editing
- `Set Current as Default` will store the current values as default,
  `Reset` after this will restore the values to stored now
- `Reset` will reset them to their stored default values
- `Clear` will set it to `null` allowing `_init` and builder to run
  again

## Checked Call

If you add `return true` to a method, and make return type empty,
`-> bool` or `-> Variant` it will turn the method into checked call.
After calling the result will be compared with `true` and discard
changes if the result doesn't match it. This allows for basic error
checking, on error it will return `null`, or to return `false`
yourself and discard all changes

## Async Call

Support for async was implemented, but was only briefly tested.
Each object can process only one async call at a time, so it will
disable other buttons and delay calls to validate method, which will
be called right after async call is finished.
In C# it will also pass `CancellationToken` that will be cancelled
on assembly reload, add `Unbind(1)` if you want to ignore it

## Working With Scene

To work with the `SceneTree` you can add parameter with the type
[`RLink`](./../gdscript/rlink), after this the plugin will pass it
to method

### Adding Node

::: code-group

```gdscript [toggle_child.gd]
@export var toggle_child_path := RLinkButton.new(toggle_child_path_impl)

func toggle_child_path_impl(rlink: RLink) -> void:
    if rlink.has_node("DirectChild/ChildPath"):
        rlink.remove_child_path("DirectChild/ChildPath")
    else:
        rlink.add_child_path("DirectChild/ChildPath", Node.new())
```

```csharp [ToggleChild.cs]
[Export] public RLinkButtonCS ToggleChildPath = new(nameof(ToggleChildPathImpl));

public void ToggleChildPathImpl(RLinkCS rlink)
{
    if (rlink.HasNode("DirectChild/ChildPath"))
        rlink.RemoveChildPath("DirectChild/ChildPath");
    else
        rlink.AddChildPath("DirectChild/ChildPath", new Node());
}
```

:::

### Adding Scene and Connecting Signal

::: code-group

```gdscript [scene.gd]
@export var scene: PackedScene
@export var scene_load: SimpleScene
@export var toggle_connect := RLinkButton.new(toggle_connect_impl)

func validate_changes(rlink: RLink) -> bool:
    if scene == null: return true

    if scene_load == null:
        scene_load = rlink.instantiate_packed(scene)
        rlink.add_child_path("SceneLoad", scene_load)

func toggle_connect_impl(rlink: RLink) -> void:
    if scene_load == null: return

    if not rlink.signal_is_connected(scene_load.custom_pressed, scene_pressed):
        rlink.signal_connect(scene_load.custom_pressed, scene_pressed, ["hello scene_load"])
    else:
        rlink.signal_disconnect(scene_load.custom_pressed, scene_pressed)

func scene_pressed(text: String) -> void:
    print("scene_pressed %s" % text)
```

```csharp [Scene.cs]
[Export] public PackedScene? Scene { get; set; }
[Export] public SimpleScene? SceneLoad { get; set; }
[Export] public RLinkButtonCS ToggleConnect = new(nameof(ToggleConnectImpl));

public bool ValidateChanges(RLinkCS rlink)
{
    if (Scene is null) return true;
    if (SceneLoad is null)
    {
        SceneLoad = rlink.InstantiatePacked<SimpleScene>(Scene);
        rlink.AddChildPath("SceneLoad", SceneLoad);
    }
    return true;
}

public void ToggleConnectImpl(RLinkCS rlink)
{
    if (SceneLoad is null) return;

    Signal customPressed = SceneLoad.Get(SimpleScene.SignalName.CustomPressed).AsSignal();
    if (!rlink.SignalIsConnected(customPressed, ScenePressed))
        rlink.SignalConnect(customPressed, ScenePressed, new Godot.Collections.Array { "hello SceneLoad C#" });
    else
        rlink.SignalDisconnect(customPressed, ScenePressed);
}

public void ScenePressed(string text)
{
    GD.Print($"ScenePressed {text}");
}
```

:::
