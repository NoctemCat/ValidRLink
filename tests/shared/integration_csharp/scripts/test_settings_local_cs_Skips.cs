#nullable enable
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_local_cs_Skips : Node
{
    [Export] public test_settings_local_cs_Inner? Inner { get; set; }
    [Export] public test_settings_local_cs_Inner? InnerMeta { get; set; }
    [Export] public test_settings_local_cs_InnerSkip? InnerSkip { get; set; }
    [Export] public int IntVar { get; set; } = 0;

    public void ValidateChanges()
    {
        Inner!.InnerVar = 110;
        if (InnerMeta is null) IntVar += 120;
        if (InnerSkip is null) IntVar += 100;
    }
}