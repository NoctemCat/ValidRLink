class_name SimpleScene
extends Control

signal custom_pressed


func _on_button_pressed() -> void:
    custom_pressed.emit()
