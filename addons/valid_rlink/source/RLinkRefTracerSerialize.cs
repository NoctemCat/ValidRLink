#if TOOLS
#nullable enable
using Godot;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.CompilerServices;

namespace ValidRLink;

[Tool]
public partial class RLinkRefTracerSerialize : Node, ISerializationListener
{
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE0028:Simplify collection initialization", Justification = "Godot 4.1 support")]
    private Godot.Collections.Array<ulong> _previouslyCreated = new();

    public void OnAfterDeserialize()
    {
        CallDeferred(MethodName.DisposePreviousInstances);
    }

    private void DisposePreviousInstances()
    {
        foreach (var refId in _previouslyCreated)
        {
            RefCounted? res = InstanceFromId(refId) as RefCounted;
            res?.Dispose();
        }
        _previouslyCreated.Clear();
    }

    public void OnBeforeSerialize()
    {
        _previouslyCreated.AddRange(RLinkRefTracer.Instance.GetRefs());
        // GD.Print($"Created: {RLinkRefTracer.Instance.GetCount()}");
        RLinkRefTracer.Instance.Clear();
    }

    [System.Diagnostics.CodeAnalysis.SuppressMessage("CodeQuality", "IDE0079:Remove unnecessary suppression", Justification = "Complains without it")]
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Performance", "CA1822:Mark members as static", Justification = "Godot 4.1 can't call statics directly from GDScript")]
    public void AddToDispose(RefCounted refCounted)
    {
        RLinkRefTracer.Instance.AddRef(refCounted);
    }
}


public class RLinkRefTracer
{
    private static RLinkRefTracer? _instance = null;
    public static RLinkRefTracer Instance => _instance ??= new();
    private RLinkRefTracer() { }

    private readonly ConcurrentDictionary<ulong, bool> _createdRefs = new();

    /// <summary>
    /// Only valid if called from constructor. Skips RefCounteds created by Godot or by GDScript.
    /// Only works in editor
    /// </summary>
    [Conditional("TOOLS")]
    [MethodImpl(MethodImplOptions.NoInlining)]
    public void AddRefIfCreatedDirectly(RefCounted? refCounted)
    {
        if (Engine.IsEditorHint())
        {
            StackTrace stackTrace = new();
            if (stackTrace.GetFrame(4)?.GetMethod()?.Name != "CreateManagedForGodotObjectScriptInstance")
            {
                AddRef(refCounted);
            }
        }
    }

    [Conditional("TOOLS")]
    public void AddRef(RefCounted? refCounted)
    {
        if (Engine.IsEditorHint())
        {
            if (refCounted is null) { return; }
            _createdRefs.AddOrUpdate(refCounted.GetInstanceId(), true, (_, _) => true);
        }
    }

    public IEnumerable<ulong> GetRefs()
    {
        return _createdRefs.Keys;
    }

    public int GetCount()
    {
        return _createdRefs.Count;
    }

    [Conditional("TOOLS")]
    public void Clear()
    {
        _createdRefs.Clear();
    }
}
#endif
