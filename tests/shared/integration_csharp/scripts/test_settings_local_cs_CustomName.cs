
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_local_cs_CustomName : Node
{
    [Export] public int IntVar { get; set; }

    public void ValidateCustomName()
    {
        IntVar = 200;
    }

    static public RLinkSettingsCS GetRLinkSettings()
    {
        // MethodName.GetRLinkSettings;
        return new RLinkSettingsCS().SetValidateName("ValidateCustomName");
    }
}