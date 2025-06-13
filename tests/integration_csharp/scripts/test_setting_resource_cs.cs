
using System;
using Godot;

namespace ValidRLink;


[GlobalClass]
[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_setting_resource_cs : Resource
{
    [Export] public int IntVar { get; set; }
    [Export] public float FloatVar { get; set; }
}
