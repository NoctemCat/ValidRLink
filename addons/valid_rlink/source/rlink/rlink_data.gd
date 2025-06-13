@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const Compat = Context.Compatibility

const ScanResult = preload("./scan_result.gd")
const ScanCache = preload("./scan_cache.gd")
const RLinkMap = preload("./rlink_map.gd")
const RLinkBuffer = preload("./rlink_buffer.gd")
const ToTool = preload(Context.SOURCE_PATH + "converters/converter_to_tool.gd")
const ToRuntime = preload(Context.SOURCE_PATH + "converters/converter_to_runtime.gd")
const RLinkScript = preload(Context.RUNTIME_PATH + "rlink.gd")

signal busy_changed(status: bool, id: int)

var __context: Context
var __settings: Settings
var __compat: Compat
var __undo_redo: EditorUndoRedoManager
var __scan_cache: ScanCache
var __map: RLinkMap
var __conv_to_tool: ToTool
var __conv_to_runtime: ToRuntime

var _object_id: int
var runtime: Object:
    get: return instance_from_id(_object_id)
var tool_obj: Object ## Keeps RefCounted alive
var _buffer: RLinkBuffer

var _helper: RLinkScript
var _helper_cs: RefCounted

var _validate_queued: String
var _validate_exceptions: Dictionary
var _validate_max_depth: int
var busy: bool:
    get: return busy
    set(value):
        if !value: _buffer.discard_changes()
        busy = value
        if !value and _validate_queued != "":
            var copy := _validate_queued
            _validate_queued = ""
            validate_changes(copy)
        busy_changed.emit(busy, get_instance_id())


func _init(ctx: Context, object: Object, in_result: ScanResult) -> void:
    __context = ctx
    __settings = ctx.settings
    __compat = ctx.compat
    __undo_redo = ctx.undo_redo
    __scan_cache = ctx.scan_cache
    __map = ctx.rlink_map
    __conv_to_tool = ctx.converter_to_tool
    __conv_to_runtime = ctx.converter_to_runtime
    
    _object_id = object.get_instance_id()
    _validate_max_depth = in_result.max_depth
    
    _buffer = RLinkBuffer.new(ctx)
    tool_obj = __conv_to_tool._convert_value(_buffer, runtime)
    
    _helper = RLinkScript.new(self)
    if ctx.csharp_enabled:
        _helper_cs = ctx.csharp_helper_script.new(self)
        
    __context.cancel_tasks.connect(_on_cancel_tasks)


func _on_cancel_tasks() -> void:
    _buffer.discard_changes()
    busy = false


func add_validate_exception(tool_id: int) -> void:
    _validate_exceptions[tool_id] = true
    
    
func remove_validate_exception(tool_id: int) -> void:
    _validate_exceptions.erase(tool_id)


func check_valid() -> bool:
    if not is_instance_valid(tool_obj):
        busy = false
        __context.clear_and_refresh()
        return true
    return false


func convert_to_tool(object: Object, depth: int = 0) -> Object:
    return __conv_to_tool._convert_value(_buffer, object, depth)
    
    
func convert_to_runtime(object: Object, depth: int = 0) -> Object:
    return __conv_to_runtime._convert_value(_buffer, object, depth)
 

func validate_changes(object_name: String) -> void:
    if check_valid(): return
    if object_name.is_empty():
        object_name = "[EmptyName]"
    if busy:
        _validate_queued = object_name
        return
    busy = true
    _validate_visit_object(object_name, {}, tool_obj, 0)
    busy = false


func _validate_visit_variant(name: String, v_visit: Dictionary, value: Variant, depth: int) -> void:
    if value == null: return

    var type := typeof(value)
    if type == TYPE_OBJECT:
        _validate_visit_object(name, v_visit, value, depth)
    elif type == TYPE_ARRAY:
        _validate_visit_array(name, v_visit, value, depth)
    elif type == TYPE_DICTIONARY:
        _validate_visit_dictionary(name, v_visit, value, depth)


func _validate_visit_array(name: String, v_visit: Dictionary, array: Array, depth: int) -> void:
    @warning_ignore("untyped_declaration")
    for elem in array:
        _validate_visit_variant(name, v_visit, elem, depth)


func _validate_visit_dictionary(name: String, v_visit: Dictionary, dictionary: Dictionary, depth: int) -> void:
    @warning_ignore("untyped_declaration")
    for key in dictionary:
        _validate_visit_variant(name, v_visit, key, depth)
        _validate_visit_variant(name, v_visit, dictionary[key], depth)


func _validate_visit_object(name: String, v_visit: Dictionary, object: Object, depth: int) -> void:
    var object_id := object.get_instance_id()
    if _validate_exceptions.has(object_id): return
    if v_visit.has(object_id): return
    v_visit[object_id] = true

    var res := __scan_cache.get_search(object)

    for prop in object.get_property_list():
        if depth + 1 >= _validate_max_depth: continue
        if not __conv_to_tool.can_contain_object(prop["type"]): continue
        if __conv_to_tool._skip_property(res.skip_properties, res.allowed_properties, prop): continue
        
        var prop_name: StringName = prop["name"]
        if prop_name == &"script": continue
        var value: Variant = object.get(prop_name)
        if __conv_to_tool._skip_object(value): continue
        
        _validate_visit_variant(name, v_visit, value, depth + 1)

    if res.has_validate:
        validate_object(name, object, res)


func validate_object(name: String, object: Object, result: ScanResult) -> void:
    var obj_runtime := __map.runtime_from_obj(object)
    if obj_runtime == null: return
    if convert_to_tool(obj_runtime) == null: return
    
    var call_res: Variant = _call_validate(object, result)
    if result.validate_check_return and not is_same(call_res, true):
        _buffer.discard_changes()
        return
        
    if convert_to_runtime(object) == null:
        _buffer.discard_changes()
        return
    
    _buffer.push_validate_action("Validate '%s'" % name, obj_runtime)


func _call_validate(object: Object, result: ScanResult) -> Variant:
    if result.validate_arg_count == 0: return object.call(result.validate_name)
    elif result.validate_arg_count == 1: return object.call(result.validate_name, _get_helper(object))
    else: push_error("ValidRLink: Validate function takes maximum 1 argument [rlink_data._call_validate]")
    return null


func call_callable(prop_name: StringName) -> void:
    if check_valid(): return
    if busy: return
    var to_call := tool_obj.get(prop_name) as Callable
    if to_call == null:
        push_error("ValidRLink: '%s' expected Callable [rlink_data.call_callable]" % prop_name)
        return
    
    var info: ScanResult.MethodInfo = null
    var arg_count: int
    if to_call.is_standard():
        var res := __scan_cache.get_search(runtime)
        info = res.get_method_info(to_call.get_method())
        arg_count = info.arg_count
    elif __compat.callable_arg_count_available():
        arg_count = __compat.get_arg_count(to_call)
    else:
        arg_count = 1 # just passing helper if the number is unknown
    if arg_count < 0 or arg_count > 1:
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_callable]" % prop_name)
        return
        
    busy = true
    if convert_to_tool(runtime) == null:
        busy = false
        return
    
    var call_res: Variant = await _call_callable_impl(arg_count, to_call)
    if info != null and info.check_return and not is_same(call_res, true):
        busy = false
        return
        
    if convert_to_runtime(tool_obj) == null:
        busy = false
        return
    
    var action_name := prop_name.capitalize()
    _buffer.push_action(__settings.call_action_template % action_name, runtime)
    busy = false


func _call_callable_impl(arg_count: int, to_call: Callable) -> Variant:
    if arg_count == 0: return await to_call.call()
    elif arg_count == 1: return await to_call.call(_get_helper(runtime))
    return null


func call_rlink_button(prop_name: StringName) -> void:
    if check_valid(): return
    if busy: return
    var to_call := tool_obj.get(prop_name) as RLinkButton
    if to_call == null:
        push_error("ValidRLink: '%s' expected RLinkButton [rlink_data.call_rlink_button]" % prop_name)
        return
    to_call.set_object(tool_obj)
        
    var final_count := to_call.get_arg_count()
    if final_count < 0 or final_count > 1:
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_rlink_button]" % to_call.callable_method_name)
        return
    
    busy = true
    if convert_to_tool(runtime) == null:
        busy = false
        return
        
    var call_res: Variant = await _call_rlink_button_impl(final_count, to_call)
    if to_call.needs_check and not is_same(call_res, true):
        busy = false
        return

    if convert_to_runtime(tool_obj) == null:
        busy = false
        return
    
    var action_name := to_call.text if to_call.text else prop_name.capitalize()
    _buffer.push_action(__settings.call_action_template % action_name, runtime)
    busy = false


func _call_rlink_button_impl(arg_count: int, to_call: RLinkButton) -> Variant:
    if arg_count == 0: return await to_call.rlink_callv_await([])
    elif arg_count == 1: return await to_call.rlink_callv_await([_get_helper(runtime)])
    return null


func call_rlink_button_cs(prop_name: StringName) -> Variant:
    if check_valid(): return
    if busy: return
    var to_call := tool_obj.get(prop_name) as RefCounted
    if to_call == null or to_call.get_script() != __context.csharp_button_script:
        push_error("ValidRLink: '%s' expected RLinkButtonCS [rlink_data.call_rlink_button_cs]" % prop_name)
        return
    to_call.SetObject(tool_obj)
    
    var final_count: int = to_call.GetArgCount()
    const CSharpAwaitable = 4
    
    # Going to add CancellationToken
    if to_call.MethodType == CSharpAwaitable:
        final_count -= 1
    if final_count < 0 or final_count > 1:
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_rlink_button_cs]" % to_call.CallableMethodName)
        return
    
    busy = true
    if convert_to_tool(runtime) == null:
        busy = false
        return
    
    var signal_var: Signal = _call_rlink_button_cs_impl(final_count, to_call)
    signal_var.connect(_call_rlink_button_cs_continue.bind(to_call.get_instance_id(), prop_name), CONNECT_ONE_SHOT)
    return signal_var
        

func _call_rlink_button_cs_impl(arg_count: int, to_call: RefCounted) -> Variant:
    if arg_count == 0: return to_call.RLinkCallvAwait([])
    elif arg_count == 1: return to_call.RLinkCallvAwait([_get_helper(runtime)])
    return null


func _call_rlink_button_cs_continue(result: Variant, to_call_id: int, prop_name: String) -> void:
    if check_valid(): return
    
    var to_call: RefCounted = instance_from_id(to_call_id)
    if to_call == null:
        push_error("ValidRLink: Idk, shouldn't happen [rlink_data._call_rlink_button_cs_continue]")
        busy = false
        return

    if to_call.NeedsCheck and not is_same(result, true):
        busy = false
        return
    
    if convert_to_runtime(tool_obj) == null:
        busy = false
        return
    
    var action_name: String = to_call.Text if to_call.Text else prop_name.capitalize()
    _buffer.push_action(__settings.call_action_template % action_name, runtime)
    busy = false


func _get_helper(object: Object) -> RefCounted:
    var script: Script = object.get_script()
    var rlink: RefCounted = null
    if script != null and _helper_cs != null and script.get_class() == "CSharpScript":
        rlink = _helper_cs
    else:
        rlink = _helper
    return rlink


#region: RLink connection
func rlink_is_pair_valid(obj: Object, delete_if_invalid: bool) -> bool:
    if obj == null: return false
    var obj_id := obj.get_instance_id()
    
    # obj is placeholder
    var tool_id := __map.tool_id_from_id(obj_id)
    if tool_id != 0:
        if is_instance_id_valid(tool_id): return true
        
        __map.erase_pair_id(obj_id, tool_id)
        return false
    
    # obj is tool_obj
    tool_id = obj_id
    obj_id = __map.runtime_id_from_id(tool_id)
    if obj_id != 0:
        var runtime_obj := instance_from_id(obj_id)
        if runtime_obj != null:
            if runtime_obj is Node and !runtime_obj.is_inside_tree():
                __map.erase_pair_id(obj_id, tool_id)
                if delete_if_invalid: obj.queue_free()
                return false
            return true
        
        __map.erase_pair_id(obj_id, tool_id)
        if delete_if_invalid: obj.queue_free()
        return false
    return false


func rlink_add_changes(object: Object, property: StringName, old_value: Variant, value: Variant) -> void:
    var runtime_obj: Object = __conv_to_runtime._convert_value(_buffer, object)
    if runtime_obj == null: return
    var old_value_runtime: Variant = __conv_to_runtime._convert_value(_buffer, old_value, 1, runtime_obj)
    var new_value_runtime: Variant = __conv_to_runtime._convert_value(_buffer, value, 1, runtime_obj)
    _buffer.object_add_changes(runtime_obj, property, old_value_runtime, new_value_runtime)
    _buffer.has_changes = true
    

func rlink_add_do_method(object: Object, method: StringName, args: Array) -> void:
    if not is_native_resource(object):
        push_error("ValidRLink: This method only supports native resources [rlink_data.add_do_method]")
        return
    var args_runtime: Array = __conv_to_runtime._convert_value(_buffer, args, 1, object)
    args_runtime.push_front(method)
    args_runtime.push_front(object)
    _buffer.add_do_method(args_runtime)


func rlink_add_undo_method(object: Object, method: StringName, args: Array) -> void:
    if not is_native_resource(object):
        push_error("ValidRLink: This method only supports native resources [rlink_data.add_undo_method]")
        return
    var args_runtime: Array = __conv_to_runtime._convert_value(_buffer, args, 1, object)
    args_runtime.push_front(method)
    args_runtime.push_front(object)
    _buffer.add_undo_method(args_runtime)
    
    
func rlink_convert_to_tool(runtime_obj: Object, custom_depth: int) -> Object:
    return __conv_to_tool._convert_value(_buffer, runtime_obj, custom_depth)
    
    
func rlink_convert_to_runtime(tool_obj_in: Object, custom_depth: int, track_instances: bool) -> Object:
    var old := _buffer.track_tool_instances
    _buffer.track_tool_instances = track_instances
    var value: Object = __conv_to_runtime._convert_value(_buffer, tool_obj_in, custom_depth)
    _buffer.track_tool_instances = old
    return value


func rlink_is_tool_object(object: Object) -> bool:
    return __map.is_tool(object)
    
    
func rlink_is_runtime_object(object: Object) -> bool:
    return __map.is_runtime(object)
    
    
func rlink_add_child_to(node: Node, child: Node) -> void:
    _buffer.node_add_child(node, child)
    
    
func rlink_remove_child_from(node: Node, child: Node) -> void:
    _buffer.node_remove_child(node, child)
    
    
func rlink_get_tool(runtime_obj: Object) -> Object:
    return __map.tool_from_obj(runtime_obj)
    

func rlink_get_runtime(tool_obj_in: Object) -> Object:
    return __map.runtime_from_obj(tool_obj_in)
    
    
func rlink_signal_connect(signal_value: Signal, callable: Callable, bindv_args: Array, unbind: int) -> void:
    if not callable.is_standard():
        push_error("ValidRLink: Only supports connecting standart callables to signals [rlink_data.signal_connect]")
        return

    var runtime_signal := get_runtime_signal(signal_value)
    var runtime_callable: Variant = get_runtime_callable(callable, bindv_args, unbind)
    if runtime_callable == null: return
    if runtime_signal.is_null() or runtime_callable.is_null():
        push_error("ValidRLink: Runtime pair is not registered [rlink_data.signal_connect]")
        return
    _buffer.signal_add_connect(runtime_signal, runtime_callable)


func rlink_signal_disconnect(signal_value: Signal, callable: Callable, bindv_args: Array, unbind: int) -> void:
    if not callable.is_standard():
        push_error("ValidRLink: Only supports connecting standart callables to signals [rlink_data.signal_disconnect]")
        return
    
    var runtime_signal := get_runtime_signal(signal_value)
    var runtime_callable: Variant = get_runtime_callable(callable, bindv_args, unbind)
    if runtime_callable == null: return
    if runtime_signal.is_null() or runtime_callable.is_null():
        push_error("ValidRLink: Runtime pair is not registered [rlink_data.signal_disconnect]")
        return
    _buffer.signal_add_disconnect(runtime_signal, runtime_callable)


func rlink_signal_is_connected(signal_value: Signal, callable: Callable, bindv_args: Array, unbind: int) -> bool:
    if not callable.is_standard():
        push_error("ValidRLink: Only supports connecting standart callables to signals [rlink_data.signal_is_connected]")
        return false
    
    var runtime_signal := get_runtime_signal(signal_value)
    var runtime_callable: Variant = get_runtime_callable(callable, bindv_args, unbind)
    if runtime_callable == null: return false
    if runtime_signal.is_null() or runtime_callable.is_null():
        push_error("ValidRLink: Runtime pair is not registered [rlink_data.signal_is_connected]")
        return false
    
    return runtime_signal.is_connected(runtime_callable)


func get_runtime_signal(signal_value: Signal) -> Signal:
    var signal_object := signal_value.get_object()
    if not is_native_resource(signal_object):
        signal_object = __map.runtime_from_obj(signal_object)
        
    if signal_object == null:
        return Signal()
        
    return Signal(signal_object, signal_value.get_name())


func get_runtime_callable(callable: Callable, bindv_args: Array, unbind: int) -> Variant:
    if not callable.is_valid():
        push_error("ValidRLink: Callable must be valid to be converted [rlink_data.get_runtime_callable]")
        return null
    var callable_object := callable.get_object()
    if not is_native_resource(callable_object):
        callable_object = __map.runtime_from_obj(callable_object)
        
    if callable_object == null:
        return Callable()
        
    var runtime_callable := Callable(callable_object, callable.get_method())
    if bindv_args.size() > 0:
        var run_args: Array = __conv_to_runtime._convert_value(_buffer, bindv_args, 1, callable_object)
        if _buffer.converter_converted_object:
            push_error("ValidRLink: Binding object persistingly is not supported [rlink_data.get_runtime_callable]")
            return null
        runtime_callable = runtime_callable.bindv(run_args)
    if unbind > 0: runtime_callable = runtime_callable.unbind(unbind)
    return runtime_callable
    

func is_native_resource(value: Variant) -> bool:
    return value is Resource and value.get_script() == null
    
#endregion
