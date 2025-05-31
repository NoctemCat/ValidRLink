@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const Compat = Context.Compatibility

const ScanResult = preload("./scan_result.gd")
const ScanCache = preload("./scan_cache.gd")
const RLinkMap = preload("./rlink_map.gd")
const RLinkUndoRedo = preload("./rlink_undo_redo.gd")
const ConverterToTool = preload("./converter_to_tool.gd")
const ConverterToRuntime = preload("./converter_to_runtime.gd")

const Helper = preload("./../helpers/rlink.gd")
var __settings: Settings
var __compat: Compat
var __undo_redo: RLinkUndoRedo
var __scan_cache: ScanCache
var __map: RLinkMap
var __conv_tool: ConverterToTool
var __conv_runtime: ConverterToRuntime

signal converted_object(id: int)

var object_id: int
var _result: ScanResult
var _editor_holder: Object
var register_tool_instances := false

var has_reset: bool:
    get: return _result.has_reset
var has_validate: bool:
    get: return _result.has_validate

#var _visit: Dictionary
#var _script_error := false
var _helper: RefCounted

#var _changes: Array
#var _changes_do_refs: Array
#var _changes_undo_refs: Array
#var _alive: Dictionary


func _init(context: Context, object: Object, in_result: ScanResult) -> void:
    __settings = context.settings
    __compat = context.compat
    __undo_redo = context.undo_redo
    __scan_cache = context.scan_cache
    __map = context.rlink_map
    __conv_tool = context.converter_to_tool
    __conv_runtime = context.converter_to_runtime
    
    object_id = object.get_instance_id()
    _result = in_result
    
    _editor_holder = __conv_tool.convert_value(object)
    if (
        __settings.csharp_use_native_helper
        and object.get_script() != null
        and object.get_script().get_class() == "CSharpScript"
    ):
        _helper = context.csharp_helper_script.new(self)
    else:
        _helper = Helper.new(self)


func validate_values(object_name: String) -> void:
    if not _result.has_validate: return
    
    var runtime := instance_from_id(object_id)
    var tool: Object = __conv_tool.convert_value(runtime)
    if tool == null:
        return
    
    __undo_redo.create_action("Validate '%s'" % object_name, UndoRedo.MERGE_ENDS, runtime)
    _call_validate(tool, runtime)
    converted_object.emit(object_id)
    __conv_runtime.convert_value(tool)
    __undo_redo.flush_changes()
    __undo_redo.commit_action()


func _call_validate(tool_obj: Object, _obj: Object) -> void:
    if _result.validate_arg_count == 0: tool_obj.call(_result.validate_name)
    elif _result.validate_arg_count == 1: tool_obj.call(_result.validate_name, _helper)
    else: push_error("ValidRLink: Validate function takes maximum 1 argument [rlink_data._call_validate]")
    
    
func call_callable(prop_name: String) -> void:
    var runtime := instance_from_id(object_id)
    if (
        __settings.engine_version <= 0x040100
        and runtime.get_script() != null
        and runtime.get_script().get_class() == "CSharpScript"
    ):
        push_error("ValidRLink: Callable C# exports are not supported on 4.1 [rlink_data.call_callable]")
        return
        
    var tool: Object = __conv_tool.convert_value(runtime)
    if tool == null:
        return
    var to_call := tool.get(prop_name) as Callable
    if to_call == null:
        push_error("ValidRLink: '%s' expected Callable [rlink_data.call_callable]" % prop_name)
        return
    
    var res := __scan_cache.get_search(runtime)
    __undo_redo.create_action(prop_name.capitalize(), UndoRedo.MERGE_DISABLE, runtime)
    
    var arg_count: int
    var arg_count_got: bool = false
    if to_call.is_standard():
        arg_count = res.get_arg_count(to_call.get_method())
        arg_count_got = true
    elif __compat.callable_arg_count_available():
        arg_count = __compat.get_arg_count(to_call)
        arg_count_got = true
    
    if not arg_count_got: to_call.call(_helper)
    elif arg_count == 0: to_call.call()
    elif arg_count == 1: to_call.call(_helper)
    else:
        __undo_redo.commit_action()
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_callable]" % prop_name)
        return
        
    converted_object.emit(object_id)
    __conv_runtime.convert_value(tool)
    __undo_redo.flush_changes()
    __undo_redo.commit_action()



func call_rlink_button(prop_name: String) -> void:
    var runtime := instance_from_id(object_id)
    var tool: Object = __conv_tool.convert_value(runtime)
    if tool == null:
        return
    var to_call := tool.get(prop_name) as RLinkButton
    if to_call == null:
        push_error("ValidRLink: '%s' expected RLinkButton [rlink_data.call_rlink_button]" % prop_name)
        return
    to_call.set_object(tool)
        
    var res := __scan_cache.get_search(runtime)
    var arg_count := res.get_arg_count(to_call.method_name)
    var final_count := arg_count - to_call.bind_arg_count + to_call.unbind_next
    
    __undo_redo.create_action(to_call.text if to_call.text else prop_name.capitalize(), UndoRedo.MERGE_DISABLE, runtime)
    if final_count == 0: to_call.rlink_call()
    elif final_count == 1: to_call.rlink_call(_helper)
    else:
        __undo_redo.commit_action()
        push_error("ValidRLink: '%s' takes maximum 1 argument [rlink_data.call_rlink_button]" % to_call.method_name)
        return
    
    converted_object.emit(object_id)
    __conv_runtime.convert_value(tool)
    __undo_redo.flush_changes()
    __undo_redo.commit_action()

    
func is_pair_valid(obj: Object, delete_if_invalid: bool) -> bool:
    if obj == null: return false
    var obj_id := obj.get_instance_id()
    
    # obj is placeholder
    var tool_id := __map.tool_id_from_id(obj_id)
    if tool_id != 0:
        if is_instance_id_valid(tool_id): return true
        
        __map.erase_pair_id(obj_id, tool_id)
        return false
    
    # obj is tool
    tool_id = obj_id
    obj_id = __map.runtime_id_from_id(tool_id)
    if obj_id != 0:
        var runtime := instance_from_id(obj_id)
        if runtime != null:
            if runtime is Node and !runtime.is_inside_tree():
                __map.erase_pair_id(obj_id, tool_id)
                if delete_if_invalid: obj.queue_free()
                return false
            return true
        
        __map.erase_pair_id(obj_id, tool_id)
        if delete_if_invalid: obj.queue_free()
        return false
    return false


func add_do_property(object: Object, property: StringName, value: Variant) -> void:
    var runtime: Object = __conv_runtime.convert_value(object)
    if runtime == null: return
    __undo_redo._undo_redo.add_do_property(runtime, property, __conv_runtime.convert_value(value, 1))
    
    
func add_undo_property(object: Object, property: StringName, value: Variant) -> void:
    var runtime: Object = __conv_runtime.convert_value(object)
    if runtime == null: return
    __undo_redo._undo_redo.add_undo_property(runtime, property, __conv_runtime.convert_value(value, 1))
    

func convert_to_tool(runtime: Object, custom_depth: int) -> Object:
    return __conv_tool.convert_value(runtime, custom_depth)
    
    
func convert_to_runtime(tool: Object, custom_depth: int, track_instances: bool) -> Object:
    return __conv_runtime.convert_value(tool, custom_depth, track_instances)


func is_tool_object(object: Object) -> bool:
    return __map.is_tool(object)
    
    
func is_runtime_object(object: Object) -> bool:
    return __map.is_runtime(object)
    
    
func add_child_to(node: Node, child: Node) -> void:
    __undo_redo.node_add_child(node, child)
    
    
func remove_child_from(node: Node, child: Node) -> void:
    __undo_redo.node_remove_child(node, child)
    
    
func get_tool(runtime: Object) -> Object:
    return __map.tool_from_obj(runtime)
    
    
func get_runtime(tool: Object) -> Object:
    return __map.runtime_from_obj(tool)
    
    
func signal_connect(signal_value: Signal, callable: Callable, bindv_args: Array, unbind: int) -> void:
    if not callable.is_standard():
        push_error("ValidRLink: Only supports connecting standart callables to signals [rlink_data.signal_connect]")
        return

    var runtime_signal := get_runtime_signal(signal_value)
    var runtime_callable := get_runtime_callable(callable, bindv_args, unbind)
    if runtime_signal.is_null() or runtime_callable.is_null():
        push_error("ValidRLink: Runtime pair is not registered [rlink_data.signal_connect]")
        return
        
    __undo_redo.add_connect_signal(runtime_signal, runtime_callable)
    
    
func signal_disconnect(signal_value: Signal, callable: Callable, bindv_args: Array, unbind: int) -> void:
    if not callable.is_standard():
        push_error("ValidRLink: Only supports connecting standart callables to signals [rlink_data.signal_disconnect]")
        return
    
    var runtime_signal := get_runtime_signal(signal_value)
    var runtime_callable := get_runtime_callable(callable, bindv_args, unbind)
    if runtime_signal.is_null() or runtime_callable.is_null():
        push_error("ValidRLink: Runtime pair is not registered [rlink_data.signal_disconnect]")
        return
        
    __undo_redo.add_disconnect_signal(runtime_signal, runtime_callable)


func signal_is_connected(signal_value: Signal, callable: Callable, bindv_args: Array, unbind: int) -> bool:
    if not callable.is_standard():
        push_error("ValidRLink: Only supports connecting standart callables to signals [rlink_data.signal_is_connected]")
        return false
    
    var runtime_signal := get_runtime_signal(signal_value)
    var runtime_callable := get_runtime_callable(callable, bindv_args, unbind)
    if runtime_signal.is_null() or runtime_callable.is_null():
        push_error("ValidRLink: Runtime pair is not registered [rlink_data.signal_is_connected]")
        return false
        
    return runtime_signal.is_connected(runtime_callable)


func get_runtime_signal(signal_value: Signal) -> Signal:
    var signal_object := signal_value.get_object()
    if not is_native_resource(signal_object):
        signal_object = get_runtime(signal_object)
        
    if signal_object == null:
        return Signal()
        
    return Signal(signal_object, signal_value.get_name())


func get_runtime_callable(callable: Callable, bindv_args: Array, unbind: int) -> Callable:
    var callable_object := callable.get_object()
    if not is_native_resource(callable_object):
        callable_object = get_runtime(callable_object)
        
    if callable_object == null:
        return Callable()
        
    var runtime_callable := Callable(callable_object, callable.get_method())
    if bindv_args.size() > 0: runtime_callable = runtime_callable.bindv(__conv_runtime.convert_value(bindv_args, 1))
    if unbind > 0: runtime_callable = runtime_callable.unbind(unbind)
    return runtime_callable
    

static func is_native_resource(value: Variant) -> bool:
    return value is Resource and value.get_script() == null

        
