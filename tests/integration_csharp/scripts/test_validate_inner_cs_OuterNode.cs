#nullable enable
using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_validate_inner_cs_OuterNode : Node
{
    [Export] public test_validate_inner_cs_Resource1? Inner1 { get; set; }
    [Export] public test_validate_inner_cs_Resource1? Inner2 { get; set; }
    [Export] public test_validate_inner_cs_Resource1? Inner3 { get; set; }

    [System.Diagnostics.CodeAnalysis.SuppressMessage("CodeQuality", "IDE0079:Remove unnecessary suppression", Justification = "Complains without it")]
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Performance", "CA1822:Mark members as static", Justification = "Needs to be instance")]
    public void ValidateChanges() { }
}