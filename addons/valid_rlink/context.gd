@tool
extends Object

const Settings = preload("./settings.gd")
const Compatibility = preload("./compatibility.gd")

var settings: Settings
var compat: Compatibility

var csharp_helper_script: Script
var popup: PopupMenu
var button_theme: Theme

var undo_redo: RefCounted
var scan_cache: RefCounted
var rlink_map: RefCounted
var rlink_data_cache: RefCounted
var converter_to_tool: RefCounted
var converter_to_runtime: RefCounted
var rlink_inspector: RefCounted
