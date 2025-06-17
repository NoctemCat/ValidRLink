class_name SimpleScene
extends Control

signal custom_pressed

@export var int_var: int


func _on_button_pressed() -> void:
    custom_pressed.emit()


func validate_changes(rlink: RLink) -> void:
    int_var = 100
    return
    prints("is_edited_scene_root:", rlink.is_edited_scene_root(), rlink.placeholder)
    prints("node.owner:", rlink.placeholder.owner)
    var child := rlink.get_node_or_null("MyName")
    var runtime: Node = rlink.get_runtime_from(child)
    print("child.owner: ", runtime.owner)
