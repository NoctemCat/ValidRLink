using Godot;
using System;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_basic_exports_cs_OuterNode : BasicNode
{
    [Export] public test_basic_exports_cs_BasicExports Res { get; set; }
    [Export] public string SomeVar { get; set; }

    public void ValidateChanges()
    {
        foreach (var value in GetValues())
        {
            Res.Set($"Export{value.VariantType}", value);
            Res.Set($"Normal{value.VariantType}", value);
        }
        SomeVar = "after validate";
    }
}
