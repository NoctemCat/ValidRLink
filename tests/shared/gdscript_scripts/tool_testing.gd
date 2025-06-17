## from https://github.com/godotengine/godot/pull/96290#issuecomment-2379003323
@tool
extends Sprite2D

@export var first: int = 123

@export var hidden_action := RLinkButton.new(test_hidden).set_text("Hidden")
@export var stop_action := RLinkButton.new(test_disabled).set_text("Disabled").set_icon("Stop")
@export var undoredo_action := RLinkButton.new(test_undoredo).set_text("UndoRedo").set_icon("UndoRedo")

@export
var make_green_action:= RLinkButton.new(set_self_modulate).bind(Color.GREEN).set_text("Make Green")

@export
var clear_modulation_action := RLinkButton.new(set_self_modulate) \
    .set_text("Clear Modulation") \
    .set_icon("Clear") \
    .bind(Color.WHITE)

@export var last: int = 42

func _validate_property(property: Dictionary) -> void:
    if property.name == "hidden_action": # hide the test button
        property.usage = property.usage & ~PROPERTY_USAGE_EDITOR
    if property.name == "stop_action":
        property.usage = property.usage | PROPERTY_USAGE_READ_ONLY

func _get_property_list() -> Array[Dictionary]:
    var properties:Array[Dictionary] = []
    for i in 3:
        properties.append({
            "name": "cool_dynamic_tool_button_%d" % i,
            "type": TYPE_OBJECT,
            "hint_string": "RLinkButton",
            "usage": PROPERTY_USAGE_EDITOR,
        })
    return properties

func _get(property: StringName) -> Variant:
    if property.begins_with("cool_dynamic_tool_button_"):
        var left: String = property.trim_prefix("cool_dynamic_tool_button_")
        return RLinkButton.new(test_dynamic).set_text("Dynamic Button %s" % left).bind(left)
    return null

func test_hidden() -> void:
    print("toot")

func test_disabled() -> void:
    print("can't touch this")

func test_undoredo() -> void:
    prints("undoredo")

func test_dynamic(what: Variant) -> void:
    prints("dynamic button", type_to_string(typeof(what)), typeof(what), what)


## Godot 4.1 support, if newer use `type_string`
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
