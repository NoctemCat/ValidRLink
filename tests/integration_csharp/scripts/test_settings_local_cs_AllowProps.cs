#nullable enable
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_local_cs_AllowProps : Node
{
    [Export] public int IntVar { get; set; }
    [Export] public float FloatVar { get; set; }
    [Export] public test_settings_local_cs_Inner? Inner { get; set; }

    public void ValidateChanges()
    {
        Inner!.InnerVar = 250;
        IntVar = 100;
        FloatVar = 200.0f;
    }

    static public RLinkSettingsCS GetRLinkSettings()
    {
        return new RLinkSettingsCS().SetAllowedProperties(["Inner", "FloatVar"]);
    }
}