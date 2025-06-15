@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const Compat = Context.Compatibility

var object_id: int
var object_name: String
var skip: bool
var max_depth: int
var validate_name: StringName
var validate_arg_count: int
var validate_check_return: bool
var has_validate: bool:
    get: return validate_name != &""

var skip_properties: Array[StringName]
var allowed_properties: Array[StringName]
var _methods_arg_infos: Dictionary


func _init(context: Context, object: Object) -> void:
    skip = false
    max_depth = context.settings.max_depth
    validate_name = &""
    validate_arg_count = -1
    validate_check_return = false
    skip_properties = [&"_import_path", &"resource_path"]
    object_id = object.get_instance_id()
    
    var script: Script = object.get_script()
    
    if object is Node and object.name:
        object_name = object.name
    elif object is Resource and object.resource_name:
        object_name = object.resource_name
    elif object is Resource and object.resource_path:
        object_name = object.resource_path
    else:
        if script != null:
            object_name = script.resource_path.get_file()
        else:
            object_name = object.to_string()
            
    if skip: return
    if object is Script:
        skip = true
        return

    if script != null and not script.is_tool():
        handle_script(context, object, script)
    else:
        handle_native(context, object)


func handle_native(context: Context, object: Object) -> void:
    handle_script(context, object, object)
        
        
func handle_script(context: Context, object: Object, script_or_native: Object) -> void:
    var rlink_settings: RLinkSettings = _get_settings(context, object, script_or_native)
    ## Uncomment for autocomplete, then comment it again to make it optional
    #var rlink_settings_cs: RLinkSettingsCS = _get_settings_cs(context, object, script_or_native) 
    var rlink_settings_cs: Resource = _get_settings_cs(context, object, script_or_native)

    var had_validate := false
    if rlink_settings != null:
        if rlink_settings.skip:
            skip = true
            return
            
        if rlink_settings.validate_name != &"":
            had_validate = true
            if context.compat.comp_has_method(object, rlink_settings.validate_name):
                validate_name = rlink_settings.validate_name
        
        skip_properties.append_array(rlink_settings.skip_properties)
        allowed_properties.assign(rlink_settings.allowed_properties)
        
        if rlink_settings.max_depth > 0:
            max_depth = rlink_settings.max_depth
            
    if rlink_settings_cs != null:
        if rlink_settings_cs.Skip:
            skip = true
            return
            
        if rlink_settings_cs.ValidateName != &"":
            had_validate = true
            if context.compat.comp_has_method(object, rlink_settings_cs.ValidateName):
                validate_name = rlink_settings_cs.ValidateName
        
        skip_properties.append_array(rlink_settings_cs.SkipProperties)
        allowed_properties.assign(rlink_settings_cs.AllowedProperties)
        
        if rlink_settings_cs.MaxDepth > 0:
            max_depth = rlink_settings_cs.MaxDepth


    if !had_validate and validate_name == &"":
        for name in context.settings.validate_changes_names:
            if context.compat.comp_has_method(object, name):
                validate_name = name
                break
    

    if validate_name != &"":
        if script_or_native is Script and script_or_native.get_class() == "CSharpScript":
            var info: Dictionary = context.csharp_db.GetMethodInfo(script_or_native, validate_name)
            validate_arg_count = info["arg_count"]
            validate_check_return = info["needs_check"]
        else:
            var info := get_method_info(validate_name)
            validate_arg_count = info.arg_count
            validate_check_return = info.check_return


func _get_settings(ctx: Context, _object: Object, script_or_native: Object) -> RLinkSettings:
    if script_or_native is Script and script_or_native.get_class() == "CSharpScript":
        return null
        
    var rlink_settings: RLinkSettings = null
    #var methods := _parse_methods(ctx, object)
    for name in ctx.settings.get_rlink_settings_names:
        # TODO: Check in 4.1
        if name in script_or_native:
        #if methods.has(name):
            var settings: Variant = script_or_native.call(name)
            if settings is Dictionary:
                rlink_settings = RLinkSettings.new(settings)
            elif settings is RLinkSettings:
                rlink_settings = settings
            else:
                push_error("ValidRLink: get settings function must return 'RLinkSettings' or dictionary [scan_result.handle_script]")
                return
            break
    return rlink_settings


func _get_settings_cs(ctx: Context, _object: Object, script_or_native: Object) -> Resource:
    if not (script_or_native is Script and script_or_native.get_class() == "CSharpScript"):
        return null
        
    return ctx.csharp_db.GetRLinkSettings(script_or_native, ctx.settings.get_rlink_settings_names)


func get_method_info(method: StringName) -> MethodInfo:
    var info: MethodInfo = _methods_arg_infos.get(method)
    if info != null: return info
    
    info = _parse_method_info(method)
    return info
    
    
func get_arg_count(method: StringName) -> int:
    var info: MethodInfo = _methods_arg_infos.get(method)
    if info != null: return info.arg_count
    
    info = _parse_method_info(method)
    return info.arg_count if info != null else -1


func get_check_return(method: StringName) -> bool:
    var info: MethodInfo = _methods_arg_infos.get(method)
    if info != null: return info.check_return
    
    info = _parse_method_info(method)
    return info.check_return if info != null else false


func _parse_method_info(method: StringName) -> MethodInfo:
    var object := instance_from_id(object_id)
    if object == null: return null
    
    var method_list: Array[Dictionary]
    var script: Script = object.get_script()
    if script != null: method_list = script.get_script_method_list()
    else: method_list = object.get_method_list()
    
    var info: MethodInfo = null
    for method_dict in method_list:
        if method_dict["name"] == method:
            var arr: Array = method_dict["args"]
            info = MethodInfo.new()
            info.arg_count = arr.size()
            var return_info: Dictionary = method_dict["return"]
            if return_info["type"] == TYPE_BOOL:
                info.check_return = true
            elif return_info["type"] == TYPE_NIL and return_info["usage"] & PROPERTY_USAGE_NIL_IS_VARIANT != 0:
                info.check_return = true
            _methods_arg_infos[method] = info
            break
    return info


class MethodInfo:
    var arg_count: int
    var check_return: bool

func _parse_methods(ctx: Context, object: Object) -> Dictionary:
    var dict := {}
    var script: Script = object.get_script() as Script
    
    var methods: Array[Dictionary]
    if script != null: methods = script.get_script_method_list()
    else: methods = object.get_method_list()
    
    for method in methods:
        var name: String = method["name"]
        var return_info: Dictionary = method["return"]
        const FLAG_STATIC = 32
        if ctx.compat.engine_version >= 0x040200 and (method["flags"] & FLAG_STATIC) != FLAG_STATIC:
            continue
        dict[name] = return_info
    return dict
