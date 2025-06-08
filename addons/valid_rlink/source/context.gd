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

var popup: PopupMenu
var button_theme: Theme
var undo_redo: EditorUndoRedoManager

var scan_cache: RefCounted
var rlink_map: RefCounted
var rlink_data_cache: RefCounted
var converter_to_tool: RefCounted
var converter_to_runtime: RefCounted
var rlink_inspector: RefCounted


func emit_cancel_tasks() -> void:
    cancel_tasks.emit()
