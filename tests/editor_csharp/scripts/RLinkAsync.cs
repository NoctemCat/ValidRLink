using Godot;
using System;
using System.Threading;
using System.Threading.Tasks;
using ValidRLink;

public partial class RLinkAsync : Node
{
    [Export] public int IntVar { get; set; } 
    [Export] public RLinkButtonCS SetInt = new RLinkButtonCS(nameof(SetIntAsync)).Unbind(1);
    [Export] public bool Success { get; set; }
    [Export] public RLinkButtonCS SetIntChecked = new(nameof(SetIntCheckedAsync));

    public async Task SetIntAsync(RLinkCS rlink)
    {
        IntVar -= 1;
        GD.Print("Before timer");
        await ToSignal(rlink.GetTree().CreateTimer(2), SceneTreeTimer.SignalName.Timeout);
        IntVar -= 1;
        GD.Print("After timer");
    }

    public async Task<bool> SetIntCheckedAsync(RLinkCS _, CancellationToken token)
    {
        IntVar += 1;
        GD.Print("Before delay"); 
        await Task.Delay(4000, token); 
        IntVar += 1;
        GD.Print("After delay");
        return Success;
    }
}
