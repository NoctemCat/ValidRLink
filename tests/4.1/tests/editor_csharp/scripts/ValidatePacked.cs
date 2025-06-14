using Godot;
using System;

namespace ValidRLink;

public partial class ValidatePacked : Node
{
    [Export] public int[] PackedArray { get; set; }

    public void ValidateChanges()
    {
        PackedArray = new int[5];
        PackedArray[0] = 100;
    }
}
