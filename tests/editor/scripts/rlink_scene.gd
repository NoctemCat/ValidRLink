extends Node

@export var scene: PackedScene
@export var scene_export: SimpleScene
@export var scene_load: SimpleScene
@export var scene_file: SimpleScene
@export var remove_all := RLinkButton.new(remove_all_impl)
@export var toggle_connect := RLinkButton.new(toggle_connect_impl)


func validate_changes(rlink: RLink) -> bool:
    if scene_export == null:
        scene_export = rlink.convert_to_tool(scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE))
        rlink.add_child_path("SceneExport", scene_export)
        
    if scene_load == null:
        scene_load = rlink.instantiate_packed(scene)
        rlink.add_child_path("SceneLoad", scene_load)
        
    if scene_file == null:
        scene_file = rlink.instantiate_file("res://tests/editor/simple_scene.tscn")
        rlink.add_child_path("SceneFile", scene_file)
        
    scene_load.position = Vector2(0, 50)
    scene_file.position = Vector2(0, 100)
    return true


func remove_all_impl(rlink: RLink) -> void:
    rlink.remove_all_children()


func toggle_connect_impl(rlink: RLink) -> void:
    if rlink.signal_is_connected(scene_export.custom_pressed, scene_pressed):
        rlink.signal_disconnect(scene_export.custom_pressed, scene_pressed)
    else:
        rlink.signal_connect(scene_export.custom_pressed, scene_pressed, ["hello scene_export"])

    if rlink.signal_is_connected(scene_load.custom_pressed, scene_pressed):
        rlink.signal_disconnect(scene_load.custom_pressed, scene_pressed)
    else:
        rlink.signal_connect(scene_load.custom_pressed, scene_pressed, ["hello scene_load"])
    
    rlink.signal_toggle(scene_file.custom_pressed, scene_pressed, ["hello scene_file"])

    
func scene_pressed(text: String) -> void:
    print("scene_pressed %s" % text)
