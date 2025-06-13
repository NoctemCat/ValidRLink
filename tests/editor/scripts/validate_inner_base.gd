extends Node
const InnerResourceValidate = preload("./inner_resource_validate.gd")

@export var inner: Resource


func validate_changes() -> void:
    if not inner is InnerResourceValidate:
        inner = InnerResourceValidate.new()
        pass
