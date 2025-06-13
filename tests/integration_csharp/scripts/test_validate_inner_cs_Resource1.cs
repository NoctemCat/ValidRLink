#nullable enable
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_validate_inner_cs_Resource1 : Resource
{
    [Export] public test_validate_inner_cs_Resource2? Inner1 { get; set; }
    [Export] public test_validate_inner_cs_Resource2? Inner2 { get; set; }
    [Export] public test_validate_inner_cs_Resource2? Inner3 { get; set; }
    [Export] public int IntVar { get; set; }

    public void ValidateChanges()
    {
        IntVar = 100;
    }
}