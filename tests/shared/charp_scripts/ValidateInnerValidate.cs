#nullable enable
using Godot;
using System;

namespace ValidRLink;

public partial class ValidateInnerValidate : Node
{
    [Export] public InnerResourceValidate? Inner { get; set; }

    public void ValidateChanges()
    {
        Inner ??= new();
    }
}
