


using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_meta_cs_RemoveMeta : Node
{
    public void ValidateChanges()
    {
        RemoveMeta("to_data1");
        RemoveMeta("to_data2");
        RemoveMeta("to_data_int1");
        RemoveMeta("to_data_int2");
    }
}