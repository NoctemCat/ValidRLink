#nullable enable
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_cs_ExternalResource : Node
{
    [Export] public test_setting_resource_cs Res { get; set; } = null!;
    [Export] public int CopyInt { get; set; }

    public void ValidateChanges()
    {
        CopyInt = Res.IntVar;
        Res.IntVar = 500;
    }

}