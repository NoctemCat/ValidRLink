
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_local_cs_MaxDepth : Node
{
    [Export] public test_settings_local_cs_Inner Inner { get; set; }
    [Export] public int IntVar { get; set; }

    public void ValidateChanges()
    {
        if (Inner is null) IntVar = 200;
        else IntVar = 150;
    }

    static public RLinkSettingsCS GetRLinkSettings()
    {
        return new RLinkSettingsCS().SetMaxDepth(1);
    }
}