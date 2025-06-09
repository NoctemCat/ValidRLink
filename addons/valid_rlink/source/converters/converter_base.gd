@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const RLinkMap = preload(Context.RLINK_PATH + "rlink_map.gd")
const ScanResult = preload(Context.RLINK_PATH + "scan_result.gd")
const ScanCache = preload(Context.RLINK_PATH + "scan_cache.gd")
const RLinkData = preload(Context.RLINK_PATH + "rlink_data.gd")

var __ctx: Context
var __map: RLinkMap
var __settings: Settings
var __scan_cache: ScanCache


func _init(context: Context) -> void:
    __ctx = context
    __map = context.rlink_map
    __settings = context.settings
    __scan_cache = context.scan_cache


#func _setup(value: Variant, depth: int) -> int:
    #var found_res := false
    #if value is Object:
        #var res := __scan_cache.get_search(value)
        #if res != null:
            #_max_depth = res.max_depth
            #found_res = true
    #if not found_res:
         #_max_depth = __settings.max_depth
        #
    #if depth == -1: depth = _max_depth - 1
    #_script_error = false
    #_visit.clear()
    #return depth


func _skip_property(to_skip: Array[StringName], allowed: Array[StringName], prop: Dictionary) -> bool:
    var prop_name: StringName = prop["name"]
    if allowed.is_empty() and prop_name in to_skip:
        return true
    
    var value_type: int = prop["type"]
    if value_type == TYPE_CALLABLE or value_type == TYPE_SIGNAL:
        return true

    if prop["usage"] & PROPERTY_USAGE_STORAGE != PROPERTY_USAGE_STORAGE:
        return true
    
    if _is_rlink_button(prop):
        return false
        
    if allowed.size() > 0:
        return not prop_name in allowed

    return false


#func _skip_resource(value: Resource) -> bool:
    #var is_builtin := value.resource_path.is_empty() or "::" in value.resource_path
    #var is_external := not is_builtin
    #var class_flag: Settings.ClassType = (
        #Settings.ClassType.UserClasses if value.get_script() != null 
        #else Settings.ClassType.NativeClasses
    #)
    #return (is_builtin and __settings.copy_builtin_resources & class_flag == 0) \
        #or (is_external and __settings.copy_external_resources & class_flag == 0)


func _skip_value(data: RLinkData, prop: Dictionary, value: Variant, depth: int) -> bool:
    var value_type: int = prop["type"]
    if depth + 1 >= data.max_depth and (
        value_type == TYPE_OBJECT
        or value_type == TYPE_ARRAY
        or value_type == TYPE_DICTIONARY
    ):
        return true

    if value is Object and __scan_cache.get_search(value).skip:
        return true
    #if value is Resource and prop["hint_string"] != RLinkButton.CLASS_NAME and _skip_resource(value):
        #return true

    return false
    

func _pass_directly(value: Object) -> bool:
    var script: Script = value.get_script()
    if script == null:
            return value is Resource
    return false
    

func _is_external_resource(value: Variant) -> bool:
    if not value is Resource: return false
    var path: String = value.resource_path
    var is_builtin := path.is_empty() or "::" in path or path.begins_with("local://")
    return not is_builtin


func _is_rlink_button(prop: Dictionary) -> bool:
    return prop["type"] == TYPE_OBJECT and (prop["hint_string"] == RLinkButton.CLASS_NAME or prop["hint_string"] == RLinkButton.CLASS_NAME_CS)