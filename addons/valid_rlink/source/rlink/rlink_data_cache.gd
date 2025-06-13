@tool
extends RefCounted

const Context = preload("./../context.gd")
const RLinkMap = preload("./rlink_map.gd")
const ScanResult = preload("./scan_result.gd")
const ScanCache = preload("./scan_cache.gd")
const RLinkData = preload("./rlink_data.gd")

signal stopped_waiting

var __ctx: Context
var __rlink_map: RLinkMap
var __scan_cache: ScanCache
var _rlink_data_cache: Dictionary

var busy_set: Dictionary
var waits_for_result: bool:
    get: return busy_set.size() > 0


func _init(context: Context) -> void:
    __ctx = context
    __rlink_map = __ctx.rlink_map
    __scan_cache = __ctx.scan_cache


func has_data(object: Object) -> bool:
    return _rlink_data_cache.has(object.get_instance_id())


func get_data(object: Object, force_create := false) -> RLinkData:
    var object_id := object.get_instance_id()
    var data: RLinkData = _rlink_data_cache.get(object_id)
    if data == null:
        var result := __scan_cache.get_search(object)
        if result.has_validate or force_create:
            data = RLinkData.new(__ctx, object, result)
            data.busy_changed.connect(_on_busy_changed)
            _rlink_data_cache[object_id] = data
    return data


func _on_busy_changed(status: bool, data_id: int) -> void:
    if status: busy_set[data_id] = true
    else: busy_set.erase(data_id)
    
    if busy_set.is_empty():
        stopped_waiting.emit()


func clear() -> void:
    busy_set.clear()
    _rlink_data_cache.clear()
    stopped_waiting.emit()
