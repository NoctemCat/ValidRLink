#nullable enable
using System;
using System.Collections.Generic;
using Godot;

namespace ValidRLink;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_settings_cs_MaxDepth : Node
{
    [Export] public test_settings_cs_Inner? Inner { get; set; }
    [Export] public int IntVar { get; set; }

    public void ValidateChanges()
    {
        Resource? temp = Inner;
        while (temp is not null)
        {
            IntVar += 1;
            temp = temp.Get("Inner").As<Resource?>();
        }
    }
}