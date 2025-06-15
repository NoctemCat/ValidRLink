extends Node

@export var int_var: int

func validate_changes() -> bool:
    int_var = 200
    if get(&"float_var") != null:
        set(&"float_var", 55.5)
    return true
