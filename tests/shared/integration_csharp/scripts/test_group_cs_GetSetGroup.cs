

using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_group_cs_GetSetGroup : Node
{
    public void ValidateChanges()
    {
        if (IsInGroup("test"))
            AddToGroup("inside_test");
        if (IsInGroup("test_other"))
            AddToGroup("inside_test_other");
    }
}