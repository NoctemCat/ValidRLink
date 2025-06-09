@tool
extends RefCounted

const Context = preload("./../context.gd")
const ScanResult = preload("./scan_result.gd")

var __ctx: Context
var _results_cache: Dictionary


func _init(context: Context) -> void:
    __ctx = context


func get_search(object: Object) -> ScanResult:
    var object_id := object.get_instance_id()
    var cached: ScanResult = _results_cache.get(object_id)
    if cached == null:
        cached = ScanResult.new(__ctx, object)
        _results_cache[object_id] = cached
    return cached


func add_pair(runtime: Object, tool_obj: Object) -> void:
    var runtime_id := runtime.get_instance_id()
    var tool_id := tool_obj.get_instance_id()
    
    var cached: ScanResult = _results_cache.get(runtime_id)
    if cached != null:
        _results_cache[tool_id] = cached
        return
    
    cached = _results_cache.get(tool_id)
    if cached != null:
        _results_cache[runtime_id] = cached


func clear() -> void:
    _results_cache.clear()
