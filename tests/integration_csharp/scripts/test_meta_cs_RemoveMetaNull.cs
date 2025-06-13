


using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_meta_cs_RemoveMetaNull : Node
{
    public void ValidateChanges()
    {
        SetMeta("to_data1", new Variant());
        SetMeta("to_data2", new Variant());
        SetMeta("to_data_int1", new Variant());
        SetMeta("to_data_int2", new Variant());
    }
}