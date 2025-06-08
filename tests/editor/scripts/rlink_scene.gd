extends Node

@export var scene: PackedScene
@export var scene_export: SimpleScene
@export var scene_load: SimpleScene
@export var scene_file: SimpleScene
@export var remove_all := RLinkButton.new(remove_all_impl)
@export var toggle_connect := RLinkButton.new(toggle_connect_impl)


func validate_changes(rlink: RLink) -> bool:
    if rlink.is_pair_invalid(scene_export):
        scene_export = rlink.convert_to_tool(scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)) 
        rlink.add_child_path("SceneExport", scene_export)
        
    if rlink.is_pair_invalid(scene_load):
        scene_load = rlink.instantiate_packed(scene)
        rlink.add_child_path("SceneLoad", scene_load)
        
    if rlink.is_pair_invalid(scene_file):
        scene_file = rlink.instantiate_file("res://tests/editor/simple_scene.tscn")
        rlink.add_child_path("SceneFile", scene_file)
        
    scene_load.position = Vector2(0, 50)
    scene_file.position = Vector2(0, 100)
    return true


func remove_all_impl(rlink: RLink) -> void:
    rlink.remove_child_path("SceneExport")
    rlink.remove_child_path("SceneLoad")
    rlink.remove_child_path("SceneFile")


func toggle_connect_impl(rlink: RLink) -> void:
    if rlink.signal_is_connected(scene_export.custom_pressed, scene_pressed):
        rlink.signal_disconnect(scene_export.custom_pressed, scene_pressed, ["hello scene_export"])
    else:
        rlink.signal_connect(scene_export.custom_pressed, scene_pressed)

    if rlink.signal_is_connected(scene_load.custom_pressed, scene_pressed):
        rlink.signal_disconnect(scene_load.custom_pressed, scene_pressed, ["hello scene_load"])
    else:
        rlink.signal_connect(scene_load.custom_pressed, scene_pressed)
    
    rlink.signal_toggle(scene_file.custom_pressed, scene_pressed, ["hello scene_file"])

    
func scene_pressed(text: String) -> void:
    print("scene_pressed %s" % text)
