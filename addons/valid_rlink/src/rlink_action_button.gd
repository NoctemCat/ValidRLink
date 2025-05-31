@tool
extends MarginContainer

const Context = preload("./../context.gd")
const Compat = Context.Compatibility

const RLinkUndoRedo = preload("./rlink_undo_redo.gd")

var __ctx: Context
var __undo_redo: RLinkUndoRedo
var __compat: Compat

signal pressed
var _object_id: int
var _property: String
var _rlink_button: RLinkButton
var _is_callable: bool:
    get: return _rlink_button == null
var _box: HBoxContainer
var _button: Button
var _max_width := 200.0
var _size_override: int = -1
var _less_than_max_width: bool:
    set(value): 
        if _less_than_max_width == value: return
        _less_than_max_width = value
        _set_on_resize_toggled(_less_than_max_width)
        

func _init(context: Context, object_id: int, property: String, rlink_button: RLinkButton = null) -> void:
    __ctx = context
    __undo_redo = context.undo_redo
    __compat = context.compat
    _object_id = object_id
    _property = property
    
    theme = context.button_theme
    
    add_theme_constant_override("margin_top", 2)

    _box = HBoxContainer.new()
    _button = ActionButton.new(self)
    _button.text = _property.capitalize()
    _button.pressed.connect(_on_pressed)

    _box.add_child(_button)
    add_child(_box)
    resized.connect(_on_resize)
    _on_resize()
    
    if rlink_button == null: return
    _rlink_button = rlink_button
    if not rlink_button.has_meta("default_stored"):
        if rlink_button.text.is_empty():
            rlink_button.text = property.capitalize()
        prints('setting', property)
        rlink_button._set_current_as_default()
    
    _rlink_button.changed.connect(_on_rlink_button_changed)
    _on_rlink_button_changed()


func _on_rlink_button_changed() -> void:
    _max_width = _rlink_button.max_width
    _size_override = _rlink_button.size_flags

    if _rlink_button.icon_texture != null:
        _button.icon = _rlink_button.icon_texture
    elif _rlink_button.icon:
        _button.icon = __compat.get_editor_theme().get_icon(_rlink_button.icon, "EditorIcons")

    _button.text = _rlink_button.text   
    _button.tooltip_text = _rlink_button.tooltip_text
    _button.icon_alignment = _rlink_button.icon_alignment
    _button.vertical_icon_alignment = _rlink_button.icon_alignment_vertical
    _button.disabled = _rlink_button.disabled
    _button.clip_text = _rlink_button.clip_text
    _button.custom_minimum_size.y = _rlink_button.min_height
    _button.modulate = _rlink_button.modulate
    _on_resize()
    
    
func _on_pressed() -> void:
    pressed.emit()
    

func _on_resize() -> void:
    _less_than_max_width = size.x <= _max_width * __compat.get_editor_scale()


func _set_on_resize_toggled(toggle: bool) -> void:
    if toggle:
        _button.custom_minimum_size.x = 0
        _box.size_flags_horizontal = Control.SIZE_FILL
    else:
        _button.custom_minimum_size.x = _max_width * __compat.get_editor_scale()
        _box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if _size_override < 0 else _size_override


func _on_gui_input(input_event: InputEvent) -> void:
    if _is_callable: return
    var event := input_event as InputEventMouseButton
    if event and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: 
        var ed_theme := __compat.get_editor_theme()
        var edit_icon := ed_theme.get_icon("Edit", "EditorIcons")
        var reload_icon := ed_theme.get_icon("Reload", "EditorIcons")
        var clear_icon := ed_theme.get_icon("Clear", "EditorIcons")
        __ctx.popup.clear()
        __ctx.popup.add_icon_item(edit_icon, "Edit", 0)
        __ctx.popup.add_icon_item(reload_icon, "Reset", 1)
        __ctx.popup.add_icon_item(clear_icon, "Clear", 2)
        __ctx.popup.id_pressed.connect(_on_id_pressed)
        __ctx.popup.popup_hide.connect(_on_hide)
        __ctx.popup.position = _button.get_screen_position() + event.position
        __ctx.popup.reset_size()
        __ctx.popup.popup()


func _on_id_pressed(id: int) -> void:
    if id == 0:
        var obj := instance_from_id(_object_id)
        @warning_ignore("unsafe_method_access")
        var runtime: Object = __ctx.rlink_map.runtime_from_obj(_rlink_button)
        
        if runtime == null: 
            __undo_redo.create_action("Create '%s'" % _rlink_button.text, UndoRedo.MERGE_DISABLE, obj)
            runtime = __ctx.converter_to_runtime.convert_value(_rlink_button, 1)
            __undo_redo.add_changes(obj, _property, null, runtime)
            __undo_redo._undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
            __undo_redo._undo_redo.add_do_method(obj, "notify_property_list_changed")
            __undo_redo.flush_changes()
            __undo_redo._undo_redo.add_undo_method(__ctx.rlink_data_cache, "clear")
            __undo_redo._undo_redo.add_undo_method(obj, "notify_property_list_changed")
            __undo_redo.commit_action()
            __ctx.converter_to_tool.convert_value(runtime, -1)
            
        __compat.interface.edit_resource(runtime)
    elif id == 1:
        _rlink_button._restore_default()
        _set_on_resize_toggled(size.x <= _max_width * __compat.get_editor_scale())
        var runtime: RLinkButton = __ctx.rlink_map.runtime_from_obj(_rlink_button)
        if runtime == null: return
        var obj := instance_from_id(_object_id)
        __undo_redo.create_action("Reset '%s'" % _rlink_button.text, UndoRedo.MERGE_DISABLE, obj)
        var run = __ctx.converter_to_runtime.convert_value(_rlink_button, 1)
        __undo_redo.flush_changes()
        __undo_redo.commit_action()
    elif id == 2:
        var runtime: RLinkButton = __ctx.rlink_map.runtime_from_obj(_rlink_button)
        if runtime == null: return
        var obj := instance_from_id(_object_id)
        
        __undo_redo.create_action("Clear '%s'" % _rlink_button.text, UndoRedo.MERGE_DISABLE, obj)
        __undo_redo.add_changes(obj, _property, runtime, null)
        __undo_redo._undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
        __undo_redo._undo_redo.add_do_method(__ctx.rlink_map, "clear")
        __undo_redo._undo_redo.add_do_method(obj, "notify_property_list_changed")
        __undo_redo.flush_changes()
        __undo_redo._undo_redo.add_undo_method(__ctx.rlink_data_cache, "clear")
        __undo_redo._undo_redo.add_undo_method(__ctx.rlink_map, "clear")
        __undo_redo._undo_redo.add_undo_method(obj, "notify_property_list_changed")
        __undo_redo._undo_redo.add_undo_method(__ctx.rlink_inspector, "establish_tracking", obj, _property)
        __undo_redo.commit_action()    


func _on_hide() -> void:
    __ctx.popup.popup_hide.disconnect(_on_hide)
    _on_hide_deferred.call_deferred()
    
    
func _on_hide_deferred() -> void:
    __ctx.popup.id_pressed.disconnect(_on_id_pressed)


class ActionButton extends Button:
    var parent: Control
    func _init(in_parent: Control) -> void:
        parent = in_parent
        expand_icon = true
        size_flags_horizontal = Control.SIZE_EXPAND_FILL
        theme_type_variation = &"IconButton"
        
    func _gui_input(event: InputEvent) -> void:
        parent._on_gui_input(event)
