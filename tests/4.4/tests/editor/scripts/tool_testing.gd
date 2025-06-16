## from https://github.com/godotengine/godot/pull/96290#issuecomment-2379003323
@tool
extends Sprite2D

@export var first: int = 123

@export var hidden_action := RLinkButton.new(test_hidden).set_text("Hidden")
@export var stop_action := RLinkButton.new(test_disabled).set_text("Disabled").set_icon("Stop")
@export var undoredo_action := RLinkButton.new(test_undoredo).set_text("UndoRedo").set_icon("UndoRedo")

@export
var make_green_action := RLinkButton.new(set_self_modulate).set_text("Make Green").bind(Color.GREEN)

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
    var properties:Array[Dictionary]
    for i in 3:
        properties.append({
            "name": "cool_dynamic_tool_button_%d" % i,
            "type": TYPE_CALLABLE,
            "hint_string": "Dynamic Button %d" % i,
            "usage": PROPERTY_USAGE_EDITOR,
        })
    return properties

func _get(property: StringName) -> Variant:
    if property.begins_with("cool_dynamic_tool_button_"):
        return test_dynamic.bind(property.trim_prefix("cool_dynamic_tool_button_"))
    return null

func test_hidden() -> void:
    print("toot")

func test_disabled() -> void:
    print("can't touch this")

func test_undoredo() -> void:
    prints("undoredo", EditorInterface.get_editor_undo_redo())

func test_dynamic(what: Variant) -> void:
    prints("dynamic button", type_string(typeof(what)), typeof(what), what)
