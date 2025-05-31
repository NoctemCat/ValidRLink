@tool
extends RefCounted

const ADDON_PATH := "res://addons/valid_rlink/"
const BASE_SETTINGS_PATH := "addons/valid_rlink/"

const VALIDATE_WAIT_TIME_PATH := BASE_SETTINGS_PATH + "validate_wait_time"
const MAX_DEPTH_PATH := BASE_SETTINGS_PATH + "copy_max_depth"
const SAVE_AFTER_VALIDATE_PATH := BASE_SETTINGS_PATH + "save_after_validate"
const COPY_EXTERNAL_RESOURCES_PATH := BASE_SETTINGS_PATH + "copy_external_resources"
const COPY_BUILTIN_RESOURCES_PATH := BASE_SETTINGS_PATH + "copy_builtin_resources"
const NATIVE_OBJECTS_BEHAVIOUR_PATH := BASE_SETTINGS_PATH + "copy_behaviour/native_objects"
const NATIVE_RESOURCES_BEHAVIOUR_PATH := BASE_SETTINGS_PATH + "copy_behaviour/native_resources"
const VALIDATE_VALUES_PATH := BASE_SETTINGS_PATH + "function_names/validate_values"
const GET_RLINK_SETTINGS_PATH := BASE_SETTINGS_PATH + "function_names/get_rlink_settings"
const CSHARP_USE_NATIVE_HELPER_PATH := BASE_SETTINGS_PATH + "csharp/use_native_helper"
const CSHARP_COLLECT_GC_ON_EXIT_PATH := BASE_SETTINGS_PATH + "csharp/collect_gc_on_exit"
const MISC_DUPLICATE_PACKED_ARRAYS_PATH = BASE_SETTINGS_PATH + "misc/duplicate_packed_arrays"
const MISC_REFRESH_AFTER_CHANGES_PATH = BASE_SETTINGS_PATH + "misc/refresh_inspector_after_settings_changes"
const MISC_VERSION_PATH = BASE_SETTINGS_PATH + "misc/version"

enum ClassType {
    UserClasses = 1,
    NativeClasses = 2,
    All = UserClasses | NativeClasses
}

enum CopyBehaviour {
    Duplicate,
    PassDirectly,
}

var plugin_version := 0x000100
var engine_version: int

var validate_wait_time: float
var max_depth: int
#var save_after_validate: bool
var copy_external_resources: ClassType = ClassType.NativeClasses
var copy_builtin_resources: ClassType = ClassType.All
var pass_native_objects: bool = false
var pass_native_resources: bool = true
 
var validate_values_paths: Array[StringName]
var get_rlink_settings_paths: Array[StringName]
 
var csharp_use_native_helper: bool
var csharp_collect_gc_on_exit: bool
 
var duplicate_packed_arrays: bool
var refresh_after_changes: bool


func _init() -> void:
    engine_version = Engine.get_version_info()["hex"]
    var set_version: String = ProjectSettings.get_setting(MISC_VERSION_PATH, "")
    # TODO: add versioning
    if set_version:
        set_version.split(".")
    set_project_settings()
    
    
func set_project_settings() -> void:
    _add_setting(VALIDATE_WAIT_TIME_PATH, TYPE_FLOAT, 0.05)
    _add_setting(MAX_DEPTH_PATH, TYPE_INT, 3)
    _add_flag_setting(COPY_EXTERNAL_RESOURCES_PATH, "User Classes,Native Classes", ClassType.NativeClasses)
    _add_flag_setting(COPY_BUILTIN_RESOURCES_PATH, "User Classes,Native Classes", ClassType.All)
    
    #_add_enum_setting(NATIVE_OBJECTS_BEHAVIOUR_PATH, "Duplicate,Pass Directly", CopyBehaviour.Duplicate)
    #_add_enum_setting(NATIVE_RESOURCES_BEHAVIOUR_PATH, "Duplicate,Pass Directly", CopyBehaviour.PassDirectly)
    
    var _validate_names: Array[StringName] = [
        &"_rlink_validate",
        &"rlink_validate",
        &"RLinkValidate"
    ]
    var _get_rlink_setting_names: Array[StringName] = [
        &"_get_rlink_settings",
        &"get_rlink_settings",
        &"GetRLinkSettings"
    ]
    _add_array_setting(VALIDATE_VALUES_PATH, TYPE_STRING_NAME, _validate_names)
    _add_array_setting(GET_RLINK_SETTINGS_PATH, TYPE_STRING_NAME, _get_rlink_setting_names)
    
    _add_setting(CSHARP_USE_NATIVE_HELPER_PATH, TYPE_BOOL, true)
    _add_setting(CSHARP_COLLECT_GC_ON_EXIT_PATH, TYPE_BOOL, true)
    
    _add_setting(MISC_DUPLICATE_PACKED_ARRAYS_PATH, TYPE_BOOL, true)
    _add_setting(MISC_REFRESH_AFTER_CHANGES_PATH, TYPE_BOOL, true)
    _add_setting(MISC_VERSION_PATH, TYPE_STRING, "%d.%d.%d" % _decode_version(plugin_version))
    
    
func _add_setting(name: String, type: Variant.Type, value: Variant) -> void:
    ProjectSettings.set_setting(name, value)
    ProjectSettings.add_property_info({
        "name": name,
        "type": type,
    })
    ProjectSettings.set_initial_value(name, value)


func _add_array_setting(name: String, type: Variant.Type, value: Array) -> void:
    ProjectSettings.set_setting(name, value)
    ProjectSettings.add_property_info({
        "name": name,
        "type": TYPE_ARRAY,
        "hint": PROPERTY_HINT_ARRAY_TYPE,
        "hint_string": "%d:" % type,
    })
    ProjectSettings.set_initial_value(name, value)


func _add_enum_setting(name: String, hint_string: String, value: int) -> void:
    ProjectSettings.set_setting(name, value)
    ProjectSettings.add_property_info({
        "name": name,
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": hint_string,
    })
    ProjectSettings.set_initial_value(name, value)
    

func _add_flag_setting(name: String, hint_string: String, value: int) -> void:
    ProjectSettings.set_setting(name, value)
    ProjectSettings.add_property_info({
        "name": name,
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_FLAGS,
        "hint_string": hint_string,
    })
    ProjectSettings.set_initial_value(name, value)


func update_plugin_settings() -> void:
    validate_wait_time = ProjectSettings.get_setting_with_override(VALIDATE_WAIT_TIME_PATH)
    max_depth = ProjectSettings.get_setting_with_override(MAX_DEPTH_PATH)
    #save_after_validate = ProjectSettings.get_setting_with_override(VALIDATE_SKIP_PATH)
    copy_external_resources = ProjectSettings.get_setting_with_override(COPY_EXTERNAL_RESOURCES_PATH)
    copy_builtin_resources = ProjectSettings.get_setting_with_override(COPY_BUILTIN_RESOURCES_PATH)
    
    #pass_native_objects = ProjectSettings.get_setting_with_override(NATIVE_OBJECTS_BEHAVIOUR_PATH) \
    #    == CopyBehaviour.PassDirectly 
    #pass_native_resources = ProjectSettings.get_setting_with_override(NATIVE_RESOURCES_BEHAVIOUR_PATH) \
    #    == CopyBehaviour.PassDirectly
    
    validate_values_paths = ProjectSettings.get_setting_with_override(VALIDATE_VALUES_PATH)
    get_rlink_settings_paths = ProjectSettings.get_setting_with_override(GET_RLINK_SETTINGS_PATH)
    
    csharp_use_native_helper = ProjectSettings.get_setting_with_override(CSHARP_USE_NATIVE_HELPER_PATH)
    csharp_collect_gc_on_exit = ProjectSettings.get_setting_with_override(CSHARP_COLLECT_GC_ON_EXIT_PATH)
    duplicate_packed_arrays = ProjectSettings.get_setting_with_override(MISC_DUPLICATE_PACKED_ARRAYS_PATH)
    refresh_after_changes = ProjectSettings.get_setting_with_override(MISC_REFRESH_AFTER_CHANGES_PATH)


func _decode_version(_version: int) -> Array[int]:
    var arr: PackedByteArray
    arr.resize(8)
    arr.encode_s64(0, plugin_version)
    return [arr.decode_s8(2), arr.decode_s8(1), arr.decode_s8(0)]
