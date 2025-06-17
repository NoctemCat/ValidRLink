#nullable enable
using Godot;
using System;

namespace ValidRLink;

public partial class ValidateBase : Node
{
    [Export] public int IntVar { get; set; }

    public bool ValidateChanges()
    {
        IntVar = 200;
        if (Get("FloatVar").VariantType != Variant.Type.Nil)
        {
            Set("FloatVar", 55.5);
        }
        return true;
    }
}
