#if TOOLS
#nullable enable
using System;
using System.Threading.Tasks;
using Godot;
namespace ValidRLink;

[Tool]
public partial class RLinkUnloadDetector : Node, ISerializationListener
{
    public static RLinkUnloadDetector Instance { get; private set; } = null!;
    // private System.Runtime.InteropServices.GCHandle? _handle;
    private readonly System.Runtime.Loader.AssemblyLoadContext? _ctx;
    private Node? _parent;
    public bool CollectGC { get; set; }
    public bool ExecutePendingContinuations { get; set; }
    public bool SwallowBaseException { get; set; }

    public delegate void NotifyUnload();
    public event NotifyUnload? Unloading;

    public RLinkUnloadDetector()
    {
        Instance = this;

        // block unloading with a strong handle
        // _handle = System.Runtime.InteropServices.GCHandle.Alloc(this);

        // register cleanup code to prevent unloading issues
        _ctx = System.Runtime.Loader.AssemblyLoadContext.GetLoadContext(System.Reflection.Assembly.GetExecutingAssembly());
        if (_ctx is not null)
        {
            _ctx.Unloading += Unload;
        }
    }

    public override void _EnterTree() => _parent = GetParent();

    private void Unload(System.Runtime.Loader.AssemblyLoadContext alc)
    {
        Unloading?.Invoke();
        if (_ctx is not null)
        {
            _ctx.Unloading -= Unload;
        }
        try
        {
            TryExecuteContinuations();
        }
        finally
        {
            TryCollectGC();
            FreeHandle();
            _parent?.Call("clear_with_cancel");
        }
    }

    private void TryExecuteContinuations()
    {
        if (ExecutePendingContinuations)
        {
            var isDone = false;
            int times = 0;
            while (isDone is false && times < 5)
            {
                try
                {
                    times += 1;
                    Dispatcher.SynchronizationContext.ExecutePendingContinuations();
                    isDone = true;
                }
                catch (TaskCanceledException) { }
                catch (Exception e)
                {
                    if (SwallowBaseException)
                    {
                        GD.PushWarning($"ValidRLink: Swallowed error trying to execute pending continuations [RLinkUnloadDetector.TryExecuteContinuations]\n{e}");
                        isDone = true;
                    }
                    else
                        throw;
                }
            }
        }

    }

    private void TryCollectGC()
    {
        if (CollectGC)
        {
            GC.Collect();
            GC.WaitForPendingFinalizers();
        }
    }

    public void FreeHandle()
    {
        // _handle?.Free();
        // _handle = null;
    }

    // While this is working, use it
    public void OnBeforeSerialize()
    {
        if (_ctx is not null)
        {
            Unload(_ctx);
        }
    }

    public void OnAfterDeserialize() { }
}
#endif
