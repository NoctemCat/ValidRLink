extends Node
const InnerResourceValidate = preload("./inner_resource_validate.gd")

@export var inner: InnerResourceValidate


func validate_changes() -> void:
    if inner == null:
        inner = InnerResourceValidate.new()
