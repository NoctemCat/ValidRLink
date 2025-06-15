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
        _previouslyCreated.AddRange(RLinkRefTracer.GetRefs());
        // GD.Print($"Created: {RLinkRefTracer.Instance.GetCount()}");
        RLinkRefTracer.Clear();
    }

    [System.Diagnostics.CodeAnalysis.SuppressMessage("CodeQuality", "IDE0079:Remove unnecessary suppression", Justification = "Complains without it")]
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Performance", "CA1822:Mark members as static", Justification = "Godot 4.1 can't call statics directly from GDScript")]
    public void AddToDispose(RefCounted refCounted)
    {
        RLinkRefTracer.AddRef(refCounted);
    }
}
#endif
