#if TOOLS
#nullable enable
using Godot;
namespace ValidRLink;

[Tool]
public partial class VrlUnloadDetector : Node
{
    private System.Runtime.InteropServices.GCHandle? _handle;
    private readonly System.Runtime.Loader.AssemblyLoadContext? _ctx;
    private Node? _parent;
    public bool CollectGCOnExit { get; set; }

    public VrlUnloadDetector()
    {
        // block unloading with a strong handle
        _handle = System.Runtime.InteropServices.GCHandle.Alloc(this);

        // register cleanup code to prevent unloading issues
        _ctx = System.Runtime.Loader.AssemblyLoadContext.GetLoadContext(System.Reflection.Assembly.GetExecutingAssembly());
        if (_ctx is not null)
        {
            _ctx.Unloading += Unload;
        }
    }

    protected override void Dispose(bool disposing)
    {
        if (_ctx is not null)
        {
            _ctx.Unloading -= Unload;
        }
        _parent?.Call(EditorPlugin.MethodName._Clear);
        FreeHandle();
        base.Dispose(disposing);
    }

    public override void _EnterTree() => _parent = GetParent();
    public override void _ExitTree()
    {
        if (CollectGCOnExit)
        {
            System.GC.Collect();
            System.GC.WaitForPendingFinalizers();
        }
        _parent = null;
    }

    private void Unload(System.Runtime.Loader.AssemblyLoadContext alc)
    {
        _parent?.Call(EditorPlugin.MethodName._Clear);
        FreeHandle();
    }

    public void FreeHandle()
    {
        _handle?.Free();
        _handle = null;
    }
}
#endif
