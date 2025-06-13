#if TOOLS
#nullable enable
using Godot;
using System;
using System.Collections.Generic;
using System.Reflection;

namespace ValidRLink;

public partial class RLinkDB : Node
{
    private readonly Dictionary<string, Type> _types;
    public RLinkDB()
    {
        _types = new();
        foreach (var type in Assembly.GetExecutingAssembly().GetTypes())
        {
            if (type.GetCustomAttribute<ScriptPathAttribute>(false) is ScriptPathAttribute pathAttribute)
            {
                _types[pathAttribute.Path] = type;
            }
        }
    }

    public RLinkSettingsCS? GetRLinkSettings(Script script, Godot.Collections.Array<StringName> possibleNames)
    {
        if (_types.TryGetValue(script.ResourcePath, out Type? type))
        {
            foreach (var name in possibleNames)
            {
                var mi = type.GetMethod(name, BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
                object? possibleSettings = mi?.Invoke(null, null);
                if (possibleSettings is RLinkSettingsCS settings)
                {
                    return settings;
                }
            }
        }
        return null;
    }

    public Godot.Collections.Dictionary GetMethodInfo(Script script, string methodName)
    {
        Godot.Collections.Dictionary info = new();
        if (_types.TryGetValue(script.ResourcePath, out Type? type))
        {
            var mi = type.GetMethod(methodName, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            if (mi is not null)
            {
                info["arg_count"] = mi.GetParameters().Length;
                info["needs_check"] = mi.ReturnType == typeof(bool) || mi.ReturnType == typeof(Variant);
            }
        }
        return info;
    }
}
#endif
