@tool
class_name RLinkSettings
extends Resource
## Specifies settings on a class level

@export var skip: bool ## If true, this class will never get duplicated
@export var skip_properties: Array[StringName] ## Exported properties to skip by names
@export var allowed_properties: Array[StringName] ## If not empty, will only allow exported properties mentioned here
@export var validate_name: StringName ## Specifies custom validate method name, if not found, doesn't search for default names
@export var max_depth: int ## Custom maximum copy depth, recursively copies objects until max depth is reached


func _init(settings: Dictionary = {}) -> void:
    skip = settings.get("skip", false)
    skip_properties = settings.get("skip_properties", Array([], TYPE_STRING_NAME, &"", null))
    allowed_properties = settings.get("allowed_properties", Array([], TYPE_STRING_NAME, &"", null))
    validate_name = settings.get("validate_name", StringName())
    max_depth = settings.get("max_depth", int())

    
## If true, this class will never get duplicated
func set_skip(is_skipped: bool) -> RLinkSettings:
    skip = is_skipped
    return self


## Exported properties to skip by names
func set_skip_properties(properties: Array[StringName]) -> RLinkSettings:
    skip_properties = properties
    return self


## Exported properties to skip by names
func append_skip_property(property: StringName) -> RLinkSettings:
    skip_properties.append(property)
    return self


## If not empty, will only allow exported properties mentioned here
func set_allowed_properties(properties: Array[StringName]) -> RLinkSettings:
    allowed_properties = properties
    return self


## If not empty, will only allow exported properties mentioned here
func append_allowed_property(property: StringName) -> RLinkSettings:
    allowed_properties.append(property)
    return self

    
## Specifies custom validate method name, if not found, doesn't search for default names
func set_validate_name(name: StringName) -> RLinkSettings:
    validate_name = name
    return self


## Custom maximum copy depth, recursively copies objects until max depth is reached
func set_max_depth(depth: int) -> RLinkSettings:
    max_depth = depth
    return self
