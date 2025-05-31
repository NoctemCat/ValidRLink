@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const Compat = Context.Compatibility

var object_id: int

var skip: bool = false
var validate_name: StringName = &""
var validate_arg_count: int = -1
var has_validate: bool:
    get: return validate_name != &""

var skip_properties: PackedStringArray = ["_import_path", "resource_path"]
var _methods_arg_counts: Dictionary


func _init(ctx: Context, object: Object) -> void: 
    #__settings = ctx.settings
    #var compat := ctx.compat
    object_id = object.get_instance_id()
    
    if object is Script:
        skip = true
        return
    
    var script: Script = object.get_script()
    if script != null:
        handle_script(ctx, object, script)
    else:
        handle_native(ctx, object)


func handle_native(ctx: Context, object: Object) -> void:
    handle_script(ctx, object, object)
        
        
func handle_script(ctx: Context, object: Object, script_or_native: Object) -> void:
    var rlink_settings: RLinkSettings = null
    for name in ctx.settings.get_rlink_settings_paths:
        # TODO: Check in 4.1
        if name in script_or_native:
            var settings = script_or_native.call(name)
            if settings is Dictionary:
                rlink_settings = RLinkSettings.new(settings)
            elif settings is RLinkSettings:
                rlink_settings = settings
            else:
                push_error("ValidRLink: get settings function must return 'RLinkSettings' or dictionary [scan_result.handle_script]")
                return
            break
            
    if rlink_settings != null:
        if rlink_settings.skip_script: 
            skip = true
            return
            
        if rlink_settings.validate_name != &"":
            validate_name = rlink_settings.validate_name
            if not ctx.compat.comp_has_method(object, validate_name):
                var script_name: String
                if script_or_native is Script:
                    script_name = script_or_native.resource_path.get_file() if script_or_native.resource_path else script_or_native.to_string()
                else:
                    script_name = script_or_native.get_class()
                push_error("ValidRLink: providied validate method '%s' is not found in '%s' [scan_result.handle_script]" % [validate_name, script_name])
                validate_name = &""
        
        skip_properties.append_array(rlink_settings.skip_properties)
    
    if validate_name == &"":
        for name in ctx.settings.validate_values_paths:
            if ctx.compat.comp_has_method(object, name):
                validate_name = name
                break
    if validate_name != &"":
        validate_arg_count = get_arg_count(validate_name)
    
    
func get_arg_count(method: StringName) -> int:
    var count: int = _methods_arg_counts.get(method, -1)
    if count != -1: return count
    
    var object := instance_from_id(object_id)
    if object == null: return -1
    
    for method_dict in object.get_method_list():
        if method_dict["name"] == method:
            var arr: Array = method_dict["args"]
            count = arr.size()
            _methods_arg_counts[method] = count
            break
    return count
