

using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_callables_cs_Callables : Node
{
    [Export] public int IntVar { get; set; }
    [Export] public RLinkButtonCS Button { get; set; } = new(nameof(FromButton));
    // [Export] public RLinkButtonCS CallableVar { get => new(this, MethodName.FromCallable); set { } }
    [Export] public Callable CallableVar { get => new(this, MethodName.FromCallable); set { } }

    public void FromButton()
    {
        IntVar = 50;
    }

    public void FromCallable()
    {
        IntVar = 100;
    }
}
