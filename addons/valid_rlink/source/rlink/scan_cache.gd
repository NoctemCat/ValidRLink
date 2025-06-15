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
    if cached == null or cached.script_id != get_script_id(object):
        cached = ScanResult.new(__ctx, object)
        _results_cache[object_id] = cached
    return cached


func clear() -> void:
    _results_cache.clear()


func get_script_id(object: Object) -> int:
    var script: Script = object.get_script()
    return script.get_instance_id() if script != null else 0