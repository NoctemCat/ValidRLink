class_name SimpleScene
extends Control

signal custom_pressed

@export var int_var: int:
    set(value):
        int_var = value


func _on_button_pressed() -> void:
    custom_pressed.emit()


func validate_changes() -> void:
    int_var = 100
    pass
