

using System;
using System.ComponentModel;
using System.Threading;
using System.Threading.Tasks;
using Godot;

namespace ValidRLink;


[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "For ease of getting connected test by name")]
public partial class test_callables_cs_CallablesAwait : Node
{
    [Export] public int IntVar { get; set; }
    [Export] public RLinkButtonCS Button { get; set; } = new RLinkButtonCS(nameof(FromButton)).Unbind(1);

    public async Task FromButton(RLinkCS rlink)
    {
        // Can't sync delay with GUT testing, but it delays it in editor,
        // so I'll assume it's working
        // await Task.Delay(250, token);
        await ToSignal(rlink.GetTree().CreateTimer(0.25), SceneTreeTimer.SignalName.Timeout);
        IntVar = 100;
        GD.Print(IntVar);
    }

    public void ValidateChanges()
    {
        IntVar = 200;
    }
}
