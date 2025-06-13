
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_discard_cs_ErrorDiscard : Node
{
    [Export] public int IntVar { get; set; }
    [Export] public Callable CallableBoolVar { get => new(this, MethodName.CallableDiscardBool); set { } }
    [Export] public Callable CallableVar { get => new(this, MethodName.CallableDiscard); set { } }
    [Export] public RLinkButtonCS ButtonBool { get; set; } = new(nameof(ButtonDiscardBool));
    [Export] public RLinkButtonCS Button { get; set; } = new(nameof(ButtonDiscard));
    [Export] public RLinkButtonCS ButtonSet { get; set; } = new(nameof(ButtonSetImpl));


    public bool ValidateChanges()
    {
        IntVar = 200;
        return false;
    }

    public bool CallableDiscardBool()
    {
        IntVar = 201;
        return false;
    }

    public Variant CallableDiscard()
    {
        IntVar = 202;
        return new();
    }

    public bool ButtonDiscardBool()
    {
        IntVar = 203;
        return false;
    }

    public Variant ButtonDiscard()
    {
        IntVar = 204;
        return new();
    }

    public Variant ButtonSetImpl()
    {
        IntVar = 205;
        return true;
    }
}
