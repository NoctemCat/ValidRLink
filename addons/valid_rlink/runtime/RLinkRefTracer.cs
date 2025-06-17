#nullable enable
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.CompilerServices;
using Godot;

#pragma warning disable IDE0130 // Namespace does not match folder structure
namespace ValidRLink;
#pragma warning restore IDE0130 // Namespace does not match folder structure

public static class RLinkRefTracer
{
#if TOOLS
    private static readonly ConcurrentDictionary<ulong, bool> _createdRefs = new();
#endif

    /// <summary>
    /// Only valid if called from constructor. Skips RefCounteds created by Godot or by GDScript.
    /// Only works in editor
    /// </summary>
    [Conditional("TOOLS")]
    [MethodImpl(MethodImplOptions.NoInlining)]
    public static void AddRefIfCreatedDirectly(RefCounted? refCounted)
    {
#if TOOLS
        if (Engine.IsEditorHint())
        {
            StackTrace stackTrace = new();
            if (stackTrace.GetFrame(4)?.GetMethod()?.Name != "CreateManagedForGodotObjectScriptInstance")
            {
                AddRef(refCounted);
            }
        }
#endif
    }

    [Conditional("TOOLS")]
    public static void AddRef(RefCounted? refCounted)
    {
#if TOOLS
        if (Engine.IsEditorHint())
        {
            if (refCounted is null) { return; }
            _createdRefs.AddOrUpdate(refCounted.GetInstanceId(), true, (_, _) => true);
        }
#endif
    }

    public static IEnumerable<ulong> GetRefs()
    {
#if TOOLS
        return _createdRefs.Keys;
#else
        yield return 0;
#endif
    }

    public static int GetCount()
    {
#if TOOLS
        return _createdRefs.Count;
#else
        return 0;
#endif
    }

    [Conditional("TOOLS")]
    public static void Clear()
    {
#if TOOLS
        _createdRefs.Clear();
#endif
    }
}
