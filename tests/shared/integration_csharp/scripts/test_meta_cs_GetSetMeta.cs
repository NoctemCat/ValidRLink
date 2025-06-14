


using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_meta_cs_GetSetMeta : Node
{
    public void ValidateChanges()
    {
        SetMeta("from_data1", GetMeta("to_data"));
        SetMeta("from_data2", GetMeta("to_data"));
        SetMeta("from_data3", GetMeta("to_data"));
        SetMeta("from_data_int1", GetMeta("to_data_int"));
        SetMeta("from_data_int2", GetMeta("to_data_int"));
        SetMeta("from_data_int3", GetMeta("to_data_int"));
    }
}