@tool
extends Object

const PLUGIN_PATH := "res://addons/valid_rlink/"
const RUNTIME_PATH := "res://addons/valid_rlink/runtime/"
const SOURCE_PATH := "res://addons/valid_rlink/source/"
const RLINK_PATH := "res://addons/valid_rlink/source/rlink/"
const Settings = preload("./settings.gd")
const Compatibility = preload("./compatibility.gd")

signal cancel_tasks

var settings: Settings
var compat: Compatibility

var csharp_enabled: bool
var csharp_helper_script: Script
var csharp_button_script: Script
var csharp_settings_script: Script
var csharp_db: Node
var csharp_ref_tracer: Node

var popup: PopupMenu
var button_theme: Theme
var undo_redo: EditorUndoRedoManager

var scan_cache: RefCounted
var rlink_map: RefCounted
var rlink_data_cache: RefCounted
var converter_to_tool: RefCounted
var converter_to_runtime: RefCounted
var rlink_inspector: RefCounted

var _clear_entered := false


func emit_cancel_tasks() -> void:
    cancel_tasks.emit()


func object_is_button(object: Object) -> bool:
    return object is RLinkButton or (csharp_enabled and object.get_script() == csharp_button_script)


func object_is_csharp(object: Object) -> bool:
    var script: Script = object.get_script()
    return script != null and script.get_class() == "CSharpScript"


func clear_and_refresh(refresh: bool = true) -> void:
    cancel_tasks.emit()
    rlink_inspector.clear()
    if refresh: refresh_inspector()


func clear_wait(refresh: bool = true) -> void:
    if _clear_entered: return
    _clear_entered = true
    if rlink_data_cache.waits_for_result:
        await rlink_data_cache.stopped_waiting
    rlink_inspector.clear()
    if refresh: refresh_inspector()
    _clear_entered = false


func refresh_inspector() -> void:
    var selection: EditorSelection = compat.interface.get_selection()
    var nodes := selection.get_selected_nodes()
    if nodes.size() == 1:
        nodes[0].notify_property_list_changed()


## Used in rlink_buffer.gd
func establish_tracking(runtime: Object, name: String) -> void:
    var btn: Resource = runtime.get(name)
    if btn == null: return
    var tool: Object = rlink_map.tool_from_obj(runtime)
    if tool == null: return
    var tool_btn: Object = tool.get(name)
    if tool_btn == null: return
    
    rlink_map.add_pair(btn, tool_btn)
    btn.changed.emit()


## Used in rlink_buffer.gd
func set_owners(owner: Node, owned: Array[Node]) -> void:
    for node in owned:
        node.owner = owner
