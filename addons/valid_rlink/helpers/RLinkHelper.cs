#if TOOLS || !DISABLE_VALIDATE_HELPER
#nullable enable
using System;
using System.Diagnostics.CodeAnalysis;
using Godot;
namespace ValidRLink;

[Tool]
public partial class RLinkHelper : RefCounted
{
    private ulong _data_id;
    private GodotObject? Data => InstanceFromId(_data_id);
    public Node? EditedSceneRoot => (Node?)Data?.Call(HelperNames.GetEditedSceneRoot);

    // Needed for tool hot reloading to work, _data will also be restored
    public RLinkHelper() { }
    public RLinkHelper(GodotObject data)
    {
        _data_id = data.GetInstanceId();
    }

    public T GetRealInstance<T>(GodotObject placeholder, int customDepth = 1) where T : GodotObject
    {
        ThrowIfInvalid(Data is null || !IsInstanceValid(Data), this);
        return (T)Data.Call(HelperNames.ConvertToTool, placeholder, customDepth);
    }

    public T GetPlaceholder<T>(GodotObject realInstance, bool registerInstances = true, int customDepth = 1) where T : GodotObject
    {
        ThrowIfInvalid(Data is null || !IsInstanceValid(Data), this);
        if (registerInstances)
            Data.Set(HelperNames.RegisterToolInstances, true);
        var runtime = Data.Call(HelperNames.ConvertToRuntime, realInstance, customDepth);

        if (registerInstances)
            Data.Set(HelperNames.RegisterToolInstances, false);
        return (T)runtime;
    }

    public bool IsPairValid(GodotObject obj, bool deleteIfInvalid = true)
    {
        ThrowIfInvalid(Data is null || !IsInstanceValid(Data), this);
        return (bool)Data.Call(HelperNames.IsPairValid, obj, deleteIfInvalid);
    }

    public bool IsPairInvalid(GodotObject obj, bool deleteIfInvalid = true)
    {
        ThrowIfInvalid(Data is null || !IsInstanceValid(Data), this); // 2
        return !(bool)Data.Call(HelperNames.IsPairValid, obj, deleteIfInvalid);
    }

    public static class HelperNames
    {
        public static StringName RegisterToolInstances { get; } = "register_tool_instances";
        public static StringName ConvertToTool { get; } = "convert_to_tool";
        public static StringName ConvertToRuntime { get; } = "convert_to_runtime";
        public static StringName GetEditedSceneRoot { get; } = "get_edited_scene_root";
        public static StringName IsPairValid { get; } = "is_pair_valid";
    }

    static void ThrowIfInvalid([DoesNotReturnIf(true)] bool condition, object instance)
    {
        if (condition)
        {
            throw new ObjectDisposedException(instance.GetType().FullName);
        }
    }
}
#endif
