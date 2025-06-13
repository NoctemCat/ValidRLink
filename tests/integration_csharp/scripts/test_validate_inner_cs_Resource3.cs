
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_validate_inner_cs_Resource3 : Resource
{
    [Export] public int IntVar { get; set; }

    public void ValidateChanges()
    {
        IntVar = 300;
    }
}