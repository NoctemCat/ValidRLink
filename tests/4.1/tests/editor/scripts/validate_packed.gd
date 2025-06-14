extends Node

@export var array: PackedInt32Array

func validate_changes() -> void:
    array.resize(5)
    array[0] = 3
