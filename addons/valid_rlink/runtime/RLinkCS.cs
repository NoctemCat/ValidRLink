#nullable enable
using System;
using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using System.Runtime.CompilerServices;
using Godot;

namespace ValidRLink;

/// <summary>
/// Adds common operations with history support
/// </summary>
[Tool, GlobalClass]
public partial class RLinkCS : RefCounted
{
    private ulong _dataId;
    private ulong _objectId;

    private GodotObject Data
    {
        get
        {
            var data = InstanceFromId(_dataId);
            ThrowIfNull(data);
            return data;
        }
    }

    /// <summary>
    /// The current placeholder object
    /// </summary>
    public GodotObject? Placeholder => InstanceFromId(_objectId);

    /// <summary>
    /// Needed for assembly reloading to work
    /// </summary>
    public RLinkCS()
    {
        RLinkRefTracer.Instance.AddRefIfCreatedDirectly(this);
    }

    public RLinkCS(RefCounted data)
    {
        _dataId = data.GetInstanceId();
        _objectId = data.Get(DataNames._ObjectId).AsUInt64();
        RLinkRefTracer.Instance.AddRef(this);
    }

    [SuppressMessage("CodeQuality", "IDE0079:Remove unnecessary suppression", Justification = "It complained without it")]
    [SuppressMessage("Performance", "CA1822:Mark members as static", Justification = "Don't want non static methods here")]
    public SceneTree GetTree()
    {
        return (SceneTree)Engine.GetMainLoop();
    }

    /// <summary>
    /// Compares current node with EditedSceneRoot
    /// </summary>
    public bool IsEditedSceneRoot() => Placeholder == GetTree().EditedSceneRoot;

    /// <inheritdoc cref="GetToolFrom(GodotObject)" />
    /// <typeparam name="T">The type of your class</typeparam>
    public T? GetToolFrom<T>(GodotObject runtime) where T : GodotObject
        => (T?)GetToolFrom(runtime);

    /// <summary>
    /// Retrieves tool object if exist
    /// </summary>
    /// <param name="runtime">Placeholder instance</param>
    /// <returns>Tool object or null</returns>
    public GodotObject? GetToolFrom(GodotObject runtime)
    {
        return Data.Call(DataNames.RLinkGetTool, runtime).AsGodotObject();
    }

    /// <inheritdoc cref="GetRuntimeFrom(GodotObject)" />
    /// <typeparam name="T">Base native Godot type</typeparam>
    public T? GetRuntimeFrom<T>(GodotObject tool) where T : GodotObject
        => (T?)GetRuntimeFrom(tool);

    /// <summary>
    /// Retrieves placeholder object if exist
    /// </summary>
    /// <param name="tool">Converted object</param>
    /// <returns>Registed placeholder or null</returns>
    public GodotObject? GetRuntimeFrom(GodotObject tool)
    {
        return Data.Call(DataNames.RLinkGetRuntime, tool).AsGodotObject();
    }

    /// <inheritdoc cref="ConvertToTool(GodotObject, int)" />
    /// <typeparam name="T">The type of your class</typeparam>
    [return: NotNullIfNotNull(nameof(runtime))]
    public T? ConvertToTool<T>(GodotObject? runtime, int customDepth = 1) where T : GodotObject
        => (T?)ConvertToTool(runtime, customDepth);

    /// <summary>
    /// Converts placeholder to a real object
    /// </summary>
    /// <param name="runtime">Placeholder instance</param>
    /// <returns>Registered object with your type, if not creates a new one</returns>
    [return: NotNullIfNotNull(nameof(runtime))]
    public GodotObject? ConvertToTool(GodotObject? runtime, int customDepth = 1)
    {
        return Data.Call(DataNames.RLinkConvertToTool, runtime ?? new Variant(), customDepth).AsGodotObject();
    }

    /// <inheritdoc cref="ConvertToRuntime(GodotObject, int, bool)" />
    /// <typeparam name="T">Base native Godot type</typeparam>
    [return: NotNullIfNotNull(nameof(tool))]
    public T? ConvertToRuntime<T>(GodotObject? tool, int customDepth = 1, bool trackInstances = true) where T : GodotObject
        => (T?)ConvertToRuntime(tool, customDepth, trackInstances);

    /// <summary>
    /// Converts tool object to placeholder
    /// </summary>
    /// <param name="tool">Converted instance</param>
    /// <param name="trackInstances">If true will free tool obj together with other temporaries</param>
    /// <returns>Runtime placeholder if registered, if not creates a new one</returns>
    [return: NotNullIfNotNull(nameof(tool))]
    public GodotObject? ConvertToRuntime(GodotObject? tool, int customDepth = 1, bool trackInstances = true)
    {
        return Data.Call(DataNames.RLinkConvertToRuntime, tool ?? new Variant(), customDepth, trackInstances).AsGodotObject();
    }

    /// <summary>
    /// Check if the registered pair is invalid. For nodes being outside of tree counts as invalid
    /// </summary>
    /// <param name="deleteIfInvalid">If pair is not valid, on true frees passed obj if it was created by this plugin</param>
    public bool IsPairInvalid(GodotObject obj, bool deleteIfInvalid = true)
        => !IsPairValid(obj, deleteIfInvalid);

    /// <summary>
    /// Check if the registered pair is valid. For nodes being outside of treee counts as invalid
    /// </summary>
    /// <param name="deleteIfInvalid">If pair is not valid, on true frees passed obj if it was created by this plugin</param>
    public bool IsPairValid(GodotObject obj, bool deleteIfInvalid = true)
    {
        return Data.Call(DataNames.RLinkIsPairValid, obj, deleteIfInvalid).AsBool();
    }

    /// <summary>
    /// Instantiates scene and converts root node to real type
    /// </summary>
    public T InstantiateFile<T>(string path) where T : Node
    {
        return InstantiatePacked<T>(GD.Load<PackedScene>(path));
    }

    /// <summary>
    /// Instantiates scene and converts root node to real type
    /// </summary>
    public T InstantiatePacked<T>(PackedScene scene) where T : Node
    {
        return ConvertToTool<T>(scene.Instantiate(PackedScene.GenEditState.Instance));
    }

    /// <summary>
    /// Instantiates scene and converts root node to real type
    /// </summary>
    public Node InstantiateFile(string path)
    {
        return InstantiatePacked(GD.Load<PackedScene>(path));
    }

    /// <summary>
    /// Instantiates scene and converts root node to real type
    /// </summary>
    public Node InstantiatePacked(PackedScene scene)
    {
        return ConvertToTool<Node>(scene.Instantiate(PackedScene.GenEditState.Instance));
    }

    /// <summary>
    /// Gets parent as real type
    /// </summary>
    public T? GetParent<T>() where T : Node
        => (T?)GetParent();

    /// <summary>
    /// Gets parent as real type
    /// </summary>
    public Node? GetParent()
    {
        if (Placeholder is not Node nodePlaceholder) return null;
        Node? parent = nodePlaceholder.GetParent();
        if (parent is null) return null;
        return ConvertToTool<Node>(parent);
    }

    /// <summary>
    /// Gets parent for node as real type
    /// </summary>
    public T? GetParentFor<T>(Node toolNode) where T : Node
        => (T?)GetParentFor(toolNode);

    /// <summary>
    /// Gets parent for node as real type
    /// </summary>
    public Node? GetParentFor(Node toolNode)
    {
        Node? runtimeNode = GetRuntimeFrom<Node>(toolNode);
        if (runtimeNode is null)
        {
            GD.PushError("ValidRLink: runtime pair is not registered [RLink.GetParentFrom]");
            return null;
        }
        Node? parent = runtimeNode.GetParent();
        if (parent is null) return null;
        return ConvertToTool<Node>(parent);
    }

    /// <summary>
    /// Gets node as real type
    /// </summary>
    public Node? GetNodeOrNull(in NodePath path)
        => GetNodeOrNull<Node>(path);

    /// <summary>
    /// Gets node as real type
    /// </summary>
    public T? GetNodeOrNull<T>(in NodePath path) where T : Node
    {
        if (Placeholder is not Node nodePlaceholder) return null;
        Node? node = nodePlaceholder.GetNodeOrNull(path);
        return ConvertToTool<T>(node);
    }

    /// <summary>
    /// Gets node from node as real type
    /// </summary>
    public Node? GetNodeOrNullFrom(Node toolNode, in NodePath path)
        => GetNodeOrNullFrom<Node>(toolNode, path);

    /// <summary>
    /// Gets node from node as real type
    /// </summary>
    public T? GetNodeOrNullFrom<T>(Node toolNode, in NodePath path) where T : Node
    {
        Node? runtimeNode = GetRuntimeFrom<Node>(toolNode);
        if (runtimeNode is null)
        {
            GD.PushError("ValidRLink: runtime pair is not registered [RLink.GetNodeOrNullFrom]");
            return null;
        }
        Node? runtime = runtimeNode.GetNodeOrNull(path);
        return ConvertToTool<T>(runtime);
    }

    /// <summary>
    /// Checks if node exist
    /// </summary>
    public bool HasNode(in NodePath path)
    {
        if (Placeholder is not Node nodePlaceholder) return false;
        return nodePlaceholder.HasNode(path);
    }

    /// <summary>
    /// Checks if node exist from node
    /// </summary>
    public bool HasNodeFrom(Node toolNode, in NodePath path)
    {
        Node? runtimeNode = GetRuntimeFrom<Node>(toolNode);
        if (runtimeNode is null)
        {
            GD.PushError("ValidRLink: runtime pair is not registered [RLink.HasNodeFrom]");
            return false;
        }
        return runtimeNode.HasNode(path);
    }

    /// <summary>
    /// Adds child to current node
    /// </summary>
    public void AddChild(Node child)
    {
        if (Placeholder is not Node) return;
        Node runtimeChild = ConvertToRuntime<Node>(child);
        Data.Call(DataNames.RLinkAddChildTo, Placeholder, runtimeChild);
    }

    /// <summary>
    /// Adds child to toolNode node
    /// </summary>
    public void AddChildTo(Node toolNode, Node child)
    {
        Node? runtimeNode = GetRuntimeFrom<Node>(toolNode);
        if (runtimeNode is null)
        {
            GD.PushError("ValidRLink: runtime pair is not registered [RLink.AddChildTo]");
            return;
        }
        Node runtimeChild = ConvertToRuntime<Node>(child);
        Data.Call(DataNames.RLinkAddChildTo, runtimeNode, runtimeChild);
    }

    /// <summary>
    /// Gets the node before last segment and adds a child to it with the name from the last segment.
    /// When the last parameter is true, frees passed <c>child</c> if node before last segment from 
    /// <c>path</c> is not found
    /// </summary>
    public void AddChildPath(NodePath path, Node child, bool freeIfNotFound = true)
    {
        if (Placeholder is not Node nodePlaceholder) return;
        string names = path.GetConcatenatedNames();
        int idx = names.LastIndexOf('/');
        Node? runtimeNode;
        if (idx == -1)
            runtimeNode = nodePlaceholder;
        else
            runtimeNode = nodePlaceholder.GetNodeOrNull(names[..idx]);

        if (runtimeNode is null)
        {
            if (freeIfNotFound)
                child.QueueFree();
            return;
        }

        child.Name = path.GetName(path.GetNameCount() - 1);
        Node? runtimeChild = ConvertToRuntime<Node>(child);
        Data.Call(DataNames.RLinkAddChildTo, runtimeNode, runtimeChild);
    }

    /// <summary>
    /// Removes child from current node
    /// </summary>
    public void RemoveChild(Node child)
    {
        if (Placeholder is not Node) return;
        Node? runtimeChild = GetRuntimeFrom<Node>(child);
        if (runtimeChild is null)
        {
            GD.PushError("ValidRLink: runtime pair is not registered [RLink.RemoveChild]");
            return;
        }
        Data.Call(DataNames.RLinkRemoveChildFrom, Placeholder, runtimeChild);
    }

    /// <summary>
    /// Removes child from node
    /// </summary>
    public void RemoveChildFrom(Node toolNode, Node child)
    {
        Node? runtimeNode = GetRuntimeFrom<Node>(toolNode);
        Node? runtimeChild = GetRuntimeFrom<Node>(child);
        if (runtimeNode is null || runtimeChild is null)
        {
            GD.PushError("ValidRLink: runtime pair is not registered [RLink.RemoveChildFrom]");
            return;
        }
        Data.Call(DataNames.RLinkRemoveChildFrom, runtimeNode, runtimeChild);
    }

    /// <summary>
    /// Removes the node at the end of the path from current
    /// </summary>
    public void RemoveChildPath(in NodePath path)
    {
        if (Placeholder is not Node nodePlaceholder) return;

        Node? runtimeNode = nodePlaceholder.GetNodeOrNull(path);
        if (runtimeNode is null) return;
        Data.Call(DataNames.RLinkRemoveChildFrom, runtimeNode.GetParent(), runtimeNode);
    }

    /// <summary>
    /// Removes all children from current node
    /// </summary>
    public void RemoveAllChildren()
    {
        if (Placeholder is not Node nodePlaceholder) return;
        for (int idx = 0; idx < nodePlaceholder.GetChildCount(); idx++)
        {
            Data.Call(DataNames.RLinkRemoveChildFrom, nodePlaceholder, nodePlaceholder.GetChild(idx));
        }
    }

    /// <summary>
    /// Removes all children from toolNode
    /// </summary>
    public void RemoveAllChildrenFrom(Node toolNode)
    {
        Node? runtimeNode = GetRuntimeFrom<Node>(toolNode);
        if (runtimeNode is null)
        {
            GD.PushError("ValidRLink: runtime pair is not registered [RLink.RemoveAllChildrenFrom]");
            return;
        }
        for (int idx = 0; idx < runtimeNode.GetChildCount(); idx++)
        {
            Data.Call(DataNames.RLinkRemoveChildFrom, runtimeNode, runtimeNode.GetChild(idx));
        }
    }

    /// <summary>
    /// Removes all children from the node at path
    /// </summary>
    public void RemoveAllChildrenPath(in NodePath path)
    {
        if (Placeholder is not Node nodePlaceholder) return;

        Node? runtimeNode = nodePlaceholder.GetNodeOrNull(path);
        if (runtimeNode is null) return;

        for (int idx = 0; idx < runtimeNode.GetChildCount(); idx++)
        {
            Data.Call(DataNames.RLinkRemoveChildFrom, runtimeNode, runtimeNode.GetChild(idx));
        }
    }

    /// <inheritdoc cref="SignalConnect(in Signal, in Variant, Godot.Collections.Array?, int)" />
    public void SignalConnect(in Signal signal, Delegate method, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
        => SignalConnect(signal, DelegateToCallable(method), bindvArgs, unbind);

    /// <summary>
    /// Connects them persistingly, bound arguments get added first, then unbind. Callables are treated as connected if they have the
    /// same object and method, so different binds are treated as the same callable
    /// </summary>
    public void SignalConnect(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
    {
        bindvArgs ??= new();
        Data.Call(DataNames.RLinkSignalConnect, signal, callable, bindvArgs, unbind);
    }

    /// <inheritdoc cref="SignalDisconnect(in Signal, in Variant, Godot.Collections.Array?, int)" />
    public void SignalDisconnect(in Signal signal, Delegate method, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
        => SignalDisconnect(signal, DelegateToCallable(method), bindvArgs, unbind);

    /// <summary>
    /// Disconnects them, bound arguments get added first, then unbind. Callables are treated as connected if they have the
    /// same object and method, so different binds are treated as the same callable
    /// </summary>
    public void SignalDisconnect(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
    {
        bindvArgs ??= new();
        Data.Call(DataNames.RLinkSignalDisconnect, signal, callable, bindvArgs, unbind);
    }

    /// <inheritdoc cref="SignalIsConnected(in Signal, in Variant, Godot.Collections.Array?, int)" />
    public bool SignalIsConnected(in Signal signal, Delegate method, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
        => SignalIsConnected(signal, DelegateToCallable(method), bindvArgs, unbind);

    /// <summary>
    /// Check if callable connected to the signal. Callables are treated as connected if they have the
    /// same object and method, so different binds are treated as the same callable
    /// </summary>
    public bool SignalIsConnected(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
    {
        bindvArgs ??= new();
        return Data.Call(DataNames.RLinkSignalIsConnected, signal, callable, bindvArgs, unbind).AsBool();
    }

    /// <inheritdoc cref="SignalToggle(in Signal, in Variant, Godot.Collections.Array?, int)" />
    public void SignalToggle(in Signal signal, Delegate method, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
        => SignalToggle(signal, DelegateToCallable(method), bindvArgs, unbind);

    /// <summary>
    /// Checks if connected, if connected disconnects callable, if not, callable is connected
    /// </summary>
    public void SignalToggle(in Signal signal, in Variant callable, Godot.Collections.Array? bindvArgs = null, int unbind = 0)
    {
        bindvArgs ??= new();
        if (SignalIsConnected(signal, callable, bindvArgs, unbind))
            SignalDisconnect(signal, callable, bindvArgs, unbind);
        else
            SignalConnect(signal, callable, bindvArgs, unbind);
    }


    private static Variant DelegateToCallable(Delegate callable)
    {
        if (!callable.Method.IsStatic)
        {
            if (callable.Target is not GodotObject godotObject)
            {
                GD.PushError("ValidRLink: Delegate's target must inherit from GodotObject [RLinkCS.DelegateToCallable]");
                return new();
            }

            return new Callable(godotObject, callable.Method.Name);
        }
        else
        {
            // Static methods still don't work, but I'm going to just leave it, theoretically it should work
            // and it prints correct method name, even could be called, just doesn't pass "is_valid" check
            GD.PushWarning("ValidRLink: Currently can't create a valid Callable for a static C# method [RLinkCS.DelegateToCallable]");

            Type? type = callable.Method.DeclaringType;
            if (type is null || !typeof(GodotObject).IsAssignableFrom(type))
            {
                GD.PushError("ValidRLink: Delegate's static method must belong to type that inherits from GodotObject [RLinkCS.DelegateToCallable]");
                return new();
            }

            ScriptPathAttribute? attr = (ScriptPathAttribute?)type.GetCustomAttribute(typeof(ScriptPathAttribute));
            if (attr is null)
            {
                GD.PushError("ValidRLink: GodotObject type is missing 'ScriptPathAttribute' [RLinkCS.DelegateToCallable]");
                return new();
            }
            return GodotHelper.Callable.CallConstructor(GD.Load(attr.Path), callable.Method.Name);
        }
    }

    /// <summary>
    /// The added changes will be added to buffer and added to history. In the case of checked call, if the
    /// check fails, discards all changes
    /// </summary>
    public void AddChanges(GodotObject obj, StringName property, Variant? oldValue, Variant? newValue)
    {
        oldValue ??= new();
        newValue ??= new();
        Data.Call(DataNames.RLinkAddChanges, obj, property, oldValue.Value, newValue.Value);
    }

    /// <summary>
    /// Only works with native resources. Other objects get duplicated, so they are alive only for a limited time,  
    /// so general do methods for them won't be supported
    /// </summary>
    public void AddDoMethod(GodotObject obj, StringName property, Godot.Collections.Array? args = null)
    {
        args ??= new();
        Data.Call(DataNames.RLinkAddDoMethod, obj, property, args);
    }

    /// <summary>
    /// Only works with native resources. Other objects get duplicated, so they are alive only for a limited time, 
    /// so general undo methods for them won't be supported
    /// </summary>
    public void AddUndoMethod(GodotObject obj, StringName property, Godot.Collections.Array? args = null)
    {
        args ??= new();
        Data.Call(DataNames.RLinkAddUndoMethod, obj, property, args);
    }

    public static class DataNames
    {
        [SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "Original name had the same beginning")]
        public static StringName _ObjectId { get; } = "_object_id";

        public static StringName RLinkGetTool { get; } = "rlink_get_tool";
        public static StringName RLinkGetRuntime { get; } = "rlink_get_runtime";
        public static StringName RLinkConvertToTool { get; } = "rlink_convert_to_tool";
        public static StringName RLinkConvertToRuntime { get; } = "rlink_convert_to_runtime";
        public static StringName RLinkIsPairValid { get; } = "rlink_is_pair_valid";
        public static StringName RLinkAddChildTo { get; } = "rlink_add_child_to";
        public static StringName RLinkRemoveChildFrom { get; } = "rlink_remove_child_from";
        public static StringName RLinkSignalConnect { get; } = "rlink_signal_connect";
        public static StringName RLinkSignalDisconnect { get; } = "rlink_signal_disconnect";
        public static StringName RLinkSignalIsConnected { get; } = "rlink_signal_is_connected";
        public static StringName RLinkAddChanges { get; } = "rlink_add_changes";
        public static StringName RLinkAddDoMethod { get; } = "rlink_add_do_method";
        public static StringName RLinkAddUndoMethod { get; } = "rlink_add_undo_method";
    }

    public static void ThrowIfNull([NotNull] object? argument, [CallerArgumentExpression(nameof(argument))] string? paramName = null)
    {
        if (argument is null)
        {
            throw new NullReferenceException($"{paramName} is null");
        }
    }
}
