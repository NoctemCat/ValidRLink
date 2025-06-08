@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const Compat = Context.Compatibility

const ScanResult = preload("./scan_result.gd")
const ScanCache = preload("./scan_cache.gd")
const RLinkMap = preload("./rlink_map.gd")

const RLinkScript = preload(Context.RUNTIME_PATH + "rlink.gd")

signal busy_changed(status: bool, id: int)
signal converted_object(id: int)

var __context: Context
var __settings: Settings
var __compat: Compat
var __undo_redo: EditorUndoRedoManager
var __scan_cache: ScanCache
var __map: RLinkMap
var __conv_to_tool: RefCounted
var __conv_to_runtime: RefCounted

var _object_id: int
var runtime: Object:
    get: return instance_from_id(_object_id)
var tool_obj: Object ## Keeps RefCounted alive
var _result: ScanResult
var _helper: RefCounted
var _validate_queued: String
var _busy: bool:
    get: return _busy
    set(value):
        _busy = value
        if !value and _validate_queued != "":
            var copy := _validate_queued
            _validate_queued = ""
            validate_changes(copy)
        busy_changed.emit(_busy, get_instance_id())

#region: Converter State
var max_depth: int
var visit: Dictionary
var script_error := false
var converter_converted_object := false
var has_changes := false
#endregion

#region: Buffer State
var _changes: Array
var _remove_metas: Array
var _add_groups: Dictionary
var _erase_groups: Dictionary
var _add_children: Dictionary
var _remove_children: Dictionary
var _connect_signals: Array
var _disconnect_signals: Array
var _do_methods: Array
var _undo_methods: Array
#endregion


func _init(context: Context, object: Object, in_result: ScanResult) -> void:
    __context = context
    __settings = context.settings
    __compat = context.compat
    __undo_redo = context.undo_redo
    __scan_cache = context.scan_cache
    __map = context.rlink_map
    __conv_to_tool = context.converter_to_tool
    __conv_to_runtime = context.converter_to_runtime
    
    _object_id = object.get_instance_id()
    _result = in_result
    max_depth = _result.max_depth
    
    tool_obj = __conv_to_tool.convert_value(self, runtime)
    if (
        object.get_script() != null
        and object.get_script().get_class() == "CSharpScript"
    ):
        _helper = context.csharp_helper_script.new(self)
    else:
        _helper = RLinkScript.new(self)
    __context.cancel_tasks.connect(_on_cancel_tasks)


func _on_cancel_tasks() -> void:
    discard_changes()
    _busy = false


func reflect_to_tool(object: Object = null, depth: int = 0) -> Object:
    if object == null: object = runtime
    return __conv_to_tool.convert_value(self, object, depth)
    
    
func reflect_to_runtime(object: Object = null, depth: int = 0) -> Object:
    if object == null: object = tool_obj
    return __conv_to_runtime.convert_value(self, object, depth)
 

func validate_changes(object_name: String) -> void:
    if _busy:
        _validate_queued = object_name
        return
    if not _result.has_validate: return
    
    _busy = true
    if reflect_to_tool() == null: return
    
    if _result.validate_check_return:
        var call_res: Variant = _call_validate(tool_obj)
        if discard_if_same(is_same(call_res, true), false): return
    else:
        _call_validate(tool_obj)
        
    converted_object.emit(_object_id)
    if discard_if_same(reflect_to_runtime(), null): return
    if has_changes and __settings.validate_use_history:
        create_action("Validate '%s'" % object_name, UndoRedo.MERGE_ALL, runtime)
        flush_changes()
        commit_action()
    elif has_changes:
        flush_changes(false)
    else:
        discard_changes()
    _busy = false


func _call_validate(call_obj: Object) -> Variant:
    if _result.validate_arg_count == 0: return call_obj.call(_result.validate_name)
    elif _result.validate_arg_count == 1: return call_obj.call(_result.validate_name, _helper)
    else: push_error("ValidRLink: Validate function takes maximum 1 argument [rlink_data._call_validate]")
    return null
    
    
func call_callable(prop_name: StringName) -> void:
    if _busy: return
    var to_call: Callable = tool_obj.get(prop_name)
    if to_call == null:
        push_error("ValidRLink: '%s' expected Callable [rlink_data.call_callable]" % prop_name)
        return
    
    var info: ScanResult.MethodInfo = null
    var arg_count: int
    if to_call.is_standard():
        info = _result.get_method_info(to_call.get_method())
        arg_count = info.arg_count
    elif __compat.callable_arg_count_available():
        arg_count = __compat.get_arg_count(to_call)
    else:
        arg_count = 1 # just passing helper if the number is unknown
    if arg_count < 0 or arg_count > 1:
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_callable]" % prop_name)
        return
        
    _busy = true
    if reflect_to_tool() == null: return
    if info != null and info.check_return:
        var call_res: Variant = await _call_callable_impl(arg_count, to_call)
        #var call_res: Variant = _call_callable_impl(arg_count, to_call)
        if discard_if_same(is_same(call_res, true), false): return
    else:
        await _call_callable_impl(arg_count, to_call)
        #_call_callable_impl(arg_count, to_call)
        
    converted_object.emit(_object_id)
    if discard_if_same(reflect_to_runtime(), null): return
    
    var action_name := prop_name.capitalize()
    create_action(__settings.call_action_template % action_name)
    flush_changes()
    commit_action()
    _busy = false


func _call_callable_impl(arg_count: int, to_call: Callable) -> Variant:
    if arg_count == 0: return await to_call.call()
    elif arg_count == 1: return await to_call.call(_helper)
    return null


func call_rlink_button(prop_name: StringName) -> void:
    if _busy: return
    var to_call := tool_obj.get(prop_name) as RLinkButton
    if to_call == null:
        push_error("ValidRLink: '%s' expected RLinkButton [rlink_data.call_rlink_button]" % prop_name)
        return
    to_call.set_object(tool_obj)
        
    # var info := _result.get_method_info(to_call.callable_method_name)
    var final_count := to_call.get_arg_count()
    if final_count < 0 or final_count > 1:
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_rlink_button]" % to_call.callable_method_name)
        return
    
    _busy = true
    if reflect_to_tool() == null: return
    if to_call.needs_check:
        var call_res: Variant = await _call_rlink_button_impl(final_count, to_call)
        if discard_if_same(is_same(call_res, true), false): return
    else:
        await _call_rlink_button_impl(final_count, to_call)
    
    converted_object.emit(_object_id)
    if discard_if_same(reflect_to_runtime(), null): return
    
    var action_name := to_call.text if to_call.text else prop_name.capitalize()
    create_action(__settings.call_action_template % action_name)
    flush_changes()
    commit_action()
    _busy = false


func _call_rlink_button_impl(arg_count: int, to_call: RLinkButton) -> Variant:
    if arg_count == 0: return await to_call.rlink_callv_await([])
    elif arg_count == 1: return await to_call.rlink_callv_await([_helper])
    return null

func print_res(res: Variant) -> void:
    prints("!!gg", res)

func cancel(res: Resource) -> void:
    res.CancelTask()
    _busy = false


func call_rlink_button_cs(prop_name: StringName) -> void:
    prints("here", _busy)
    if _busy: return
    var to_call := tool_obj.get(prop_name) as RLinkButtonCS
    if to_call == null:
        push_error("ValidRLink: '%s' expected RLinkButtonCS [rlink_data.call_rlink_button_cs]" % prop_name)
        return
    to_call.SetObject(tool_obj)
    prints("leaked ", runtime, tool_obj)
    
    # to_call.Completed.connect(print_res, CONNECT_ONE_SHOT)
    # var info := _result.get_method_info(to_call.CallableMethodName)
    var final_count: int = to_call.GetArgCount()
    const CSharpAsyncDelegate = 3
    const CSharpAsyncAwaitable = 4
    
    # Going to add CancellationToken
    if to_call.MethodType == CSharpAsyncDelegate or to_call.MethodType == CSharpAsyncAwaitable:
        final_count -= 1
    if final_count < 0 or final_count > 1:
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_rlink_button_cs]" % to_call.CallableMethodName)
        return
    
    _busy = true
    if reflect_to_tool() == null: return
    
    var signal_var: Signal = _call_rlink_button_cs_impl(final_count, to_call)
    signal_var.connect(call_rlink_button_cs_continue.bind(to_call.get_instance_id(), prop_name), CONNECT_ONE_SHOT)
    

func _call_rlink_button_cs_impl(arg_count: int, to_call: RLinkButtonCS) -> Variant:
    if arg_count == 0: return to_call.RLinkCallvAwait([])
    elif arg_count == 1: return to_call.RLinkCallvAwait([_helper])
    return null


func call_rlink_button_cs_continue(result: Variant, to_call_id: int, prop_name: String) -> void:
    var to_call: RefCounted = instance_from_id(to_call_id)
    if to_call == null:
        push_error("ValidRLink: Idk, shouldn't happen [rlink_data.call_rlink_button_cs_continue]")
        discard_if_same(true, true)
        return

    if to_call.NeedsCheck:
        # var call_res: Variant = await _call_rlink_button_cs_impl(final_count, to_call)
        prints("here2", to_call, result)
        if discard_if_same(is_same(result, true), false): return
    # else:
    #     await _call_rlink_button_cs_impl(final_count, to_call)
    
    # prints("here3", call_res)
    converted_object.emit(_object_id)
    if discard_if_same(reflect_to_runtime(), null): return
    # prints("here4", call_res)
    var action_name: String = to_call.Text if to_call.Text else prop_name.capitalize()
    create_action(__settings.call_action_template % action_name)
    flush_changes()
    commit_action()
    prints("here5")
    _busy = false


func discard_if_same(value1: Variant, value2: Variant) -> bool:
    if is_same(value1, value2):
        discard_changes()
        _busy = false
        return true
    return false


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
    var runtime_obj: Object = __conv_to_runtime.convert_value(self, object)
    if runtime_obj == null: return
    object_add_changes(runtime_obj, property, __conv_to_runtime.convert_value(self, old_value, 1), __conv_to_runtime.convert_value(self, value, 1))
    

func rlink_add_do_method(object: Object, method: StringName, args: Array) -> void:
    if not is_native_resource(object):
        push_error("ValidRLink: This method only supports native resources [rlink_data.add_do_method]")
        return
    var args_runtime: Array = __conv_to_runtime.convert_value(self, args, 1)
    args_runtime.push_front(method)
    args_runtime.push_front(object)
    _do_methods.push_back(args_runtime)


func rlink_add_undo_method(object: Object, method: StringName, args: Array) -> void:
    if not is_native_resource(object):
        push_error("ValidRLink: This method only supports native resources [rlink_data.add_undo_method]")
        return
    var args_runtime: Array = __conv_to_runtime.convert_value(self, args, 1)
    args_runtime.push_front(method)
    args_runtime.push_front(object)
    _undo_methods.push_back(args_runtime)
    
    
func rlink_convert_to_tool(runtime_obj: Object, custom_depth: int) -> Object:
    return __conv_to_tool.convert_value(self, runtime_obj, custom_depth)
    
    
func rlink_convert_to_runtime(tool_obj_in: Object, custom_depth: int, track_instances: bool) -> Object:
    return __conv_to_runtime.convert_value(self, tool_obj_in, custom_depth, track_instances)


func rlink_is_tool_object(object: Object) -> bool:
    return __map.is_tool(object)
    
    
func rlink_is_runtime_object(object: Object) -> bool:
    return __map.is_runtime(object)
    
    
func rlink_add_child_to(node: Node, child: Node) -> void:
    node_add_child(node, child)
    
    
func rlink_remove_child_from(node: Node, child: Node) -> void:
    node_remove_child(node, child)
    
    
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
    signal_add_connect(runtime_signal, runtime_callable)


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
    signal_add_disconnect(runtime_signal, runtime_callable)


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
        var run_args: Array = __conv_to_runtime.convert_value(self, bindv_args, 1)
        if converter_converted_object:
            push_error("ValidRLink: Binding object persistingly is not supported [rlink_data.get_runtime_callable]")
            return null
        runtime_callable = runtime_callable.bindv(run_args)
    if unbind > 0: runtime_callable = runtime_callable.unbind(unbind)
    return runtime_callable
    

func is_native_resource(value: Variant) -> bool:
    return value is Resource and value.get_script() == null
#endregion


#region: Changes buffer
func object_add_changes(object: Object, property: StringName, old_value: Variant, new_value: Variant) -> void:
    _changes.push_back(object)
    _changes.push_back(property)
    _changes.push_back(old_value)
    _changes.push_back(new_value)
    has_changes = true


func object_remove_meta(object: Object, property: StringName) -> void:
    _remove_metas.push_back(object)
    _remove_metas.push_back(property)
    has_changes = true


func node_add_groups(node: Node, groups: Array[StringName]) -> void:
    var arr: Variant = _add_groups.get(node)
    if arr == null:
        arr = Array([], TYPE_STRING_NAME, &"", null)
        _add_groups[node] = arr
    arr.append_array(groups)
    has_changes = true


func node_remove_groups(node: Node, groups: Array[StringName]) -> void:
    var arr: Variant = _erase_groups.get(node)
    if arr == null:
        arr = Array([], TYPE_STRING_NAME, &"", null)
        _erase_groups[node] = arr
    arr.append_array(groups)
    has_changes = true
    
    
func node_add_child(node: Node, child: Node) -> void:
    var arr: Variant = _add_children.get(node)
    if arr == null:
        arr = Array([], TYPE_OBJECT, &"Node", null)
        _add_children[node] = arr
    arr.append(child)
    has_changes = true


func node_remove_child(node: Node, child: Node) -> void:
    var arr: Variant = _remove_children.get(node)
    if arr == null:
        arr = Array([], TYPE_OBJECT, &"Node", null)
        _remove_children[node] = arr
    arr.append(child)
    has_changes = true


func signal_add_connect(signal_value: Signal, callable: Callable) -> void:
    _connect_signals.push_back(signal_value)
    _connect_signals.push_back(callable)
    has_changes = true


func signal_add_disconnect(signal_value: Signal, callable: Callable) -> void:
    _disconnect_signals.push_back(signal_value)
    _disconnect_signals.push_back(callable)
    has_changes = true


func flush_changes(use_history: bool = true) -> void:
    if __undo_redo == null: use_history = false
    
    if use_history: _flush_changes_history()
    else: _flush_changes_direct()
    
    var needs_updating := _connect_signals.size() > 0 or _disconnect_signals.size() > 0
    _clear_buffer()
    if needs_updating: _update_tree()


## Made a separate method, so that if for some reason any of them failed, 
## clear functions after it still got called
func _flush_changes_history() -> void:
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        __undo_redo.add_undo_property(_changes[i], _changes[i + 1], _changes[i + 2])
        
    for i in range(0, _remove_metas.size(), 2):
        var object: Object = _remove_metas[i]
        var meta: StringName = _remove_metas[i + 1]
        __undo_redo.add_undo_method(object, &"set_meta", meta, object.get_meta(meta))
    
    @warning_ignore("untyped_declaration")
    for node in _add_children:
        @warning_ignore("untyped_declaration")
        for child in _add_children[node]:
            __undo_redo.add_do_method(node, &"add_child", child, true)
            if node.is_inside_tree():
                __undo_redo.add_do_method(child, &"set_owner", node.owner if node.owner != null else node)
            __undo_redo.add_do_reference(child)
            __undo_redo.add_undo_method(node, &"remove_child", child)

    @warning_ignore("untyped_declaration")
    for node in _remove_children:
        @warning_ignore("untyped_declaration")
        for child in _remove_children[node]:
            __undo_redo.add_do_method(node, &"remove_child", child)
            __undo_redo.add_undo_method(node, &"add_child", child, true)
            if node.is_inside_tree():
                var owner: Node = node.owner if node.owner != null else node
                var owned: Array[Node]
                _get_owned_by(owner, child, owned)
                __undo_redo.add_undo_method(self, &"_set_owners", owner, owned)
            __undo_redo.add_undo_method(node, &"move_child", child, child.get_index())
            __undo_redo.add_undo_reference(child)
            
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        __undo_redo.add_do_property(_changes[i], _changes[i + 1], _changes[i + 3])
        
    for i in range(0, _remove_metas.size(), 2):
        var object: Object = _remove_metas[i]
        var meta: StringName = _remove_metas[i + 1]
        __undo_redo.add_do_method(object, &"remove_meta", meta)
        
    for i in range(0, _do_methods.size(), 1):
        __undo_redo.callv(&"add_do_method", _do_methods[i])
        
    for i in range(0, _undo_methods.size(), 1):
        __undo_redo.callv(&"add_undo_method", _undo_methods[i])
    
    @warning_ignore("untyped_declaration")
    for node in _add_groups:
        @warning_ignore("untyped_declaration")
        for group in _add_groups[node]:
            __undo_redo.add_do_method(node, &"add_to_group", group, true)
            __undo_redo.add_undo_method(node, &"remove_from_group", group)

    @warning_ignore("untyped_declaration")
    for node in _erase_groups:
        @warning_ignore("untyped_declaration")
        for group in _erase_groups[node]:
            __undo_redo.add_do_method(node, &"remove_from_group", group)
            __undo_redo.add_undo_method(node, &"add_to_group", group, true)
    
    for i in range(0, _connect_signals.size(), 2):
        var signal_value: Signal = _connect_signals[i]
        var callable: Callable = _connect_signals[i + 1]

        __undo_redo.add_do_method(signal_value.get_object(), &"connect", signal_value.get_name(), callable, Object.CONNECT_PERSIST)
        __undo_redo.add_undo_method(signal_value.get_object(), &"disconnect", signal_value.get_name(), callable)
        
    for i in range(0, _disconnect_signals.size(), 2):
        var signal_value: Signal = _disconnect_signals[i]
        var callable: Callable = _disconnect_signals[i + 1]
        
        __undo_redo.add_do_method(signal_value.get_object(), &"disconnect", signal_value.get_name(), callable)
        __undo_redo.add_undo_method(signal_value.get_object(), &"connect", signal_value.get_name(), callable, Object.CONNECT_PERSIST)


func _flush_changes_direct() -> void:
    @warning_ignore("untyped_declaration")
    for node in _add_children:
        @warning_ignore("untyped_declaration")
        for child in _add_children[node]:
            node.add_child(child, true)
            if node.is_inside_tree():
                child.owner = node.owner if node.owner != null else node

    @warning_ignore("untyped_declaration")
    for node in _remove_children:
        @warning_ignore("untyped_declaration")
        for child in _remove_children[node]:
            node.remove_child(child)
            
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        _changes[i].set(_changes[i + 1], _changes[i + 3])
        
    for i in range(0, _remove_metas.size(), 2):
        var object: Object = _remove_metas[i]
        object.remove_meta(_remove_metas[i + 1])
        
    for i in range(0, _do_methods.size(), 1):
        var args: Array = _do_methods[i]
        var object: Object = args.pop_front()
        var method: StringName = args.pop_front()
        object.callv(method, args)

    @warning_ignore("untyped_declaration")
    for node in _add_groups:
        @warning_ignore("untyped_declaration")
        for group in _add_groups[node]:
            node.add_to_group(group, true)
    
    @warning_ignore("untyped_declaration")
    for node in _erase_groups:
        @warning_ignore("untyped_declaration")
        for group in _erase_groups[node]:
            node.remove_from_group(group)
    
    for i in range(0, _connect_signals.size(), 2):
        var signal_value: Signal = _connect_signals[i]
        var callable: Callable = _connect_signals[i + 1]
        signal_value.connect(callable, Object.CONNECT_PERSIST)
        
    for i in range(0, _disconnect_signals.size(), 2):
        var signal_value: Signal = _disconnect_signals[i]
        var callable: Callable = _disconnect_signals[i + 1]
        signal_value.disconnect(callable)


func discard_changes() -> void:
    @warning_ignore("untyped_declaration")
    for node in _add_children:
        @warning_ignore("untyped_declaration")
        for child in _add_children[node]:
            child.queue_free()
    _clear_buffer()
   

func _clear_buffer() -> void:
    _add_children.clear()
    _remove_children.clear()
    _changes.clear()
    _remove_metas.clear()
    _do_methods.clear()
    _undo_methods.clear()
    _add_groups.clear()
    _erase_groups.clear()
    _connect_signals.clear()
    _disconnect_signals.clear()
    has_changes = false


func commit_action(execute: bool = true) -> void:
    if __undo_redo != null:
        __undo_redo.commit_action(execute)
    #__undo_redo.add_do_method()
    
    
func create_action(
    name: String,
    merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE,
    custom_context: Object = null,
    backward_undo_ops: bool = false
) -> void:
    if custom_context == null:
        custom_context = runtime
    if __undo_redo != null:
        __undo_redo.create_action(name, merge_mode, custom_context, backward_undo_ops)
    

# Pretty ugly workaround
func _update_tree() -> void:
    if __compat.engine_version >= 0x040400:
        return
    @warning_ignore("unsafe_property_access")
    var root: Node = Engine.get_main_loop().edited_scene_root
    if root != null:
        var temp := Node.new()
        root.add_child(temp)
        temp.owner = root
        temp.queue_free()
        
        
func _get_owned_by(owner: Node, node: Node, owned: Array[Node]) -> void:
    if owner == node.owner:
        owned.push_back(node)
    
    for idx in node.get_child_count():
        _get_owned_by(owner, node.get_child(idx), owned)


func _set_owners(owner: Node, owned: Array[Node]) -> void:
    for node in owned:
        node.owner = owner
#endregion
