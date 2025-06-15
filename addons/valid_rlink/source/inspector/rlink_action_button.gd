@tool
extends MarginContainer

const Context = preload("./../context.gd")
const Compat = Context.Compatibility
const RLinkMap = preload(Context.RLINK_PATH + "rlink_map.gd")
const RLinkData = preload(Context.RLINK_PATH + "rlink_data.gd")
const RLinkBuffer = preload(Context.RLINK_PATH + "rlink_buffer.gd")

enum ContextActions {
    Edit,
    SetCurrentAsDefault,
    Reset,
    Clear,
}

signal pressed

var __ctx: Context
var __compat: Compat
var __rlink_map: RLinkMap

var _data_id: int
var _data: RLinkData:
    get: return instance_from_id(_data_id)
var _buffer: RLinkBuffer:
    get: return _data._buffer
var _property: StringName
var property_is_readonly: bool = false
var _button_id: int
var _rlink_button: RLinkButton:
    get: return instance_from_id(_button_id)
var _button_id_cs: int
var _rlink_button_cs: RefCounted:
# var _rlink_button_cs: RLinkButtonCS:
    get: return instance_from_id(_button_id_cs)
var _on_id_pressed_callable: Callable
var _box: HBoxContainer
var _button: Button
var _max_width := 200.0
var _size_override: int = -1
        

func _init(context: Context, data: RLinkData, property: String, rlink_button: Resource = null) -> void:
    __ctx = context
    __compat = context.compat
    __rlink_map = context.rlink_map
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
    
    if rlink_button == null: 
        _callable_set_default(property)
        return

    data.busy_changed.connect(_on_busy_changed)
    if rlink_button is RLinkButton:
        _setup(rlink_button, property)
    elif __ctx.csharp_enabled and rlink_button.get_script() == __ctx.csharp_button_script:
        _setup_cs(rlink_button, property)


func _callable_set_default(property: String) -> void:
    var default_btn: Resource = load(__ctx.settings.default_button_path)
    if default_btn == null or not default_btn is RLinkButton:
        return
    _button_id = default_btn.get_instance_id()
    _on_rlink_button_changed()
    _button_id = 0
    _button.text = property.capitalize()


func _setup(rlink_button: RLinkButton, property: String) -> void:
    _on_id_pressed_callable = _on_id_pressed
    _button_id = rlink_button.get_instance_id()
    if not rlink_button.has_meta(&"default_values"):
        if rlink_button.text.is_empty():
            rlink_button.text = property.capitalize()
        _set_default(rlink_button)
        rlink_button.set_current_as_default()
        var old_runtime: Resource = _data.runtime.get(property)
        var run_button: Resource = rlink_button.duplicate()
        _buffer.object_add_changes(_data.runtime, property, old_runtime, run_button)
        _buffer.create_action("Buttons Set Default", UndoRedo.MERGE_ALL, _data.runtime)
        _buffer.flush_changes()
        _buffer.commit_action()
        __rlink_map.add_pair(run_button, rlink_button)
        __ctx.converter_to_tool._connect_rlink_buttons(_buffer, run_button)
        
    _rlink_button.changed.connect(_on_rlink_button_changed)
    _on_rlink_button_changed()
    
    
func _setup_cs(rlink_button_cs: Resource, property: String) -> void:
    _on_id_pressed_callable = _on_id_pressed_cs
    _button_id_cs = rlink_button_cs.get_instance_id()
    if not rlink_button_cs.has_meta(&"default_values"):
        if rlink_button_cs.Text.is_empty():
            rlink_button_cs.Text = property.capitalize()
        _set_default(rlink_button_cs)
        rlink_button_cs.SetCurrentAsDefault()
        
        var old_runtime: Resource = _data.runtime.get(property)
        var run_button: Resource = rlink_button_cs.duplicate()
        _buffer.object_add_changes(_data.runtime, property, old_runtime, run_button)
        _buffer.create_action("Buttons Set Default", UndoRedo.MERGE_ALL, _data.runtime)
        _buffer.flush_changes()
        _buffer.commit_action()
        __rlink_map.add_pair(run_button, rlink_button_cs)
        __ctx.converter_to_tool._connect_rlink_buttons(_buffer, run_button)
        
    _rlink_button_cs.changed.connect(_on_rlink_button_changed_cs)
    _on_rlink_button_changed_cs()


func _set_default(rlink_button: Resource) -> void:
    var real_defaults: Dictionary = {
        icon_alignment = HORIZONTAL_ALIGNMENT_LEFT,
        icon_alignment_vertical = VERTICAL_ALIGNMENT_CENTER,
        modulate = Color.WHITE,
        max_width = 200,
        clip_text = true,
        size_flags = RLinkButton.ControlSizes.SIZE_UNSET,
    }
    
    if not __ctx.settings.default_button_path or not ResourceLoader.exists(__ctx.settings.default_button_path):
        return
        
    var default_btn: Resource = load(__ctx.settings.default_button_path)
    if default_btn == null or not default_btn is RLinkButton:
        return
    
    if rlink_button is RLinkButton:
        var comb_flag: int = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
        for prop in default_btn.get_property_list():
            if (prop["usage"] & comb_flag) != comb_flag: continue
            var prop_name: StringName = prop["name"]
            var current: Variant = rlink_button.get(prop_name)
            var default: Variant = real_defaults.get(prop_name)
            if not current or (default != null and current == default):
                rlink_button.set(prop_name, default_btn.get(prop_name))
    else:
        var map: Dictionary = {
            &"text": &"Text",
            &"tooltip_text": &"TooltipText",
            &"icon": &"Icon",
            &"icon_texture": &"IconTexture",
            &"icon_alignment": &"IconAlignment",
            &"icon_alignment_vertical": &"IconAlignmentVertical",
            &"modulate": &"Modulate",
            &"max_width": &"MaxWidth",
            &"min_height": &"MinHeight",
            &"margin_left": &"MarginLeft",
            &"margin_top": &"MarginTop",
            &"margin_right": &"MarginRight",
            &"margin_bottom": &"MarginBottom",
            &"disabled": &"Disabled",
            &"clip_text": &"ClipText",
            &"size_flags": &"SizeFlags",
            &"bound_args": &"BoundArgs",
            &"unbind_next": &"UnbindNext",
            &"callable_method_name": &"CallableMethodName",
        }
        var comb_flag: int = PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_SCRIPT_VARIABLE
        for prop in default_btn.get_property_list():
            if (prop["usage"] & comb_flag) != comb_flag: continue
            var prop_name: StringName = prop["name"]
            var current: Variant = rlink_button.get(map[prop_name])
            var default: Variant = real_defaults.get(prop_name)
            if not current or (default != null and current == default):
                rlink_button.set(map[prop_name], default_btn.get(prop_name))


func _on_busy_changed(_status: bool, _id: int) -> void:
    var disabled: bool
    if _rlink_button != null:
        disabled = _rlink_button.disabled
    elif _rlink_button_cs != null and "Disabled" in _rlink_button_cs:
        disabled = _rlink_button_cs.Disabled

    _button.disabled = _data.busy or property_is_readonly or disabled

    
func _on_rlink_button_changed() -> void:
    _max_width = _rlink_button.max_width
    _size_override = _rlink_button.size_flags

    if _rlink_button.icon_texture != null:
        _button.icon = _rlink_button.icon_texture
    elif _rlink_button.icon:
        _button.icon = __compat.get_editor_theme().get_icon(_rlink_button.icon, &"EditorIcons")
    else:
        _button.icon = null

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
    if not "MaxWidth" in _rlink_button_cs: return # Sometimes not present on reload
    _max_width = _rlink_button_cs.MaxWidth
    _size_override = _rlink_button_cs.SizeFlags

    if _rlink_button_cs.IconTexture != null:
        _button.icon = _rlink_button_cs.IconTexture
    elif _rlink_button_cs.icon:
        _button.icon = __compat.get_editor_theme().get_icon(_rlink_button_cs.Icon, "EditorIcons")
    else:
        _button.icon = null
        
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
        var edit_icon := ed_theme.get_icon(&"Edit", &"EditorIcons")
        var reload_icon := ed_theme.get_icon(&"Reload", &"EditorIcons")
        var clear_icon := ed_theme.get_icon(&"Clear", &"EditorIcons")
        var bucket_icon := ed_theme.get_icon(&"Bucket", &"EditorIcons")
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
    var obj := _data.runtime
    if id == ContextActions.Edit:
        var rlink_runtime: RLinkButton = __rlink_map.runtime_from_obj(_rlink_button)
        
        if rlink_runtime == null:
            var text := "Default"
            if "text" in _rlink_button:
                text = _rlink_button.text
            rlink_runtime = _data.convert_to_runtime(_rlink_button)
            _buffer.object_add_changes(obj, _property, null, rlink_runtime)
            _buffer.push_action("Create '%s'" % text, obj)
            __rlink_map.add_pair(rlink_runtime, _rlink_button)
            __ctx.converter_to_tool._connect_rlink_buttons(_buffer, rlink_runtime)
            
        __compat.interface.edit_resource(rlink_runtime)
        
    elif id == ContextActions.SetCurrentAsDefault:
        _rlink_button.set_current_as_default()
        _data.convert_to_runtime(_rlink_button)
        _buffer.push_action("Set Current as Default '%s'" % _rlink_button.text, obj)
        
    elif id == ContextActions.Reset:
        _rlink_button.restore_default()
        _data.convert_to_runtime(_rlink_button)
        _buffer.push_action("Reset '%s'" % _rlink_button.text, obj)
        
    elif id == ContextActions.Clear:
        var rlink_runtime: Resource = __ctx.rlink_map.runtime_from_obj(_rlink_button)
        if rlink_runtime == null: return

        var text := "Default"
        if "text" in _rlink_button:
            text = _rlink_button.text
        _buffer.object_add_changes(obj, _property, rlink_runtime, null)
        _buffer.add_do_method([__ctx, &"clear_and_refresh"])
        _buffer.add_undo_method([__ctx, &"clear_and_refresh"])
        _buffer.add_undo_method([__ctx, &"establish_tracking", obj, _property])
        _buffer.push_action("Clear '%s'" % text, obj)


func _on_id_pressed_cs(id: int) -> void:
    if _data == null or _data.busy: return
    var obj := _data.runtime
    if id == ContextActions.Edit:
        var rlink_runtime_cs: Resource = __rlink_map.runtime_from_obj(_rlink_button_cs)
        
        if rlink_runtime_cs == null:
            var text := "Default"
            if "Text" in _rlink_button_cs:
                text = _rlink_button_cs.Text
            rlink_runtime_cs = _data.convert_to_runtime(_rlink_button_cs)
            _buffer.object_add_changes(obj, _property, null, rlink_runtime_cs)
            _buffer.push_action("Create '%s'" % text, obj)
            __rlink_map.add_pair(rlink_runtime_cs, _rlink_button_cs)
            __ctx.converter_to_tool._connect_rlink_buttons(_buffer, rlink_runtime_cs)
            
        __compat.interface.edit_resource(rlink_runtime_cs)
        
    elif id == ContextActions.SetCurrentAsDefault:
        _rlink_button_cs.SetCurrentAsDefault()
        _data.convert_to_runtime(_rlink_button_cs)
        _buffer.push_action("Set Current as Default '%s'" % _rlink_button_cs.Text, obj)
        
    elif id == ContextActions.Reset:
        _rlink_button_cs.RestoreDefault()
        _data.convert_to_runtime(_rlink_button_cs)
        _buffer.push_action("Reset '%s'" % _rlink_button_cs.Text, obj)
        
    elif id == ContextActions.Clear:
        var rlink_runtime_cs: Resource = __ctx.rlink_map.runtime_from_obj(_rlink_button_cs)
        if rlink_runtime_cs == null: return

        var text := "Default"
        if "Text" in _rlink_button_cs:
            text = _rlink_button_cs.Text
        _buffer.object_add_changes(obj, _property, rlink_runtime_cs, null)
        _buffer.add_do_method([__ctx, &"clear_and_refresh"])
        _buffer.add_undo_method([__ctx, &"clear_and_refresh"])
        _buffer.add_undo_method([__ctx, &"establish_tracking", obj, _property])
        _buffer.push_action("Clear '%s'" % text, obj)


func _on_hide() -> void:
    __ctx.popup.popup_hide.disconnect(_on_hide)
    _on_hide_deferred.call_deferred()
    
    
func _on_hide_deferred() -> void:
    __ctx.popup.id_pressed.disconnect(_on_id_pressed_callable)
