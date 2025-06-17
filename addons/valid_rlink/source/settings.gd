@tool
extends RefCounted

const BASE_SETTINGS_PATH := "addons/valid_rlink/"
const MISC_VERSION_PATH = BASE_SETTINGS_PATH + "misc/version"

const DEF_VALIDATE_CHANGES_NAMES: Array[StringName] = [&"_validate_changes", &"validate_changes", &"ValidateChanges", &"_ValidateChanges"]
const DEF_GET_RLINK_SETTINGS_NAMES: Array[StringName] = [&"_get_rlink_settings", &"get_rlink_settings", &"GetRLinkSettings", &"_GetRLinkSettings"]
const DEFAULT_VALUES := {
    turn_callables_to_buttons = true,
    call_without_changes_commits_action = true,
    call_action_template = "%s",
    validate_wait_time = 0.05,
    validate_use_history = true,
    max_depth = 3,
    apply_changes_to_external_user_resources = false,
    default_button_path = "",
    validate_changes_names = DEF_VALIDATE_CHANGES_NAMES,
    get_rlink_settings_names = DEF_GET_RLINK_SETTINGS_NAMES,
    csharp_collect_gc = true,
    csharp_execute_pending_continuations = true,
    csharp_swallow_base_exception = true,
    duplicate_packed_arrays = true,
    update_tree_on_signal_change = true,
}

const NAME_ALIASES := {
    max_depth = "copy_max_depth",
    validate_changes_names = "function_names/validate_changes",
    get_rlink_settings_names = "function_names/get_rlink_settings",
    csharp_collect_gc = "csharp_assembly_unload/collect_gc",
    csharp_execute_pending_continuations = "csharp_assembly_unload/execute_pending_continuations",
    csharp_swallow_base_exception = "csharp_assembly_unload/swallow_base_exception",
    duplicate_packed_arrays = "misc/duplicate_packed_arrays",
    update_tree_on_signal_change = "misc/update_tree_on_signal_change",
}

const PROP_HINTS := {
    validate_changes_names = {"hint": PROPERTY_HINT_ARRAY_TYPE, "hint_string": "%d:" % TYPE_STRING_NAME},
    get_rlink_settings_names = {"hint": PROPERTY_HINT_ARRAY_TYPE, "hint_string": "%d:" % TYPE_STRING_NAME},
    default_button_path = {"hint": PROPERTY_HINT_FILE, "hint_string": "*.tres,*.res"},
}

var plugin_version := 0x000100
var engine_version: int

var turn_callables_to_buttons: bool
var call_without_changes_commits_action: bool
var call_action_template: String
var validate_wait_time: float
var validate_use_history: bool
var max_depth: int
var apply_changes_to_external_user_resources: bool
var default_button_path: String

var validate_changes_names: Array[StringName]
var get_rlink_settings_names: Array[StringName]

var csharp_collect_gc: bool
var csharp_execute_pending_continuations: bool
var csharp_swallow_base_exception: bool
var duplicate_packed_arrays: bool
var update_tree_on_signal_change: bool


func _init() -> void:
    engine_version = Engine.get_version_info()["hex"]
    var set_version: String = ProjectSettings.get_setting(MISC_VERSION_PATH, "")
    # TODO: add versioning
    if set_version:
        set_version.split(".")
    _set_default()
    _set_project_settings()
    _set_settings_order()
    
    
func _set_default() -> void:
    for prop_name in DEFAULT_VALUES:
        assert(prop_name in self)
        set(prop_name, DEFAULT_VALUES[prop_name])
    
    
func _set_project_settings() -> void:
    for value_name in DEFAULT_VALUES:
        _add_setting(value_name, DEFAULT_VALUES[value_name])
    ProjectSettings.set_setting(MISC_VERSION_PATH, "0.1.0")
    ProjectSettings.add_property_info({"name": MISC_VERSION_PATH, "type": TYPE_STRING})
    ProjectSettings.set_initial_value(MISC_VERSION_PATH, "0.1.0")
    
    
func _add_setting(prop_name: StringName, value: Variant) -> void:
    var setting_name: String = BASE_SETTINGS_PATH + NAME_ALIASES.get(prop_name, prop_name)
    var prop_info := {
        "name": setting_name,
        "type": typeof(value),
    }
    if PROP_HINTS.has(prop_name):
        var hints: Dictionary = PROP_HINTS[prop_name]
        prop_info["hint"] = hints["hint"]
        prop_info["hint_string"] = hints["hint_string"]
    
    if not ProjectSettings.has_setting(setting_name):
        ProjectSettings.set_setting(setting_name, value)
    ProjectSettings.add_property_info(prop_info)
    ProjectSettings.set_initial_value(setting_name, value)


func _set_settings_order() -> void:
    var idx := _find_min()
    for prop_name in DEFAULT_VALUES:
        var setting_name: String = BASE_SETTINGS_PATH + NAME_ALIASES.get(prop_name, prop_name)
        ProjectSettings.set_order(setting_name, idx)
        idx += 1


func _find_min() -> int:
    var min_value := 10000000
    for prop_name in DEFAULT_VALUES:
        var current := ProjectSettings.get_order(BASE_SETTINGS_PATH + NAME_ALIASES.get(prop_name, prop_name))
        if current < min_value: min_value = current
    return min_value


func update_plugin_settings() -> void:
    for prop_name in DEFAULT_VALUES:
        var setting_name: String = BASE_SETTINGS_PATH + NAME_ALIASES.get(prop_name, prop_name)
        set(prop_name, ProjectSettings.get_setting_with_override(setting_name))

    if max_depth <= 0:
        push_warning("ValidRLink: 'copy_max_depth' is only accepts values higher than 1 [settings.update_plugin_settings]")
        max_depth = 3
        ProjectSettings.set_setting(BASE_SETTINGS_PATH + "copy_max_depth", 3)
    
    if default_button_path == "": return
    var btn: Resource = null
    if ResourceLoader.exists(default_button_path):
        btn = load(default_button_path)
    if not btn is RLinkButton:
        push_warning("ValidRLink: Expected RLinkButton at 'default_button_path' [settings.update_plugin_settings]")


func _decode_version(_version: int) -> Array[int]:
    var arr: PackedByteArray = []
    arr.resize(8)
    arr.encode_s64(0, plugin_version)
    return [arr.decode_s8(2), arr.decode_s8(1), arr.decode_s8(0)]
