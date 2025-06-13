#nullable enable
using Godot;
using System;
using ValidRLink;

public partial class RLinkChanges : Node
{
    [Export] public NoiseTexture2D? NoiseTexture { get; set; }
    [Export] public RLinkButtonCS SetNoise = new(nameof(SetNoiseImpl));
    [Export] public RLinkButtonCS SetNoiseProperty = new(nameof(SetNoisePropertyImpl));

    public void ValidateChanges()
    {
        NoiseTexture ??= new();
    }

    public bool SetNoiseImpl(RLinkCS rlink)
    {
        if (NoiseTexture is null) return true;

        if (NoiseTexture.Noise is null)
        {
            Noise noise = new FastNoiseLite();
            rlink.AddChanges(NoiseTexture, NoiseTexture2D.PropertyName.Noise, null, noise);
        }
        else
        {
            rlink.AddChanges(NoiseTexture, NoiseTexture2D.PropertyName.Noise, NoiseTexture.Noise, null);
        }

        return true;
    }

    public bool SetNoisePropertyImpl(RLinkCS rlink)
    {
        if (NoiseTexture is null) return true;
        if (NoiseTexture.Noise is null) return true;

        if (((FastNoiseLite)NoiseTexture.Noise).Seed == 0)
        {
            rlink.AddDoMethod(NoiseTexture.Noise, FastNoiseLite.MethodName.SetSeed, new Godot.Collections.Array { 1234 });
            rlink.AddUndoMethod(NoiseTexture.Noise, FastNoiseLite.MethodName.SetSeed, new Godot.Collections.Array { 0 });
        }
        else
        {
            rlink.AddDoMethod(NoiseTexture.Noise, FastNoiseLite.MethodName.SetSeed, new Godot.Collections.Array { 0 });
            rlink.AddUndoMethod(NoiseTexture.Noise, FastNoiseLite.MethodName.SetSeed, new Godot.Collections.Array { 1234 });
        }

        return true;
    }
}
