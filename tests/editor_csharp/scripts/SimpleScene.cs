using Godot;
using System;

namespace ValidRLink;

[Tool]
public partial class SimpleScene : Control
{
    [Signal] public delegate void CustomPressedEventHandler();

    private void OnButtonPressed()
    {
        EmitSignalCustomPressed();
    }
}
