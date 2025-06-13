@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const RLinkMap = preload(Context.RLINK_PATH + "rlink_map.gd")
const ScanResult = preload(Context.RLINK_PATH + "scan_result.gd")
const ScanCache = preload(Context.RLINK_PATH + "scan_cache.gd")
const RLinkBuffer = preload(Context.RLINK_PATH + "rlink_buffer.gd")

var __ctx: Context
var __map: RLinkMap
var __settings: Settings
var __scan_cache: ScanCache


func _init(context: Context) -> void:
    __ctx = context
    __map = context.rlink_map
    __settings = context.settings
    __scan_cache = context.scan_cache


func _convert_value(_data: RLinkBuffer, value: Variant, _depth: int = 0, _search_ctx: Object = null) -> Variant:
    push_warning("ValidRLink: Don't call this base method [converter_base._convert_value]")
    return value


func _skip_property(to_skip: Array[StringName], allowed: Array[StringName], prop: Dictionary) -> bool:
    var prop_name: StringName = prop["name"]
    
    if prop_name == &"script":
        return true

    var value_type: int = prop["type"]
    if value_type == TYPE_CALLABLE or value_type == TYPE_SIGNAL:
        return true

    if (prop["usage"] & PROPERTY_USAGE_STORAGE) != PROPERTY_USAGE_STORAGE:
        return true
    
    if _is_rlink_button(prop):
        return false
        
    if allowed.size() > 0:
        return not prop_name in allowed
        
    if prop_name in to_skip:
        return true

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
        
        
func _skip_type(data: RLinkBuffer, type: Variant.Type, depth: int) -> bool:
    return depth + 1 >= data.max_depth and can_contain_object(type)


func _skip_object(value: Variant) -> bool:
    return value is Object and (
        value.get_meta(&"rlink_skip", false)
        or __scan_cache.get_search(value).skip
    )


func _skip_value(data: RLinkBuffer, prop: Dictionary, value: Variant, depth: int) -> bool:
    var value_type: int = prop["type"]
    if depth + 1 >= data.max_depth and can_contain_object(value_type):
        return true

    if value is Object and (
        value.get_meta(&"rlink_skip", false)
         or __scan_cache.get_search(value).skip
    ):
        return true

    return false
    

func _pass_directly(value: Object) -> bool:
    if value is Script:
        return true
        
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
    return prop["type"] == TYPE_OBJECT and (
        prop["hint_string"] == RLinkButton.CLASS_NAME
        or prop["hint_string"] == RLinkButton.CLASS_NAME_CS
    )


func can_contain_object(type: Variant.Type) -> bool:
    return type == TYPE_OBJECT or type == TYPE_ARRAY or type == TYPE_DICTIONARY
