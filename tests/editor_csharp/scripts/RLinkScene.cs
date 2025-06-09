#nullable enable
using Godot;
using System;

namespace ValidRLink;

[Tool, GlobalClass]
public partial class RLinkScene : Node
{
    [Export] public PackedScene? Scene { get; set; }
    [Export] public SimpleScene? SceneExport { get; set; }
    [Export] public SimpleScene? SceneLoad { get; set; }
    [Export] public SimpleScene? SceneFile { get; set; }
    [Export] public RLinkButtonCS RemoveAll = new(nameof(RemoveAllImpl));
    [Export] public RLinkButtonCS ToggleConnect = new(nameof(ToggleConnectImpl));


    public void ValidateChanges(RLinkCS rlink)
    {
        if (Scene is null) return;

        if (SceneExport is null)
        {
            SceneExport = rlink.ConvertToTool<SimpleScene>(Scene.Instantiate<Control>(PackedScene.GenEditState.Instance));
            rlink.AddChildPath("SceneExport", SceneExport);
        }

        if (SceneLoad is null)
        {
            SceneLoad = rlink.InstantiatePacked<SimpleScene>(Scene);
            rlink.AddChildPath("SceneLoad", SceneLoad);
        }

        if (SceneFile is null)
        {
            SceneFile = rlink.InstantiateFile<SimpleScene>("res://tests/editor_csharp/simple_scene.tscn");
            rlink.AddChildPath("SceneFile", SceneFile);
        }

        SceneLoad.Position = new(0, 50);
        SceneFile.Position = new(0, 100);
    }

    public void RemoveAllImpl(RLinkCS rlink)
    {
        rlink.RemoveAllChildren();
    }

    public void ToggleConnectImpl(RLinkCS rlink)
    {
        Signal customPressed = SceneExport!.Get(SimpleScene.SignalName.CustomPressed).AsSignal();
        if (rlink.SignalIsConnected(customPressed, ScenePressed))
            rlink.SignalDisconnect(customPressed, ScenePressed);
        else
            rlink.SignalConnect(customPressed, ScenePressed, ["hello SceneExport"]);

        customPressed = SceneLoad!.Get(SimpleScene.SignalName.CustomPressed).AsSignal();
        if (rlink.SignalIsConnected(customPressed, ScenePressed))
            rlink.SignalDisconnect(customPressed, ScenePressed);
        else
            rlink.SignalConnect(customPressed, ScenePressed, ["hello SceneLoad"]);

        customPressed = SceneFile!.Get(SimpleScene.SignalName.CustomPressed).AsSignal();
        rlink.SignalToggle(customPressed, ScenePressed, ["hello SceneFile"]);
    }

    public void ScenePressed(string text)
    {
        GD.Print($"ScenePressed {text}");
    }
}
