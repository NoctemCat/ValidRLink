using Godot;
using Godot.Collections;
using System;

namespace ValidRLink;

// ## from https://github.com/godotengine/godot/pull/96290#issuecomment-2379003323
[Tool]
public partial class ToolTesting : Sprite2D
{
    [Export] public int First { get; set; } = 123;

    [Export] public RLinkButtonCS HiddenAction { get; set; } = new RLinkButtonCS(nameof(TestHidden)).SetText("Hidden");
    [Export] public RLinkButtonCS StopAction { get; set; } = new RLinkButtonCS(nameof(TestDisabled)).SetText("Disabled").SetIcon("Stop");
    [Export] public RLinkButtonCS UndoRedoAction { get; set; } = new RLinkButtonCS(nameof(TestUndoRedo)).SetText("UndoRedo").SetIcon("UndoRedo");

    [Export] public RLinkButtonCS MakeGreenAction { get; set; } = new RLinkButtonCS("SetSelfModulate").SetText("Make Green").Bind(Colors.Green);
    [Export] public RLinkButtonCS ClearModulationAction { get; set; }

    [Export] public int Last { get; set; } = 42;

    public ToolTesting()
    {
        ClearModulationAction = new RLinkButtonCS((Color color) => SelfModulate = color)
            .SetText("Clear Modulation")
            .SetIcon("Clear")
            .Bind(Colors.White);
    }

#if GODOT4_2_OR_GREATER
    public override void _ValidateProperty(Dictionary property)
    {
        if (property["name"].AsStringName() == PropertyName.HiddenAction) // hide the test button
        {
            var usage = property["usage"].As<PropertyUsageFlags>() & ~PropertyUsageFlags.Editor;
            property["usage"] = (long)usage;
        }
        if (property["name"].AsStringName() == PropertyName.StopAction)
        {
            var usage = property["usage"].As<PropertyUsageFlags>() | PropertyUsageFlags.ReadOnly;
            property["usage"] = (long)usage;
        }
    }
#endif

    public override Array<Dictionary> _GetPropertyList()
    {
        Array<Dictionary> properties = new();
        for (int i = 0; i < 3; i++)
        {
            properties.Add(new()
            {
                {"name", $"cool_dynamic_tool_button_{i}"},
                {"type", (long)Variant.Type.Object},
                {"hint_string", "RLinkButtonCS"},
                {"usage", (long)PropertyUsageFlags.Editor},
            });
        }
        return properties;
    }

    public override Variant _Get(StringName property)
    {
        string propString = property.ToString();
        if (propString.StartsWith("cool_dynamic_tool_button_"))
        {
            string left = propString.TrimPrefix("cool_dynamic_tool_button_");
            return new RLinkButtonCS(TestDynamic).SetText($"Dynamic Button {left}").Bind(left);
        }
        return new();
    }

    public void TestHidden()
    {
        GD.Print("toot");
    }

    public void TestDisabled()
    {
        GD.Print("can't touch this");
    }

    public void TestUndoRedo()
    {
        GD.PrintS("undoredo");
    }

    public void TestDynamic(Variant what)
    {
        GD.PrintS("dynamic button", what.VariantType.ToString(), (long)what.VariantType, what);
    }
}
