#nullable enable

using Godot;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using static ValidRLink.GodotHelper;

namespace ValidRLink;

/// <summary>
/// Specifies settings on a class level
/// </summary>
[Tool, GlobalClass]
[SuppressMessage("Style", "IDE0306:Simplify collection initialization", Justification = "Godot 4.1 support")]
[SuppressMessage("Style", "IDE0028:Simplify collection initialization", Justification = "Godot 4.1 support")]
public partial class RLinkSettingsCS : Resource
{
    /// <summary>
    /// If true, this class will never get duplicated
    /// </summary>
    [Export] public bool Skip { get; set; }
    /// <summary>
    /// Exported properties to skip by names
    /// </summary>
    [Export] public Godot.Collections.Array<StringName> SkipProperties { get; set; }
    /// <summary>
    /// If not empty, will only allow exported properties mentioned here
    /// </summary>
    [Export] public Godot.Collections.Array<StringName> AllowedProperties { get; set; }
    /// <summary>
    /// Specifies custom validate method name, if not found, doesn't search for default names
    /// </summary>
    [Export] public StringName ValidateName { get; set; }
    /// <summary>
    /// Custom maximum copy depth, recursively copies objects until max depth is reached
    /// </summary>
    [Export] public int MaxDepth { get; set; }

    public RLinkSettingsCS()
    {
        SkipProperties ??= new();
        AllowedProperties ??= new();
        ValidateName ??= new StringName();
        RLinkRefTracer.AddRefIfCreatedDirectly(this);
    }

    public RLinkSettingsCS(Godot.Collections.Dictionary dictionary)
    {
        Skip = GetDefault(dictionary, "skip", false).AsBool();
        SkipProperties = GetDefault(dictionary, "skip_properties", new Godot.Collections.Array<StringName>()).AsGodotArray<StringName>();
        AllowedProperties = GetDefault(dictionary, "allowed_properties", new Godot.Collections.Array<StringName>()).AsGodotArray<StringName>();
        ValidateName = GetDefault(dictionary, "validate_name", new StringName()).AsStringName();
        MaxDepth = GetDefault(dictionary, "max_depth", 0).AsInt32();
        RLinkRefTracer.AddRef(this);
    }

    public RLinkSettingsCS(Dictionary<Variant, Variant> dictionary)
    {
        Skip = GetDefault(dictionary, "skip", false).AsBool();
        SkipProperties = GetDefault(dictionary, "skip_properties", new Godot.Collections.Array<StringName>()).AsGodotArray<StringName>();
        AllowedProperties = GetDefault(dictionary, "allowed_properties", new Godot.Collections.Array<StringName>()).AsGodotArray<StringName>();
        ValidateName = GetDefault(dictionary, "validate_name", new StringName()).AsStringName();
        MaxDepth = GetDefault(dictionary, "max_depth", 0).AsInt32();
        RLinkRefTracer.AddRef(this);
    }

    /// <inheritdoc cref="Skip"/>
    public RLinkSettingsCS SetSkip(bool skip)
    {
        Skip = skip;
        return this;
    }

    /// <inheritdoc cref="SkipProperties"/>
    public RLinkSettingsCS SetSkipProperties(Godot.Collections.Array<StringName> properties)
    {
        SkipProperties = properties;
        return this;
    }


    /// <inheritdoc cref="SkipProperties"/>
    public RLinkSettingsCS SetSkipProperties(IEnumerable<StringName> properties)
    {
        SkipProperties = new(properties);
        return this;
    }

    /// <inheritdoc cref="SkipProperties"/>
    public RLinkSettingsCS AppendSkipProperties(StringName property)
    {
        SkipProperties.Add(property);
        return this;
    }

    /// <inheritdoc cref="AllowedProperties"/>
    public RLinkSettingsCS SetAllowedProperties(Godot.Collections.Array<StringName> properties)
    {
        AllowedProperties = properties;
        return this;
    }

    /// <inheritdoc cref="AllowedProperties"/>
    public RLinkSettingsCS SetAllowedProperties(IEnumerable<StringName> properties)
    {
        AllowedProperties = new(properties);
        return this;
    }

    /// <inheritdoc cref="AllowedProperties"/>
    public RLinkSettingsCS AppendAllowedProperties(StringName property)
    {
        AllowedProperties.Add(property);
        return this;
    }

    /// <inheritdoc cref="ValidateName"/>
    public RLinkSettingsCS SetValidateName(StringName name)
    {
        ValidateName = name;
        return this;
    }

    /// <inheritdoc cref="MaxDepth"/>
    public RLinkSettingsCS SetMaxDepth(int depth)
    {
        MaxDepth = depth;
        return this;
    }
}
