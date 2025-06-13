#nullable enable
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_cs_CustomSettingsName : Node
{
    [Export] public int IntVar { get; set; }

    public void ValidateChanges()
    {
        IntVar = 100;
    }

    static public RLinkSettingsCS GetRLinkSettings() => new RLinkSettingsCS().SetSkip(true);
    static public RLinkSettingsCS GetRLinkSettingsCustom() => new RLinkSettingsCS().SetValidateName("no-name");
}