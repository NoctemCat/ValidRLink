


using System;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_group_cs_RemoveGroup : Node
{

    public void ValidateChanges()
    {
        RemoveFromGroup("test");
        RemoveFromGroup("test_other");
    }
}