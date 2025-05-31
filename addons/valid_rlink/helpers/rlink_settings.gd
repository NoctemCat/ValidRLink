@tool
class_name RLinkSettings
extends RefCounted


var skip_script: bool
var skip_properties: PackedStringArray 
var validate_name: StringName


func _init(settings: Dictionary = {}) -> void:
    skip_script = settings.get("skip_script", false)
    skip_properties = settings.get("skip_properties", PackedStringArray())
    validate_name = settings.get("validate_name", StringName())
    
    
func set_skip_script(is_skipped: bool) -> RLinkSettings:
    skip_script = is_skipped
    return self


func set_skip_properties(properties: PackedStringArray) -> RLinkSettings:
    skip_properties = properties
    return self


func add_skip_property(property: String) -> RLinkSettings:
    skip_properties.append(property)
    return self
    
    
func set_validate_name(name: StringName) -> RLinkSettings:
    validate_name = name
    return self
