@tool
extends MarginContainer

const Context = preload("./../context.gd")
const Compat = Context.Compatibility
#const ScanResult = preload("./scan_result.gd")
#const ScanCache = preload("./scan_cache.gd")
const RLinkMap = preload(Context.RLINK_PATH + "rlink_map.gd")
const RLinkData = preload(Context.RLINK_PATH + "rlink_data.gd")
#const RLinkDataCache = preload("./rlink_data_cache.gd")

enum ContextActions {
    Edit,
    SetCurrentAsDefault,
    Reset,
    Clear,
}

signal pressed

var __ctx: Context
#var ___undo_redo: RLinkUndoRedo
var __compat: Compat
var __rlink_map: RLinkMap
#var __scan_cache: ScanCache
#var __rlink_data_cache: RLinkDataCache

#var _object_id: int
var _data_id: int
var _data: RLinkData:
    get: return instance_from_id(_data_id)
var _property: StringName
var property_is_readonly: bool = false
var _button_id: int
var _rlink_button: RLinkButton:
    get: return instance_from_id(_button_id)
var _button_id_cs: int
var _rlink_button_cs: RLinkButtonCS:
    get: return instance_from_id(_button_id_cs)
var _on_id_pressed_callable: Callable
var _box: HBoxContainer
var _button: Button
var _max_width := 200.0
var _size_override: int = -1
        

func _init(context: Context, data: RLinkData, property: String, rlink_button: Resource = null) -> void:
    __ctx = context
    #___undo_redo = context.undo_redo
    __compat = context.compat
    __rlink_map = context.rlink_map
    #__scan_cache = context.scan_cache
    #__rlink_data_cache = context.rlink_data_cache
    _data_id = data.get_instance_id()
    _property = property
    
    theme = context.button_theme
    
    _box = HBoxContainer.new()
    _button = Button.new()
    _button.expand_icon = true
    _button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _button.theme_type_variation = &"IconButton"
    _button.text = property.capitalize()
    _button.pressed.connect(_on_pressed)
    _button.gui_input.connect(_on_gui_input)

    _box.add_child(_button)
    add_child(_box)
    resized.connect(_on_resize)
    _on_resize()
    
    if rlink_button == null: return

    data.busy_changed.connect(_on_busy_changed)
    if rlink_button is RLinkButton:
        setup(rlink_button, property)
    elif rlink_button.get_script() == __ctx.csharp_button_script:
        setup_cs(rlink_button, property)


func setup(rlink_button: RLinkButton, property: String) -> void:
    _on_id_pressed_callable = _on_id_pressed
    _button_id = rlink_button.get_instance_id()
    if not rlink_button.has_meta(&"default_values"):
        if rlink_button.text.is_empty():
            rlink_button.text = property.capitalize()
        rlink_button.set_current_as_default()
        _data.create_action("Buttons set default", UndoRedo.MERGE_ALL)
        _data.reflect_to_runtime(_rlink_button)
        _data.flush_changes()
        _data.commit_action()
        
    _rlink_button.changed.connect(_on_rlink_button_changed)
    _on_rlink_button_changed()
    
    
func setup_cs(rlink_button_cs: Resource, property: String) -> void:
    _on_id_pressed_callable = _on_id_pressed_cs
    _button_id_cs = rlink_button_cs.get_instance_id()
    if not rlink_button_cs.has_meta(&"default_values"):
        if rlink_button_cs.Text.is_empty():
            rlink_button_cs.Text = property.capitalize()
        rlink_button_cs.SetCurrentAsDefault()
        _data.create_action("Buttons set default", UndoRedo.MERGE_ALL)
        _data.reflect_to_runtime(rlink_button_cs)
        _data.flush_changes()
        _data.commit_action()
        
    _rlink_button_cs.changed.connect(_on_rlink_button_changed_cs)
    _on_rlink_button_changed_cs()


func _on_busy_changed(_status: bool, _id: int) -> void:
    var disabled: bool
    if _rlink_button != null:
        disabled = _rlink_button.disabled
    elif _rlink_button_cs != null:
        disabled = _rlink_button_cs.Disabled

    _button.disabled = _data.busy or property_is_readonly or disabled

    
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
    _button.disabled = _data.busy or property_is_readonly or _rlink_button.disabled
    _button.clip_text = _rlink_button.clip_text
    _button.custom_minimum_size.y = _rlink_button.min_height
    _button.modulate = _rlink_button.modulate
    
    add_theme_constant_override(&"margin_left", _rlink_button.margin_left)
    add_theme_constant_override(&"margin_top", _rlink_button.margin_top)
    add_theme_constant_override(&"margin_right", _rlink_button.margin_right)
    add_theme_constant_override(&"margin_bottom", _rlink_button.margin_bottom)
    _on_resize()


func _on_rlink_button_changed_cs() -> void:
    if not "MaxWidth" in _rlink_button_cs: return
    _max_width = _rlink_button_cs.MaxWidth
    _size_override = _rlink_button_cs.SizeFlags

    if _rlink_button_cs.IconTexture != null:
        _button.icon = _rlink_button_cs.IconTexture
    elif _rlink_button_cs.icon:
        _button.icon = __compat.get_editor_theme().get_icon(_rlink_button_cs.Icon, "EditorIcons")

    _button.text = _rlink_button_cs.Text
    _button.tooltip_text = _rlink_button_cs.TooltipText
    _button.icon_alignment = _rlink_button_cs.IconAlignment as HorizontalAlignment
    _button.vertical_icon_alignment = _rlink_button_cs.IconAlignmentVertical as VerticalAlignment
    _button.disabled = _data.busy or property_is_readonly or _rlink_button_cs.Disabled
    _button.clip_text = _rlink_button_cs.ClipText
    _button.custom_minimum_size.y = _rlink_button_cs.MinHeight
    _button.modulate = _rlink_button_cs.Modulate
    
    add_theme_constant_override(&"margin_left", _rlink_button_cs.MarginLeft)
    add_theme_constant_override(&"margin_top", _rlink_button_cs.MarginTop)
    add_theme_constant_override(&"margin_right", _rlink_button_cs.MarginRight)
    add_theme_constant_override(&"margin_bottom", _rlink_button_cs.MarginBottom)
    _on_resize()

    
func _on_pressed() -> void:
    if _data == null: return
    if _rlink_button != null:
        _data.call_rlink_button(_property)
    elif _rlink_button_cs != null:
        _data.call_rlink_button_cs(_property)
    else:
        _data.call_callable(_property)
    pressed.emit()
    

func _on_resize() -> void:
    if size.x <= _max_width * __compat.get_editor_scale():
        _button.custom_minimum_size.x = 0
        _box.size_flags_horizontal = Control.SIZE_FILL
    else:
        _button.custom_minimum_size.x = _max_width * __compat.get_editor_scale()
        _box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if _size_override < 0 else _size_override


func _on_gui_input(input_event: InputEvent) -> void:
    if _rlink_button == null and _rlink_button_cs == null: return
    
    var event := input_event as InputEventMouseButton
    if event and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        var ed_theme := __compat.get_editor_theme()
        var edit_icon := ed_theme.get_icon("Edit", "EditorIcons")
        var reload_icon := ed_theme.get_icon("Reload", "EditorIcons")
        var clear_icon := ed_theme.get_icon("Clear", "EditorIcons")
        var bucket_icon := ed_theme.get_icon("Bucket", "EditorIcons")
        __ctx.popup.clear()
        __ctx.popup.add_icon_item(edit_icon, "Edit", ContextActions.Edit)
        __ctx.popup.add_icon_item(bucket_icon, "Set Current as Default", ContextActions.SetCurrentAsDefault)
        __ctx.popup.add_icon_item(reload_icon, "Reset", ContextActions.Reset)
        __ctx.popup.add_icon_item(clear_icon, "Clear", ContextActions.Clear)
        __ctx.popup.id_pressed.connect(_on_id_pressed_callable)
        __ctx.popup.popup_hide.connect(_on_hide)
        __ctx.popup.position = _button.get_screen_position() + event.position
        __ctx.popup.reset_size()
        __ctx.popup.popup()


func _on_id_pressed(id: int) -> void:
    if _data == null or _data.busy: return
    if id == ContextActions.Edit:
        var obj := _data.runtime
        var rlink_runtime: Resource = __rlink_map.runtime_from_obj(_rlink_button)
        
        if rlink_runtime == null:
            _data.create_action("Create '%s'" % _rlink_button.text)
            rlink_runtime = _data.reflect_to_runtime(_rlink_button, 1)
            _data.object_add_changes(obj, _property, null, rlink_runtime)
            _data.__undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
            _data.__undo_redo.add_do_method(obj, "notify_property_list_changed")
            _data.flush_changes()
            _data.__undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
            _data.__undo_redo.add_do_method(obj, "notify_property_list_changed")
            _data.commit_action()
            #_data.reflect_to_tool(rlink_runtime)
            
        __compat.interface.edit_resource(rlink_runtime)
        
    elif id == ContextActions.SetCurrentAsDefault:
        _rlink_button.set_current_as_default()
        _data.create_action("Set Current as Default '%s'" % _rlink_button.text)
        _data.reflect_to_runtime(_rlink_button)
        _data.flush_changes()
        _data.commit_action()
        
    elif id == ContextActions.Reset:
        _rlink_button.restore_default()
        _data.create_action("Reset '%s'" % _rlink_button.text)
        _data.reflect_to_runtime(_rlink_button)
        _data.flush_changes()
        _data.commit_action()
        
    elif id == ContextActions.Clear:
        var rlink_runtime: RLinkButton = __ctx.rlink_map.runtime_from_obj(_rlink_button)
        if rlink_runtime == null: return
        
        var obj := _data.runtime
        _data.create_action("Clear '%s'" % _rlink_button.text, UndoRedo.MERGE_DISABLE, obj)
        _data.object_add_changes(obj, _property, rlink_runtime, null)
        _data.__undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
        _data.__undo_redo.add_do_method(__ctx.rlink_map, "clear")
        _data.__undo_redo.add_do_method(obj, "notify_property_list_changed")
        _data.flush_changes()
        _data.__undo_redo.add_undo_method(__ctx.rlink_data_cache, "clear")
        _data.__undo_redo.add_undo_method(__ctx.rlink_map, "clear")
        _data.__undo_redo.add_undo_method(obj, "notify_property_list_changed")
        _data.__undo_redo.add_undo_method(__ctx.rlink_inspector, "establish_tracking", obj, _property)
        _data.commit_action()


func _on_id_pressed_cs(id: int) -> void:
    if _data == null or _data.busy: return
    if id == ContextActions.Edit:
        var obj := _data.runtime
        var rlink_runtime_cs: Resource = __rlink_map.runtime_from_obj(_rlink_button_cs)
        
        if rlink_runtime_cs == null:
            _data.create_action("Create '%s'" % _rlink_button_cs.Text)
            rlink_runtime_cs = _data.reflect_to_runtime(_rlink_button_cs, 1)
            _data.object_add_changes(obj, _property, null, rlink_runtime_cs)
            _data.__undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
            _data.__undo_redo.add_do_method(obj, "notify_property_list_changed")
            _data.flush_changes()
            _data.__undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
            _data.__undo_redo.add_do_method(obj, "notify_property_list_changed")
            _data.commit_action()
            #_data.reflect_to_tool(rlink_runtime)
            
        __compat.interface.edit_resource(rlink_runtime_cs)
        
    elif id == ContextActions.SetCurrentAsDefault:
        _rlink_button_cs.SetCurrentAsDefault()
        _data.create_action("Set Current as Default '%s'" % _rlink_button_cs.Text)
        _data.reflect_to_runtime(_rlink_button_cs)
        _data.flush_changes()
        _data.commit_action()
        
    elif id == ContextActions.Reset:
        _rlink_button_cs.RestoreDefault()
        _data.create_action("Reset '%s'" % _rlink_button_cs.Text)
        _data.reflect_to_runtime(_rlink_button_cs)
        _data.flush_changes()
        _data.commit_action()
        
    elif id == ContextActions.Clear:
        var rlink_runtime_cs: Resource = __ctx.rlink_map.runtime_from_obj(_rlink_button_cs)
        if rlink_runtime_cs == null: return
        
        var obj := _data.runtime
        _data.create_action("Clear '%s'" % _rlink_button_cs.Text, UndoRedo.MERGE_DISABLE, obj)
        _data.object_add_changes(obj, _property, rlink_runtime_cs, null)
        _data.__undo_redo.add_do_method(__ctx.rlink_data_cache, "clear")
        _data.__undo_redo.add_do_method(__ctx.rlink_map, "clear")
        _data.__undo_redo.add_do_method(obj, "notify_property_list_changed")
        _data.flush_changes()
        _data.__undo_redo.add_undo_method(__ctx.rlink_data_cache, "clear")
        _data.__undo_redo.add_undo_method(__ctx.rlink_map, "clear")
        _data.__undo_redo.add_undo_method(obj, "notify_property_list_changed")
        _data.__undo_redo.add_undo_method(__ctx.rlink_inspector, "establish_tracking", obj, _property)
        _data.commit_action()


func _on_hide() -> void:
    __ctx.popup.popup_hide.disconnect(_on_hide)
    _on_hide_deferred.call_deferred()
    
    
func _on_hide_deferred() -> void:
    __ctx.popup.id_pressed.disconnect(_on_id_pressed_callable)
