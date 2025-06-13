extends Node
const InnerResource = preload("./inner_resource.gd")

@export var inner: InnerResource


func validate_changes() -> void:
    if not inner is InnerResource:
        inner = InnerResource.new()
        
    @warning_ignore("untyped_declaration")
    for value in inner.set_values:
        var type := typeof(value)
        inner.set("export_%s_var" % type_string(type), value)
