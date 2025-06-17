using Godot;
using Godot.Collections;
using System;

namespace ValidRLink;

// ## from https://github.com/godotengine/godot/pull/96290#issuecomment-2379003323
[Tool]
[System.Diagnostics.CodeAnalysis.SuppressMessage("Performance", "CA1822:Mark members as static", Justification = "Callables get created from instance methods")]
public partial class ToolTestingCallable : Sprite2D
{
    [Export] public int First { get; set; } = 123;

#if GODOT4_2_OR_GREATER && TOOLS
    [Export] public Callable HiddenAction { get; set; }
    [Export] public Callable StopAction { get; set; }
    [Export] public Callable UndoRedoAction { get; set; }


    // [Export] public Callable MakeGreenAction { get; set; }
    // [Export] public Callable ClearModulationAction { get; set; }

    [Export] public int Last { get; set; } = 42;

    public ToolTestingCallable()
    {
        HiddenAction = new(this, MethodName.TestHidden);
        StopAction = new(this, MethodName.TestDisabled);
        UndoRedoAction = new(this, MethodName.TestUndoRedo);
    }
#endif

#if GODOT4_2_OR_GREATER && TOOLS
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
        Array<Dictionary> properties = new()
        {
            new()
            {
                {"name", $"MakeGreenAction"},
                {"type", (long)Variant.Type.Callable},
                {"usage", (long)PropertyUsageFlags.Editor},
            },
            new()
            {
                {"name", $"ClearModulationAction"},
                {"type", (long)Variant.Type.Callable},
                {"usage", (long)PropertyUsageFlags.Editor},
            }
        };

        for (int i = 0; i < 3; i++)
        {
            properties.Add(new()
            {
                {"name", $"cool_dynamic_tool_button_{i}"},
                {"type", (long)Variant.Type.Callable},
                {"usage", (long)PropertyUsageFlags.Editor},
            });
        }
        return properties;
    }

    public override Variant _Get(StringName property)
    {
        string propString = property.ToString();
        if (propString == "MakeGreenAction")
        {
            Variant callable = new Callable(this, CanvasItem.MethodName.SetSelfModulate);
            callable = GodotHelper.Callable.Bind(callable, Colors.Green);
            CompatUnbind(ref callable);
            return callable;
        }
        if (propString == "ClearModulationAction")
        {
            Variant callable = new Callable(this, CanvasItem.MethodName.SetSelfModulate);
            callable = GodotHelper.Callable.Bind(callable, Colors.White);
            CompatUnbind(ref callable);
            return callable;
        }
        if (propString.StartsWith("cool_dynamic_tool_button_"))
        {
            Variant btn = new Callable(this, MethodName.TestDynamic);
            btn = GodotHelper.Callable.Bind(btn, propString.TrimPrefix("cool_dynamic_tool_button_"));
            CompatUnbind(ref btn);
            return btn;
        }
        return new();
    }

    private static void CompatUnbind(ref Variant variant)
    {
        // `get_argument_count` doesn't exist, so the  
        // helper will be always passed, ignore it
        if (Engine.GetVersionInfo()["hex"].AsInt64() < 0x040300)
        {
            variant = GodotHelper.Callable.Unbind(variant, 1);
        }
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
