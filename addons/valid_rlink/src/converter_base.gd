@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const ScanResult = preload("./scan_result.gd")
const ScanCache = preload("./scan_cache.gd")

var __setting: Settings
var __scan_cache: ScanCache


func _init(context: Context) -> void:
    __setting = context.settings
    __scan_cache = context.scan_cache


func _skip_property(to_skip: PackedStringArray, prop: Dictionary) -> bool:
    if prop["name"] in to_skip:
        return true
    
    if prop["type"] == TYPE_CALLABLE or prop["type"] == TYPE_SIGNAL:
        return true

    #if prop["type"] == TYPE_OBJECT and prop["hint_string"] == RLinkButton.CLASS_NAME:
    #    return true
    
    # Node name is not even storage
    if prop["name"] == "name" or prop["type"] == TYPE_STRING_NAME:
        return false
        
    if not (
        prop["usage"] & PROPERTY_USAGE_STORAGE != 0 
        #or prop["usage"] & PROPERTY_USAGE_EDITOR != 0
        #or prop["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE != 0
    ): 
        return true

    return false


func _skip_resource(value: Resource) -> bool:
    var is_builtin := value.resource_path.is_empty() or "::" in value.resource_path
    var is_external := not is_builtin
    var class_flag: Settings.ClassType = (
        Settings.ClassType.UserClasses if value.get_script() != null 
        else Settings.ClassType.NativeClasses
    )
    return (is_builtin and __setting.copy_builtin_resources & class_flag == 0) \
        or (is_external and __setting.copy_external_resources & class_flag == 0)


func _skip_value(
    value: Variant,
    value_type: Variant.Type,
    depth: int
) -> bool:
    if depth + 1 >= __setting.max_depth and (
        value_type == TYPE_OBJECT  
        or value_type == TYPE_ARRAY
        or value_type == TYPE_DICTIONARY
    ): 
        return true
    
    #if value is Object:
    # and __scan_cache.get_search(value).has_skip:
    #    return true
    if value is Resource and _skip_resource(value):
        return true

    return false
    

func _pass_directly(value: Object) -> bool:
    var script: Script = value.get_script() 
    if script == null:
        if (
            (value is Resource and __setting.pass_native_resources) 
            or __setting.pass_native_objects
        ):
            return true
    return false
