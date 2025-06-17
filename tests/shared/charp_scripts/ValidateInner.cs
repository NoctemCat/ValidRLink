#nullable enable
using Godot;
using System;

namespace ValidRLink;


public partial class ValidateInner : Node
{
    [Export] public InnerResource? Inner { get; set; }

    public void ValidateChanges()
    {
        Inner ??= new();

        foreach (var value in InnerResource.GetValues())
        {
            Inner.Set($"Export{value.VariantType}", value);
        }
    }
}
