extends Node
#const InnerResource = preload("./inner_resource.gd")

@export var inner: EditorInnerResource = EditorInnerResource.new()


func validate_changes(rlink: RLink) -> void:
    if not inner is EditorInnerResource:
        inner = rlink.convert_to_tool(EditorInnerResource.new())
        
    for value in inner.set_values:
        var type := typeof(value)
        inner.set("export_%s_var" % type_to_string(type), value)


func type_to_string(type: Variant.Type) -> String:
    var types: Array[String] = [
        "Nil", # 0
        "bool", # 1
        "int", # 2
        "float", # 3
        "String", # 4
        "Vector2", # 5
        "Vector2i", # 6
        "Rect2", # 7
        "Rect2i", # 8
        "Vector3", # 9
        "Vector3i", # 10
        "Transform2D", # 11
        "Vector4", # 12
        "Vector4i", # 13
        "Plane", # 14
        "Quaternion", # 15
        "AABB", # 16
        "Basis", # 17
        "Transform3D", # 18
        "Projection", # 19
        "Color", # 20
        "StringName", # 21
        "NodePath", # 22
        "RID", # 23
        "Object", # 24
        "Callable", # 25
        "Signal", # 26
        "Dictionary", # 27
        "Array", # 28
        "PackedByteArray", # 29
        "PackedInt32Array", # 30
        "PackedInt64Array", # 31
        "PackedFloat32Array", # 32
        "PackedFloat64Array", # 33
        "PackedStringArray", # 34
        "PackedVector2Array", # 35
        "PackedVector3Array", # 36
        "PackedColorArray", # 37
        "PackedVector4Array", # 38
    ]
    return types[type]
