
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_cs_Inner : Resource
{
    [Export] public int IntVar { get; set; }
    [Export] public Resource Inner { get; set; }
}