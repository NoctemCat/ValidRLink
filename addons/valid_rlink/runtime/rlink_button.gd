@tool
class_name RLinkButton
extends Resource
## Turns a method from non-tool class into a button in editor

const CLASS_NAME = "RLinkButton"
const CLASS_NAME_CS = "RLinkButtonCS"

## Sizes from [Control] with possible unset
enum ControlSizes {
    SIZE_UNSET = -1,
    SIZE_SHRINK_BEGIN = 0,
    SIZE_FILL = 1,
    SIZE_EXPAND = 2,
    SIZE_EXPAND_FILL = 3,
    SIZE_SHRINK_CENTER = 4,
    SIZE_SHRINK_END = 8,
}

static var get_unbound_count_expr: Expression = null ## Calls [method Callable.get_unbound_arguments_count] through [Expression]
static var unbound_count_available: bool ## Is true if current Godot version supports it

@export
var text: String: ## The button's text that will be displayed inside the button's area
    set(value):
        var new := text != value
        text = value
        if new: emit_changed()
@export
var tooltip_text: String: ## Sets [member Control.tooltip_text]
    set(value):
        var new := tooltip_text != value
        tooltip_text = value
        if new: emit_changed()
@export
var icon: String: ## Sets editor icon by name, setting it unsets [member icon_texture]
    set(value):
        if value: icon_texture = null
        var new := text != value
        icon = value
        if new: emit_changed()
@export
var icon_texture: Texture2D: ## Sets texture as icon, unsets [member icon]
    set(value):
        if value: icon = ""
        var new := icon_texture != value
        icon_texture = value
        if new: emit_changed()
@export
var icon_alignment: HorizontalAlignment: ## Icon behavior for [member Button.icon_alignment]
    set(value):
        var new := icon_alignment != value
        icon_alignment = value
        if new: emit_changed()
@export
var icon_alignment_vertical: VerticalAlignment: ## Icon behavior for [member Button.vertical_icon_alignment]
    set(value):
        var new := icon_alignment_vertical != value
        icon_alignment_vertical = value
        if new: emit_changed()
@export
var modulate: Color: ## Modulates button
    set(value):
        var new := modulate != value
        modulate = value
        if new: emit_changed()
@export
var max_width: int: ## Sets maximum width, can be shrunk
    set(value):
        var new := max_width != value
        max_width = value
        if new: emit_changed()
@export
var min_height: int: ## Sets minimum height, can't be shrunk
    set(value):
        var new := min_height != value
        min_height = value
        if new: emit_changed()
@export
var margin_left: int: ## Sets left margin
    set(value):
        var new := margin_left != value
        margin_left = value
        if new: emit_changed()
@export
var margin_top: int: ## Sets top margin
    set(value):
        var new := margin_top != value
        margin_top = value
        if new: emit_changed()
@export
var margin_right: int: ## Sets right margin
    set(value):
        var new := margin_right != value
        margin_right = value
        if new: emit_changed()
@export
var margin_bottom: int: ## Sets bottom margin
    set(value):
        var new := margin_bottom != value
        margin_bottom = value
        if new: emit_changed()
@export
var disabled: bool: ## Sets disabled on the button
    set(value):
        var new := disabled != value
        disabled = value
        if new: emit_changed()
@export
var clip_text: bool: ## Sets clip text on the button
    set(value):
        var new := clip_text != value
        clip_text = value
        if new: emit_changed()
## If size is less than max width the flag is always SIZE_FILL, else it's SIZE_SHRINK_CENTER. 
## This allows to override the flag to other when the size of container is more than 
## its max width
@export var size_flags: ControlSizes:
    set(value):
        var new := size_flags != value
        size_flags = value
        if new: emit_changed()
        
@export_group("Callable")

## The args that will be passed to method using Callable rules
@export var bound_args: Array
## Unbind next args using normal Callable rules
@export var unbind_next: int
## Method that will be called
@export var callable_method_name: StringName
## If true, the method result will get checked. If the result is false or Variant 
## null will discard changes
var needs_check: bool

var _object_id: int
var _script_id: int
var _base_arg_count: int


static func _static_init() -> void:
    unbound_count_available = Engine.get_version_info()["hex"] >= 0x040400
    if unbound_count_available:
        get_unbound_count_expr = Expression.new()
        get_unbound_count_expr.parse("callable.get_unbound_arguments_count()", ["callable"])
    

## [param method] can be either [Callable] or name as a [String]
func _init(method: Variant = null, properties: Dictionary = Dictionary()) -> void:
    unbind_next = 0
    icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
    icon_alignment_vertical = VERTICAL_ALIGNMENT_CENTER
    modulate = Color.WHITE
    max_width = 200
    clip_text = true
    size_flags = ControlSizes.SIZE_UNSET
    
    if method is Callable:
        if method == Callable(): return
        if "anonymous lambda" in method.get_method():
            push_error("ValidRLink: Doesn't support lambdas [rlink_button._init]")
            return

        set_object(method.get_object(), method.get_method())
        bound_args = method.get_bound_arguments()
        if unbound_count_available:
            unbind_next = get_unbound_count_expr.execute([method])
    elif method is StringName or method is String:
        callable_method_name = method
    set_dictioanary(properties)
    

func _property_can_revert(property: StringName) -> bool:
    if has_meta(&"default_values"):
        var defaults: Dictionary = get_meta(&"default_values")
        return defaults.has(property)
    return false


func _property_get_revert(property: StringName) -> Variant:
    if has_meta(&"default_values"):
        var defaults: Dictionary = get_meta(&"default_values")
        return defaults[property]
    return null


func _reset_state() -> void:
    restore_default()


## Sets object and, optionally, method to prepare it for calling
func set_object(object: Object, method: StringName = "") -> RLinkButton:
    var object_id := object.get_instance_id()
    if _object_id != object_id:
        _object_id = object_id
        _set_method(object, method if method else callable_method_name)
    return self


func _set_method(object: Object, method: StringName) -> void:
    var script: Script = object.get_script()
    var new_script_id: int = 0
    if script != null:
        new_script_id = script.get_instance_id()

    if _script_id != new_script_id or method != callable_method_name:
        _script_id = new_script_id
        needs_check = false
        _base_arg_count = 0
        callable_method_name = method

        var method_list: Array[Dictionary]
        if script != null: method_list = script.get_script_method_list()
        else: method_list = object.get_method_list()
        
        for method_dict in method_list:
            if method_dict["name"] == callable_method_name:
                var arr: Array = method_dict["args"]
                _base_arg_count = arr.size()
                var return_info: Dictionary = method_dict["return"]
                if return_info["type"] == TYPE_BOOL:
                    needs_check = true
                elif return_info["type"] == TYPE_NIL and (return_info["usage"] & PROPERTY_USAGE_NIL_IS_VARIANT) == PROPERTY_USAGE_NIL_IS_VARIANT:
                    needs_check = true
                break
    

## Sets exported properties by name from dictionary
func set_dictioanary(properties: Dictionary) -> RLinkButton:
    for prop_name in properties:
        if prop_name in self: set(prop_name, properties[prop_name])
    return self


## Calls stored method without waiting
func rlink_call(arg: Variant = null) -> Variant:
    var args := []
    if arg != null: args.push_front(arg)
    return rlink_callv(args)
    

## Calls stored method without waiting
func rlink_callv(args: Array) -> Variant:
    var call_copy: Variant = _get_args_copy(args)
    if call_copy == null: return
    return instance_from_id(_object_id).callv(callable_method_name, call_copy)


## Calls stored method with waiting
func rlink_call_await(arg: Variant = null) -> Variant:
    var args := []
    if arg != null: args.push_front(arg)
    return await rlink_callv_await(args)


## Calls stored method with waiting
func rlink_callv_await(args: Array) -> Variant:
    var call_copy: Variant = _get_args_copy(args)
    if call_copy == null: return
    return await instance_from_id(_object_id).callv(callable_method_name, call_copy)


func _get_args_copy(args: Array) -> Variant:
    var copy := args.duplicate()
    var unbind_next_copy := unbind_next
    while copy and unbind_next_copy > 0:
        unbind_next_copy -= 1
        copy.pop_back()
    if unbind_next_copy > 0:
        push_error("ValidRLink: Invalid call to function '%s'. Expected -%d arguments [rlink_button._get_args_copy]" % [get_method_name(), unbind_next])
        return null
        
    var call_copy := bound_args.duplicate()
    for i in copy.size():
        call_copy.insert(i, copy[i])
    return call_copy


## Adds argument that method will be called with
func bind(arg: Variant) -> RLinkButton:
    if unbind_next > 0:
        unbind_next -= 1
        return self
    bound_args.push_front(arg)
    return self
    

## Adds arguments that method will be called with
func bindv(args: Array) -> RLinkButton:
    var copy := args.duplicate()
    while copy and unbind_next > 0:
        unbind_next -= 1
        copy.pop_back()
        
    for i in copy.size():
        bound_args.insert(i, copy[i])
    return self
    

## Next arguments passed to bind or call will be ignored
func unbind(argcount: int) -> RLinkButton:
    if argcount <= 0:
        push_error("ValidRLink: Amount of unbind() arguments must be 1 or greater [rlink_button.unbind]")
        return self
    unbind_next += argcount
    return self
    

## Returns calculated argument count
func get_arg_count() -> int:
    return _base_arg_count - bound_args.size() + unbind_next
    

## Returns method that will be called
func get_method_name() -> StringName:
    return callable_method_name


## The button's text that will be displayed inside the button's area
func set_text(in_text: String) -> RLinkButton:
    text = in_text
    return self
    

## Sets [member Control.tooltip_text]
func set_tooltip_text(in_text: String) -> RLinkButton:
    tooltip_text = in_text
    return self


## Sets editor icon by name, setting it unsets [member icon_texture]
func set_icon(in_icon: String) -> RLinkButton:
    icon = in_icon
    return self
    

## Sets texture as icon, unsets [member icon]
func set_icon_texture(in_icon: Texture2D) -> RLinkButton:
    icon_texture = in_icon
    return self


## Icon behavior for [member Button.icon_alignment]
func set_icon_alignment(alignment: HorizontalAlignment) -> RLinkButton:
    icon_alignment = alignment
    return self


## Icon behavior for [member Button.vertical_icon_alignment]
func set_icon_alignment_vertical(alignment: VerticalAlignment) -> RLinkButton:
    icon_alignment_vertical = alignment
    return self


## Modulates button
func set_modulate(color: Color) -> RLinkButton:
    modulate = color
    return self


## Sets maximum width, can be shrunk
func set_max_width(width: int) -> RLinkButton:
    max_width = width
    return self


## Sets minimum height, can't be shrunk
func set_min_height(height: int) -> RLinkButton:
    min_height = height
    return self


## Sets left margin
func set_margin_left(margin: int) -> RLinkButton:
    margin_left = margin
    return self


## Sets top margin
func set_margin_top(margin: int) -> RLinkButton:
    margin_top = margin
    return self


## Sets right margin
func set_margin_right(margin: int) -> RLinkButton:
    margin_right = margin
    return self


## Sets bottom margin
func set_margin_bottom(margin: int) -> RLinkButton:
    margin_bottom = margin
    return self


## Sets disabled on the button
func set_disabled(in_disabled: bool = true) -> RLinkButton:
    disabled = in_disabled
    return self


## If size is less than max width the flag is always SIZE_FILL, else it's SIZE_SHRINK_CENTER. 
## This allows to override the flag to other when the size of container is more than 
## its max width
func set_size_flags(in_size_flags: ControlSizes) -> RLinkButton:
    size_flags = in_size_flags
    return self


## If size is less than max width the flag is always SIZE_FILL, else it's SIZE_SHRINK_CENTER. 
## This allows to override the flag to other when the size of container is more than 
## its max width
func set_size_flags_control(in_size_flags: Control.SizeFlags) -> RLinkButton:
    size_flags = in_size_flags as ControlSizes
    return self


## Sets disabled on the button
func toggle_disabled() -> RLinkButton:
    disabled = !disabled
    return self


## Stores current exported properties as default
func set_current_as_default() -> void:
    var defaults := {}
    var comb_flag: int = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
    for prop in get_property_list():
        if (prop["usage"] & comb_flag) == comb_flag:
            var prop_name: StringName = prop["name"]
            defaults[prop_name] = get(prop_name)
    set_meta(&"default_values", defaults)


## Sets exported properties to stored defaults
func restore_default() -> void:
    var defaults: Dictionary = get_meta(&"default_values", {})
    set_dictioanary(defaults)
