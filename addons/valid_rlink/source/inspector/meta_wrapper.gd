@tool
extends Resource

var value_id: int
var value: Object:
    get: return instance_from_id(value_id)


func _init(obj: Object = null) -> void:
    value_id = obj.get_instance_id()
