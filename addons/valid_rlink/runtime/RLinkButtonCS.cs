#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using Godot;

using System.Threading;
using System.Reflection;
using System.Threading.Tasks;
using System.Linq;
using System.Diagnostics;

namespace ValidRLink;

/// <summary>
/// Turns a method from non-tool class into a button in editor
/// </summary>
[Tool, GlobalClass]
[SuppressMessage("Style", "IDE0028:Simplify collection initialization", Justification = "Godot 4.1 support")]
[SuppressMessage("Style", "IDE0300:Simplify collection initialization", Justification = "Godot 4.1 support")]
[SuppressMessage("Style", "IDE0305:Simplify collection initialization", Justification = "Godot 4.1 support")]
public partial class RLinkButtonCS : Resource
{
    public static readonly StringName DefaultValuesName = "default_values";

    [Signal] public delegate void CompletedEventHandler(Variant result);

    /// <summary>
    /// Sizes from <c>Control</c> with added unset
    /// </summary>
    public enum ControlSizes
    {
        SizeUnset = -1,
        SizeShrinkBegin = 0,
        SizeFill = 1,
        SizeExpand = 2,
        SizeExpandFill = 3,
        SizeShrinkCenter = 4,
        SizeShrinkEnd = 8,
    }

    /// <summary>
    /// The type of method
    /// </summary>
    public enum MethodTypeEnum
    {
        NotFound = 0,
        GodotMethod = 1,
        CSharpDelegate = 2,
        CSharpAwaitable = 4,
    }

    private string text = "";
    /// <summary>
    /// The button's text that will be displayed inside the button's area
    /// </summary>
    [Export]
    public string Text
    {
        get => text;
        set
        {
            if (text == value) { return; }
            text = value;
            EmitChanged();
        }
    }
    private string tooltipText = "";
    /// <summary>
    /// Sets <see cref="Control.TooltipText"/>
    /// </summary>
    [Export]
    public string TooltipText
    {
        get => tooltipText;
        set
        {
            if (tooltipText == value) { return; }
            tooltipText = value;
            EmitChanged();
        }
    }
    private string icon = "";
    /// <summary>
    /// Sets editor icon by name, setting it unsets <see cref="IconTexture" />
    /// </summary>
    [Export]
    public string Icon
    {
        get => icon;
        set
        {
            if (icon == value) { return; }
            if (!string.IsNullOrWhiteSpace(value)) { iconTexture = null; }
            icon = value;
            EmitChanged();
        }
    }
    private Texture2D? iconTexture = null;
    /// <summary>
    /// Sets texture as icon, unsets <see cref="Icon" />
    /// </summary>
    [Export]
    public Texture2D? IconTexture
    {
        get => iconTexture;
        set
        {
            if (iconTexture == value) { return; }
            if (value != null) { icon = ""; }
            iconTexture = value;
            EmitChanged();
        }
    }
    private HorizontalAlignment iconAlignment;
    /// <summary>
    /// Icon behavior for <see cref="Button.IconAlignment" />
    /// </summary>
    [Export]
    public HorizontalAlignment IconAlignment
    {
        get => iconAlignment;
        set
        {
            if (iconAlignment == value) { return; }
            iconAlignment = value;
            EmitChanged();
        }
    }
    private VerticalAlignment iconAlignmentVertical;
    /// <summary>
    /// Icon behavior for <see cref="Button.VerticalIconAlignment" />
    /// </summary>
    [Export]
    public VerticalAlignment IconAlignmentVertical
    {
        get => iconAlignmentVertical;
        set
        {
            if (iconAlignmentVertical == value) { return; }
            iconAlignmentVertical = value;
            EmitChanged();
        }
    }
    private Color modulate;
    /// <summary>
    /// Modulates button
    /// </summary>
    [Export]
    public Color Modulate
    {
        get => modulate;
        set
        {
            if (modulate == value) { return; }
            modulate = value;
            EmitChanged();
        }
    }
    private int maxWidth;
    /// <summary>
    /// Sets maximum width, can be shrunk
    /// </summary>
    [Export]
    public int MaxWidth
    {
        get => maxWidth;
        set
        {
            if (maxWidth == value) { return; }
            maxWidth = value;
            EmitChanged();
        }
    }
    private int minHeight;
    /// <summary>
    /// Sets minimum height, can't be shrunk
    /// </summary>
    [Export]
    public int MinHeight
    {
        get => minHeight;
        set
        {
            if (minHeight == value) { return; }
            minHeight = value;
            EmitChanged();
        }
    }
    private int marginLeft;
    /// <summary>
    /// Sets left margin
    /// </summary>
    [Export]
    public int MarginLeft
    {
        get => marginLeft;
        set
        {
            if (marginLeft == value) { return; }
            marginLeft = value;
            EmitChanged();
        }
    }
    private int marginTop;
    /// <summary>
    /// Sets top margin
    /// </summary>
    [Export]
    public int MarginTop
    {
        get => marginTop;
        set
        {
            if (marginTop == value) { return; }
            marginTop = value;
            EmitChanged();
        }
    }
    private int marginRight;
    /// <summary>
    /// Sets right margin
    /// </summary>
    [Export]
    public int MarginRight
    {
        get => marginRight;
        set
        {
            if (marginRight == value) { return; }
            marginRight = value;
            EmitChanged();
        }
    }
    private int marginBottom;
    /// <summary>
    /// Sets bottom margin
    /// </summary>
    [Export]
    public int MarginBottom
    {
        get => marginBottom;
        set
        {
            if (marginBottom == value) { return; }
            marginBottom = value;
            EmitChanged();
        }
    }
    private bool disabled;
    /// <summary>
    /// Sets disabled on the button
    /// </summary>
    [Export]
    public bool Disabled
    {
        get => disabled;
        set
        {
            if (disabled == value) { return; }
            disabled = value;
            EmitChanged();
        }
    }
    private bool clipText;
    /// <summary>
    /// Sets clip text on the button   
    /// </summary>
    [Export]
    public bool ClipText
    {
        get => clipText;
        set
        {
            if (clipText == value) { return; }
            clipText = value;
            EmitChanged();
        }
    }
    private ControlSizes sizeFlags;
    /// <summary>
    /// If size is less than max width the flag is always SIZE_FILL, else it's SIZE_SHRINK_CENTER. 
    /// This allows to override the flag to other when the size of container is more than 
    /// its max width
    /// </summary>
    [Export]
    public ControlSizes SizeFlags
    {
        get => sizeFlags;
        set
        {
            if (sizeFlags == value) { return; }
            sizeFlags = value;
            EmitChanged();
        }
    }

    /// <summary>
    /// The args that will be passed to method using Callable rules
    /// </summary>
    [ExportGroup("Callable")]
    [Export] public Godot.Collections.Array BoundArgs { get; set; }
    /// <summary>
    /// Unbind next args using normal Callable rules
    /// </summary>
    [Export] public int UnbindNext { get; set; }
    /// <summary>
    /// Method that will be called
    /// </summary>
    [Export] public StringName CallableMethodName { get; set; } = "";

    /// <summary>
    /// Parsed method type that will be called
    /// </summary>
    public MethodTypeEnum MethodType { get; private set; }
    /// <summary>
    /// If true, the method result will get checked. If the result is false or Variant null will
    /// discard changes
    /// </summary>
    public bool NeedsCheck { get; private set; }

    private ulong _objectId;
    private ulong _scriptId;
    private MethodInfo? _info;
    private int _baseArgCount;
    private CancellationTokenSource? _ctx;

    [RequiresUnreferencedCode("Getting method by its name")]
    public RLinkButtonCS()
    {
        BoundArgs ??= new();
        RLinkRefTracer.Instance.AddRefIfCreatedDirectly(this);
    }

    [RequiresUnreferencedCode("Getting method by its name")]
    public RLinkButtonCS(Callable callable, Godot.Collections.Dictionary? properties = null)
    {
        BoundArgs = new();
        SetDefaults();
        RLinkRefTracer.Instance.AddRef(this);

        StringName method = GodotHelper.Callable.GetMethod(callable);
        if (method.ToString().Contains("anonymous lambda"))
        {
            GD.PushError("ValidRLink: Doesn't support lambdas [RLinkButtonCS.ctor(Callable)]");
            return;
        }

        BoundArgs = GodotHelper.Callable.GetBoundArguments(callable);
        if (GodotHelper.Callable.UnboundCountAvailable)
        {
            UnbindNext = GodotHelper.Callable.GetUnboundArgumentsCount(callable);
        }
        SetObject(callable.Target, method);
        if (properties is not null)
        {
            SetDictionary(properties);
        }
    }

    [RequiresUnreferencedCode("Getting method by its name")]
    public RLinkButtonCS(GodotObject target, StringName method, Godot.Collections.Dictionary? properties = null)
    {
        BoundArgs = new();
        SetDefaults();
        RLinkRefTracer.Instance.AddRef(this);

        SetObject(target, method);
        if (properties is not null)
        {
            SetDictionary(properties);
        }
    }

    /// <summary>
    /// Only sets method name, will retrieve method info when `SetObject` is called
    /// </summary>
    [RequiresUnreferencedCode("Getting method by its name")]
    public RLinkButtonCS(StringName method, Dictionary<StringName, Variant>? properties = null)
    {
        BoundArgs = new();
        SetDefaults();
        RLinkRefTracer.Instance.AddRef(this);

        CallableMethodName = method;
        if (properties is not null)
        {
            SetDictionary(properties);
        }
    }

    [RequiresUnreferencedCode("Getting method by its name")]
    public RLinkButtonCS(Delegate method, Dictionary<StringName, Variant>? properties = null)
    {
        GD.Print("> RLinkButtonCS 5");
        BoundArgs = new();
        SetDefaults();
        RLinkRefTracer.Instance.AddRef(this);

        if (typeof(GodotObject).IsAssignableFrom(method.Method.DeclaringType) is false)
        {
            GD.PushError("ValidRLink: Delegate must belong to type inherited from GodotObject [RLinkButtonCS.ctor(Delegate)]");
            return;
        }

        ParseCSharpMethod(method.Method, method.Method.Name);
        if (properties is not null)
        {
            SetDictionary(properties);
        }
    }

    public override bool _PropertyCanRevert(StringName property)
    {
        if (HasMeta(DefaultValuesName))
        {
            Godot.Collections.Dictionary defaults = GetMeta(DefaultValuesName).AsGodotDictionary();
            return defaults.ContainsKey(property);
        }
        return false;
    }

    public override Variant _PropertyGetRevert(StringName property)
    {
        if (HasMeta(DefaultValuesName))
        {
            Godot.Collections.Dictionary defaults = GetMeta(DefaultValuesName).AsGodotDictionary();
            return defaults[property];
        }
        return new Variant();
    }

#if GODOT4_4_OR_GREATER
    public override void _ResetState()
#else
        [SuppressMessage("Style", "IDE1006:Naming Styles", Justification = "It exists in a newer version")]
        public void _ResetState()
#endif
    {
        RestoreDefault();
    }

    protected override void Dispose(bool disposing)
    {
        CancelTask();
        base.Dispose(disposing);
    }

    private void SetDefaults()
    {
        UnbindNext = 0;
        IconAlignment = HorizontalAlignment.Left;
        IconAlignmentVertical = VerticalAlignment.Center;
        Modulate = Colors.White;
        MaxWidth = 200;
        ClipText = true;
        SizeFlags = ControlSizes.SizeUnset;
    }

    /// <inheritdoc cref="SetObject(GodotObject, StringName?)"/>
    [RequiresUnreferencedCode("Getting method by its name")]
    public RLinkButtonCS SetObject(GodotObject obj)
        => SetObject(obj, null);

    /// <summary>
    /// Sets object and, optionally, method to prepare it for calling. 
    /// If possible stores MethodInfo from GetMethod. If no MethodInfo is found
    /// checks if it exist in GDScript
    /// </summary>
    /// <param name="newMethod">The name of the method</param>
    [RequiresUnreferencedCode("Getting method by its name")]
    public RLinkButtonCS SetObject(GodotObject obj, StringName? newMethod = null)
    {
        ulong newId = obj.GetInstanceId();
        if (_objectId != newId)
        {
            _objectId = newId;
            SetMethod(obj, newMethod ?? CallableMethodName);
        }
        return this;
    }

    [RequiresUnreferencedCode("Getting method by its name")]
    private void SetMethod(GodotObject obj, StringName newMethod)
    {
        bool found = FindCSharpMethod(obj, newMethod) || FindGDScriptMethod(obj, newMethod);
        if (found is false)
        {
            _scriptId = 0;
            _baseArgCount = 0;
            NeedsCheck = false;
            CallableMethodName = newMethod;
            _info = null;
            MethodType = MethodTypeEnum.NotFound;
            GD.PushWarning($"ValidRLink: Method '{CallableMethodName}' not found on {obj} [RLinkButtonCS.SetMethod]");
        }
    }

    private bool FindCSharpMethod(GodotObject obj, StringName newMethod)
    {
        MethodInfo? method = obj.GetType().GetMethod(newMethod, BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic);
        if (method is not null)
        {
            if (_info != method)
            {
                ParseCSharpMethod(method, newMethod);
            }
            return true;
        }

        return false;
    }

    private bool FindGDScriptMethod(GodotObject obj, StringName newMethod)
    {
        if (obj.HasMethod(newMethod))
        {
            using Variant scriptVariant = obj.GetScript();
            Script? script = scriptVariant.AsGodotObject() as Script;

            if (script?.GetInstanceId() != _scriptId || newMethod != CallableMethodName)
            {
                ParseGDScriptMethod(obj, script, newMethod);
            }
            return true;
        }

        return false;
    }

    private void ParseCSharpMethod(MethodInfo method, StringName methodName)
    {
        _scriptId = 0;
        _baseArgCount = method.GetParameters().Length;
        NeedsCheck = false;
        CallableMethodName = methodName;
        _info = method;

        if (method.ReturnType == typeof(SignalAwaiter))
        {
            MethodType = MethodTypeEnum.CSharpAwaitable;
            NeedsCheck = false;
        }
        else if (method.ReturnType.IsGenericType && typeof(Task).IsAssignableFrom(method.ReturnType))
        {
            var actualReturnType = method.ReturnType.GenericTypeArguments[0];
            MethodType = MethodTypeEnum.CSharpAwaitable;
            NeedsCheck = actualReturnType == typeof(bool) || actualReturnType == typeof(Variant);
        }
        else if (method.ReturnType == typeof(Task))
        {
            MethodType = MethodTypeEnum.CSharpAwaitable;
            NeedsCheck = false;
        }
        else
        {
            MethodType = MethodTypeEnum.CSharpDelegate;
            NeedsCheck = method.ReturnType == typeof(bool) || method.ReturnType == typeof(Variant);
        }

        if (method.IsStatic)
        {
            _objectId = 0;
        }
    }

    private void ParseGDScriptMethod(GodotObject obj, Script? script, StringName methodName)
    {
        _scriptId = script?.GetInstanceId() ?? 0;
        _baseArgCount = 0;
        NeedsCheck = false;
        CallableMethodName = methodName;
        _info = null;
        MethodType = MethodTypeEnum.GodotMethod;

        Godot.Collections.Array<Godot.Collections.Dictionary> methodList;
        if (script is not null)
            methodList = script.GetScriptMethodList();
        else
            methodList = obj.GetMethodList();

        foreach (var methodDict in methodList)
        {
            if (methodDict["name"].AsString() == CallableMethodName)
            {
                _baseArgCount = methodDict["args"].AsGodotArray().Count;
                Godot.Collections.Dictionary returnDict = methodDict["return"].AsGodotDictionary();
                Variant.Type returnType = returnDict["type"].As<Variant.Type>();
                if (
                    returnType == Variant.Type.Bool || (returnType == Variant.Type.Nil &&
                    (returnDict["usage"].As<PropertyUsageFlags>() & PropertyUsageFlags.NilIsVariant) != PropertyUsageFlags.NilIsVariant))
                {
                    NeedsCheck = true;
                }
                script?.Dispose();
                return;
            }
        }
    }

    /// <summary>
    /// Sets exported properties by name from dictionary
    /// </summary>
    public RLinkButtonCS SetDictionary(Godot.Collections.Dictionary properties)
    {
        foreach (var propName in GodotHelper.GetObjectProperties(this))
        {
            StringName asStringName = propName;
            if (properties.TryGetValue(asStringName, out Variant value))
            {
                Set(asStringName, value);
            }
        }
        return this;
    }

    /// <summary>
    /// Sets exported properties by name from dictionary
    /// </summary>
    public RLinkButtonCS SetDictionary(Dictionary<StringName, Variant> properties)
    {
        foreach (var propName in GodotHelper.GetObjectProperties(this))
        {
            StringName asStringName = propName;
            if (properties.TryGetValue(asStringName, out Variant value))
            {
                Set(asStringName, value);
            }
        }
        return this;
    }

    /// <inheritdoc cref="RLinkCallv(Godot.Collections.Array)" />
    public Variant RLinkCall()
    {
        return RLinkCallv(new());
    }

    /// <inheritdoc cref="RLinkCallv(Godot.Collections.Array)" />
    /// <param name="arg">Argument passed to method. Bound arguments will be added after</param>
    public Variant RLinkCall(Variant arg)
    {
        return RLinkCallv(new Godot.Collections.Array { arg });
    }

    /// <summary>
    /// Calls stored method without waiting. Tries to convert the result to Variant, doesn't emit <c>Completed</c> signal
    /// </summary>
    /// <param name="args">Arguments passed to method. Bound arguments will be added after</param>
    /// <returns>Result converted to Variant if possible</returns>
    public Variant RLinkCallv(Godot.Collections.Array args)
    {
        if (UnbindNext > args.Count)
        {
            GD.PushError($"ValidRLink: Invalid call to function '{GetMethodName()}'. Expected -{UnbindNext} arguments [RLinkButtonCS.RLinkCallv]");
            return new Variant();
        }

        GodotObject? instance = InstanceFromId(_objectId);
        switch (MethodType)
        {

            case MethodTypeEnum.NotFound:
                {
                    GD.PushWarning($"ValidRLink: No method found [RLinkButtonCS.RLinkCallv]");
                    return new Variant();
                }
            case MethodTypeEnum.GodotMethod:
                {
                    if (instance is null)
                    {
                        GD.PushError($"ValidRLink: InstanceFromId returned null, id: {_objectId} [RLinkButtonCS.RLinkCallv]");
                        return new Variant();
                    }
                    Godot.Collections.Array callCopy = GetArgsCopy(args);
                    Variant variant = instance.Callv(CallableMethodName, callCopy);
                    return variant;
                }
            case MethodTypeEnum.CSharpDelegate:
            case MethodTypeEnum.CSharpAwaitable:
                {
                    List<object?> argsObj = args.Select(arg => GodotHelper.ToObject(arg)).ToList();
                    object?[]? callCopy = GetArgsCopyList(argsObj);

                    try
                    {
                        object? result = _info!.Invoke(instance, callCopy);
                        if (!GodotHelper.TryToVariant(result, out Variant variant))
                            variant = new Variant();

                        return variant;
                    }
                    catch (Exception e)
                    {
                        GD.PushError(e);
                        return new Variant();
                    }
                }
            default:
                GD.PushError($"ValidRLink: unknown MethodTypeEnum {(int)MethodType} [RLinkButtonCS.RLinkCallv");
                return new Variant();
        }

    }
    /// <inheritdoc cref="RLinkCallvAwait(Godot.Collections.Array)" />
    [RequiresUnreferencedCode("Needed for getting result from Task<>")]
    public Signal RLinkCallAwait()
    {
        _ = RLinkCallvAwaitTask(new());
        return new Signal(this, SignalName.Completed);
    }

    /// <inheritdoc cref="RLinkCallvAwait(Godot.Collections.Array)" />
    /// <param name="arg">Argument passed to method. Bound arguments will be added after</param>
    [RequiresUnreferencedCode("Needed for getting result from Task<>")]
    public Signal RLinkCallAwait(Variant arg)
    {
        _ = RLinkCallvAwaitTask(new Godot.Collections.Array { arg });
        return new Signal(this, SignalName.Completed);
    }

    /// <summary>
    /// Begin task without waiting, and returns a signal that will be emitted on when it ends
    /// </summary>
    /// <param name="args">Arguments passed to method. Bound arguments will be added after</param>
    /// <returns>Signal <c>Completed</c></returns>
    [RequiresUnreferencedCode("Needed for getting result from Task<>")]
    public Signal RLinkCallvAwait(Godot.Collections.Array args)
    {
        _ = RLinkCallvAwaitTask(args);
        return new Signal(this, SignalName.Completed);
    }

    /// <summary>
    /// Calls and awaits a method. Gets result using reflection if exist. Emits <c>Completed</c> signal with deferred on any result
    /// if the result is convertible to Variant it gets emitted with signal, if not passes null Variant
    /// </summary>
    /// <param name="args">Arguments passed to method. Bound arguments will be added after</param>
    [RequiresUnreferencedCode("Needed for getting result from Task<>")]
    public async Task RLinkCallvAwaitTask(Godot.Collections.Array args)
    {
        int argCount = args.Count;
        // Adds CancelationToken
        if (MethodType == MethodTypeEnum.CSharpAwaitable)
        {
            argCount += 1;
        }
        if (UnbindNext > argCount)
        {
            GD.PushError($"ValidRLink: Invalid call to function '{GetMethodName()}'. Expected -{UnbindNext} arguments [RLinkButtonCS.RLinkCallvAwaitTask]");
            CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
            return;
        }

        GodotObject? instance = InstanceFromId(_objectId);
        switch (MethodType)
        {
            case MethodTypeEnum.NotFound:
                {
                    GD.PushWarning($"ValidRLink: No method found [RLinkButtonCS.RLinkCallvAwaitTask]");
                    CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                    return;
                }
            case MethodTypeEnum.GodotMethod:
                {
                    if (instance is null)
                    {
                        GD.PushError($"ValidRLink: InstanceFromId returned null, id: {_objectId} [RLinkButtonCS.RLinkCallvAwaitTask]");
                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                        return;
                    }
                    _ctx = new();
                    Godot.Collections.Array callCopy = GetArgsCopy(args);
#if TOOLS
                    if (Engine.IsEditorHint())
                        RLinkUnloadDetector.Instance.Unloading += _ctx.Cancel;
#endif
                    try
                    {
                        // With `WaitAsync` Token abandons SignalAwaiter on cancellation in the hopes that it will be enough
                        Variant result = await GodotHelper.CallvAsync(instance, CallableMethodName, callCopy).WaitAsync(_ctx.Token);
                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, result });
                    }
                    catch (OperationCanceledException) // Don't know if this is possible, but wouldn't hurt
                    {
                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                        return;
                    }
                    catch (Exception e)
                    {
                        GD.PushError(e);
                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                        throw;
                    }
                    finally
                    {
#if TOOLS
                        if (Engine.IsEditorHint())
                            RLinkUnloadDetector.Instance.Unloading -= _ctx.Cancel;
#endif
                        _ctx.Dispose();
                        _ctx = null;
                    }
                    return;
                }
            case MethodTypeEnum.CSharpDelegate:
                {
                    List<object?> argsObj = args.Select(arg => GodotHelper.ToObject(arg)).ToList();
                    object?[]? callCopy = GetArgsCopyList(argsObj);

                    try
                    {
                        object? result = _info?.Invoke(instance, callCopy);

                        if (!GodotHelper.TryToVariant(result, out Variant variantConv))
                            variantConv = new Variant();

                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, variantConv });
                        return;
                    }
                    catch (Exception e)
                    {
                        GD.PushError(e);
                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                        throw;
                    }
                }
            case MethodTypeEnum.CSharpAwaitable:
                {
                    _ctx = new();
                    List<object?> argsObj = args.Select(arg => GodotHelper.ToObject(arg)).ToList();
                    argsObj.Add(_ctx.Token);
                    object?[]? callCopy = GetArgsCopyList(argsObj);
#if TOOLS
                    if (Engine.IsEditorHint())
                        RLinkUnloadDetector.Instance.Unloading += _ctx.Cancel;
#endif

                    try
                    {
                        object genericTask = _info!.Invoke(instance, callCopy)!;

                        object? result = null;
                        if (genericTask is Task task)
                        {
                            await task;
                            var resultProperty = task.GetType().GetProperty("Result", BindingFlags.Instance | BindingFlags.Public);
                            result = resultProperty?.GetValue(task, null);
                        }
                        else if (genericTask is SignalAwaiter signalAwaiter)
                        {
                            await signalAwaiter;
                            var signalResult = signalAwaiter.GetResult();
                            result = signalResult.Length > 0 ? signalResult[0] : new Variant();
                        }
                        else
                        {
                            Debug.Assert(false, "Shouldn't happen");
                        }

                        if (!GodotHelper.TryToVariant(result, out Variant variantConv))
                            variantConv = new Variant();

                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, variantConv });
                        return;
                    }
                    catch (OperationCanceledException)
                    {
                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                        return; // Expected
                    }
                    catch (Exception e)
                    {
                        GD.PushError(e);
                        CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                        throw;
                    }
                    finally
                    {
#if TOOLS
                        if (Engine.IsEditorHint())
                            RLinkUnloadDetector.Instance.Unloading -= _ctx.Cancel;
#endif
                        _ctx.Dispose();
                        _ctx = null;
                    }
                }
            default:
                GD.PushError($"ValidRLink: unknown MethodTypeEnum {(int)MethodType} [RLinkButtonCS.RLinkCallvAwaitTask");
                CallDeferred(GodotObject.MethodName.EmitSignal, new Variant[] { SignalName.Completed, new() });
                return;
        }
    }

    private Godot.Collections.Array GetArgsCopy(Godot.Collections.Array args)
    {
        Godot.Collections.Array copy = args.Duplicate();
        int unbindNextCopy = UnbindNext;
        while (copy.Count > 0 && unbindNextCopy > 0)
        {
            unbindNextCopy -= 1;
            copy.RemoveAt(copy.Count - 1);
        }

        Godot.Collections.Array callCopy = BoundArgs.Duplicate();
        for (int i = 0; i < copy.Count; i++)
        {
            callCopy.Insert(i, copy[i]);
        }
        return callCopy;
    }

    private object?[]? GetArgsCopyList(List<object?> args)
    {
        int unbindNextCopy = UnbindNext;
        while (args.Count > 0 && unbindNextCopy > 0)
        {
            unbindNextCopy -= 1;
            args.RemoveAt(args.Count - 1);
        }

        object?[] callCopy = new object[BoundArgs.Count + args.Count];
        for (int i = 0; i < args.Count; i++)
        {
            callCopy[i] = args[i];
        }
        for (int i = 0; i < BoundArgs.Count; i++)
        {
            callCopy[args.Count + i] = GodotHelper.ToObject(BoundArgs[i]);
        }
        if (callCopy.Length == 0) return null;
        return callCopy;
    }

    /// <summary>
    /// Communicates a request for cancellation to a running task if it exists
    /// </summary>
    public void CancelTask()
    {
        _ctx?.Cancel();
    }

    /// <summary>
    /// Adds argument that method will be called with
    /// </summary>
    public RLinkButtonCS Bind(Variant arg)
    {
        if (UnbindNext > 0)
        {
            UnbindNext -= 1;
            return this;
        }
        BoundArgs.Add(arg);
        return this;
    }

    /// <inheritdoc cref="Bindv(Godot.Collections.Array)" />
    public RLinkButtonCS Bindv(params Variant[] args) => Bindv(new Godot.Collections.Array(args));
    /// <summary>
    /// Adds arguments that method will be called with
    /// </summary>
    public RLinkButtonCS Bindv(Godot.Collections.Array args)
    {
        Godot.Collections.Array copy = args.Duplicate();
        while (copy.Count > 0 && UnbindNext > 0)
        {
            UnbindNext -= 1;
            copy.RemoveAt(copy.Count - 1);
        }
        for (int i = 0; i < copy.Count; i++)
        {
            BoundArgs.Insert(i, copy[i]);
        }
        return this;
    }

    /// <summary>
    /// Next arguments passed to bind or call will be ignored
    /// </summary>
    /// <param name="argCount">The number of args to unbind, must be greater than 0</param>
    public RLinkButtonCS Unbind(int argCount)
    {
        if (argCount <= 0)
        {
            GD.PushError("ValidRLink: Amount of unbind() arguments must be 1 or greater [RLinkButtonCS.Unbind]");
            return this;
        }
        UnbindNext += argCount;
        return this;
    }

    /// <returns>Calculated argument count</returns>
    public int GetArgCount()
    {
        return _baseArgCount - BoundArgs.Count + UnbindNext;
    }

    /// <returns>Method that will be called</returns>
    public StringName GetMethodName()
    {
        return CallableMethodName;
    }

    /// <inheritdoc cref="Text"/>
    public RLinkButtonCS SetText(string text)
    {
        Text = text;
        return this;
    }

    /// <inheritdoc cref="TooltipText"/>
    public RLinkButtonCS SetTooltipText(string text)
    {
        TooltipText = text;
        return this;
    }

    /// <inheritdoc cref="Icon"/>
    public RLinkButtonCS SetIcon(string editorIcon)
    {
        Icon = editorIcon;
        return this;
    }

    /// <inheritdoc cref="IconTexture"/>
    public RLinkButtonCS SetIconTexture(Texture2D icon)
    {
        IconTexture = icon;
        return this;
    }

    /// <inheritdoc cref="IconAlignment"/>
    public RLinkButtonCS SetIconAlignment(HorizontalAlignment alignment)
    {
        IconAlignment = alignment;
        return this;
    }

    /// <inheritdoc cref="IconAlignmentVertical"/>
    public RLinkButtonCS SetIconAlignmentVertical(VerticalAlignment alignment)
    {
        IconAlignmentVertical = alignment;
        return this;
    }

    /// <inheritdoc cref="Modulate"/>
    public RLinkButtonCS SetModulate(Color color)
    {
        Modulate = color;
        return this;
    }

    /// <inheritdoc cref="MaxWidth"/>
    public RLinkButtonCS SetMaxWidth(int width)
    {
        MaxWidth = width;
        return this;
    }

    /// <inheritdoc cref="MinHeight"/>
    public RLinkButtonCS SetMinHeight(int height)
    {
        MinHeight = height;
        return this;
    }

    /// <inheritdoc cref="MarginLeft"/>
    public RLinkButtonCS SetMarginLeft(int margin)
    {
        MarginLeft = margin;
        return this;
    }

    /// <inheritdoc cref="MarginTop"/>
    public RLinkButtonCS SetMarginTop(int margin)
    {
        MarginTop = margin;
        return this;
    }

    /// <inheritdoc cref="MarginRight"/>
    public RLinkButtonCS SetMarginRight(int margin)
    {
        MarginRight = margin;
        return this;
    }

    /// <inheritdoc cref="MarginBottom"/>
    public RLinkButtonCS SetMarginBottom(int margin)
    {
        MarginBottom = margin;
        return this;
    }

    /// <inheritdoc cref="Disabled"/>
    public RLinkButtonCS SetDisabled(bool disabled)
    {
        Disabled = disabled;
        return this;
    }

    /// <inheritdoc cref="SizeFlags"/>
    public RLinkButtonCS SetSizeFlags(ControlSizes sizeFlags)
    {
        SizeFlags = sizeFlags;
        return this;
    }

    /// <inheritdoc cref="SizeFlags"/>
    public RLinkButtonCS SetSizeFlagsControl(Control.SizeFlags sizeFlags)
    {
        SizeFlags = (ControlSizes)sizeFlags;
        return this;
    }

    /// <inheritdoc cref="Disabled"/>
    public RLinkButtonCS ToggleDisabled()
    {
        Disabled = !Disabled;
        return this;
    }

    /// <summary>
    /// Stores current exported properties as default
    /// </summary>
    public void SetCurrentAsDefault()
    {
        Godot.Collections.Dictionary defaults = new();
        foreach (var propName in GodotHelper.GetObjectProperties(this))
        {
            StringName asStringName = propName;
            defaults[asStringName] = Get(asStringName);
        }
        SetMeta(DefaultValuesName, defaults);
    }

    /// <summary>
    /// Sets exported properties to stored defaults
    /// </summary>
    public void RestoreDefault()
    {
        if (HasMeta(DefaultValuesName))
        {
            SetDictionary(GetMeta(DefaultValuesName).AsGodotDictionary());
        }
    }
}
