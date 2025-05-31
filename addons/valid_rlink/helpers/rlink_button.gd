@tool
class_name RLinkButton
extends Resource


const CLASS_NAME = "RLinkButton"

enum ControlSizes {
    SIZE_UNSET = -1,
    SIZE_SHRINK_BEGIN = 0,
    SIZE_FILL = 1,
    SIZE_EXPAND = 2,
    SIZE_EXPAND_FILL = 3,
    SIZE_SHRINK_CENTER = 4,
    SIZE_SHRINK_END = 8,
}

@export
var text: String:
    set(value):
        var new := text != value
        text = value
        if new: emit_changed()
        
@export
var tooltip_text: String:
    set(value):
        var new := tooltip_text != value
        tooltip_text = value
        if new: emit_changed()
        
@export
var icon: String:
    set(value):
        if value: icon_texture = null
        var new := text != value
        icon = value
        if new: emit_changed()
        
@export
var icon_texture: Texture2D:
    set(value):
        if value: icon = ""
        var new := icon_texture != value
        icon_texture = value
        if new: emit_changed()

@export
var icon_alignment: HorizontalAlignment:
    set(value):
        var new := icon_alignment != value
        icon_alignment = value
        if new: emit_changed()

@export
var icon_alignment_vertical: VerticalAlignment:
    set(value):
        var new := icon_alignment_vertical != value
        icon_alignment_vertical = value
        if new: emit_changed()
        
@export
var modulate: Color:
    set(value):
        var new := modulate != value
        modulate = value
        if new: emit_changed()
        
@export          
var max_width: int:
    set(value):
        var new := max_width != value
        max_width = value
        if new: emit_changed()

@export          
var min_height: int:
    set(value):
        var new := min_height != value
        min_height = value
        if new: emit_changed()
        
@export    
var disabled: bool:
    set(value):
        var new := disabled != value
        disabled = value
        if new: emit_changed()

@export      
var clip_text: bool:
    set(value):
        var new := clip_text != value
        clip_text = value
        if new: emit_changed()


@export var size_flags: ControlSizes:
    set(value):
        var new := size_flags != value
        size_flags = value
        if new: emit_changed() 
        
        
@export_group("Callable")
var _object_id: int
@export var _args: Array
var bind_arg_count: int: 
    get: return _args.size()
@export var _unbind_next: int
var unbind_next: int: 
    get: return _unbind_next
@export var method_name: StringName


func _init(callable: Callable = Callable(), properties: Dictionary = Dictionary()) -> void:
    _unbind_next = 0
    icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
    icon_alignment_vertical = VERTICAL_ALIGNMENT_CENTER
    modulate = Color.WHITE
    max_width = 200
    clip_text = true
    size_flags = -1
    
    if not callable.is_valid(): return
    if callable.is_custom():
        push_error("ValidRLink: Only supports standart callables [rlink_button._init]")
        return
    set_object(callable.get_object())
    method_name = callable.get_method()
    set_dictioanary(properties)
    

func _property_can_revert(property: StringName) -> bool:
    if has_meta(&"default_stored"):
        var defaults: Dictionary = get_meta(&"default_values")
        return defaults.has(property)
    return false


func _property_get_revert(property: StringName) -> Variant:
    if has_meta(&"default_stored"):
        var defaults: Dictionary = get_meta(&"default_values")
        return defaults[property]
    return null


func _reset_state() -> void:
    _restore_default()


func set_object(object: Object) -> void:
    if _object_id != object.get_instance_id():
        _object_id = object.get_instance_id()


func set_dictioanary(properties: Dictionary) -> void:
    for prop_name in properties:
        if prop_name in self: set(prop_name, properties[prop_name])


func rlink_call(arg: Variant = null) -> Variant:
    var args := []
    if arg != null: args.push_front(arg)
    return rlink_callv(args)
    
    
func rlink_callv(args: Array) -> Variant:
    assert(is_instance_id_valid(_object_id))
    
    var copy := args.duplicate()
    var unbind_next := _unbind_next
    while copy and unbind_next > 0:
        unbind_next -= 1
        copy.pop_back()
    if unbind_next > 0:
        push_error("ValidRLink: Invalid call to function '%s'. Expected -%d arguments [rlink_button.rlink_callv]" % [get_method_name(), unbind_next])
        return
        
    var call_copy := _args.duplicate()
    for i in copy.size():
        call_copy.insert(i, copy[i])
        
    return instance_from_id(_object_id).callv(method_name, call_copy)


func bind(arg: Variant) -> RLinkButton:
    if _unbind_next > 0: 
        _unbind_next -= 1
        return self
    _args.push_front(arg)
    return self
    
    
func bindv(args: Array) -> RLinkButton:
    var copy := args.duplicate()
    while copy and _unbind_next > 0:
        _unbind_next -= 1
        copy.pop_back()
        
    for i in copy.size():
        _args.insert(i, copy[i])
    return self
    
    
func unbind(argcount: int) -> RLinkButton:
    if argcount <= 0:
        push_error("ValidRLink: Amount of unbind() arguments must be 1 or greater [rlink_button.unbind]")
        return self
    _unbind_next += argcount
    return self
    
    
func get_method_name() -> StringName:
    return method_name


func set_text(in_text: String) -> RLinkButton:
    text = in_text
    return self
    
func set_tooltip_text(in_text: String) -> RLinkButton:
    tooltip_text = in_text
    return self

func set_icon(in_icon: String) -> RLinkButton:
    icon = in_icon
    return self
    
func set_icon_texture(in_icon: Texture2D) -> RLinkButton:
    icon_texture = in_icon
    return self
    
func set_icon_alignment(alignment: HorizontalAlignment) -> RLinkButton:
    icon_alignment = alignment
    return self
    
func set_icon_alignment_vertical(alignment: VerticalAlignment) -> RLinkButton:
    icon_alignment_vertical = alignment
    return self
    
func set_modulate(color: Color) -> RLinkButton:
    modulate = color
    return self
    
func set_max_width(width: int) -> RLinkButton:
    max_width = width
    return self
    
func set_min_height(height: int) -> RLinkButton:
    min_height = height
    return self
    
func set_disabled(in_disabled: bool = true) -> RLinkButton:
    disabled = in_disabled
    return self
    
func set_size_flags(in_size_flags: ControlSizes) -> RLinkButton:
    size_flags = in_size_flags
    return self

func toggle_disabled() -> RLinkButton:
    disabled = !disabled
    return self


func _to_string() -> String:
    return "%s.%s" % [CLASS_NAME, method_name]


func _set_current_as_default() -> void:
    var defaults = {}
    for prop in get_property_list():
        if prop["usage"] & PROPERTY_USAGE_STORAGE != 0 and prop["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE: 
            var prop_name = StringName(prop["name"])
            defaults[prop_name] = get(prop_name)
    set_meta(&"default_values", defaults)
    set_meta(&"default_stored", true)

    
func _restore_default() -> void:
    var defaults: Dictionary = get_meta(&"default_values", {})
    set_dictioanary(defaults)
