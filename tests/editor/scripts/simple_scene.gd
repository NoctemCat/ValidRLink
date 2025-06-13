class_name SimpleScene
extends Control

signal custom_pressed

@export var int_var: int


func _on_button_pressed() -> void:
    custom_pressed.emit()


func validate_changes() -> void:
    int_var = 100
    pass
