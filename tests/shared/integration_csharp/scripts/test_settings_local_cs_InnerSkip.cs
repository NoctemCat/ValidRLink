

using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_local_cs_InnerSkip : Resource
{
    [Export] public int InnerVar { get; set; }

    public static RLinkSettingsCS GetRLinkSettings()
    {
        return new RLinkSettingsCS().SetSkip(true);
    }
}