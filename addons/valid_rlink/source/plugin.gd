@tool
extends EditorPlugin

const Context = preload("./context.gd")
const Settings = Context.Settings
const Compatibility = Context.Compatibility
const RLinkInspector = preload("./inspector/rlink_inspector.gd")

var _ctx: Context
var _settings: Settings
var _compat: Compatibility
var _inspector: RLinkInspector

var _popup: PopupMenu
var _refresh_timer: Timer
var _refresh_callable: Callable
var _csharp_unload_detector: Node
var _clear_entered: bool


func _get_plugin_name() -> String:
    return "ValidRLink"
    
    
func _get_plugin_icon() -> Texture2D:
    return preload("./../icon.svg")

    
func _enter_tree() -> void:
    _ctx = Context.new()
    _ctx.settings = Settings.new()
    _settings = _ctx.settings
    _ctx.compat = Compatibility.new()
    _compat = _ctx.compat
    
    _settings.update_plugin_settings()
    _compat.set_interface(self)
    _ctx.undo_redo = get_undo_redo()
    
    _handle_csharp_support()
    _connect_signals()
    
    _copy_button_theme()
    _ctx.rlink_inspector = RLinkInspector.new(_ctx)
    _inspector = _ctx.rlink_inspector
    add_inspector_plugin(_inspector)
    
    _popup = PopupMenu.new()
    _popup.theme = _compat.get_editor_theme()
    add_child(_popup)
    _ctx.popup = _popup
    _create_refresh_timer()
    add_tool_menu_item("ValidRLink: Clear Cache", _clear)


func _exit_tree() -> void:
    _refresh_callable = Callable()
    clear_with_cancel()
    remove_tool_menu_item("ValidRLink: Clear Cache")
    if _csharp_unload_detector != null:
        _csharp_unload_detector.call(&"FreeHandle")
        _csharp_unload_detector.queue_free()
        _ctx.csharp_db.queue_free()
        _ctx.csharp_ref_tracer.queue_free()
    _popup.queue_free()
    _refresh_timer.queue_free()
    remove_inspector_plugin(_inspector)
    _inspector = null
    _disconnect_signals()
    _ctx.free()


func _clear() -> void:
    if _clear_entered: return
    _clear_entered = true
    if _ctx.rlink_data_cache.waits_for_result:
        await _ctx.rlink_data_cache.stopped_waiting
    _inspector.clear()
    if _refresh_callable.is_valid():
        _refresh_callable.call()
    _clear_entered = false


func clear_with_cancel() -> void:
    _ctx.emit_cancel_tasks()
    _clear()


func _handle_csharp_support() -> void:
    if not ClassDB.class_exists(&"CSharpScript"): return
    
    _ctx.csharp_enabled = true
    _ctx.csharp_helper_script = load(Context.RUNTIME_PATH + "RLinkCS.cs")
    _ctx.csharp_button_script = load(Context.RUNTIME_PATH + "RLinkButtonCS.cs")
    _ctx.csharp_settings_script = load(Context.RUNTIME_PATH + "RLinkSettingsCS.cs")
    
    _csharp_unload_detector = load(Context.SOURCE_PATH + "RLinkUnloadDetector.cs").new()
    add_child(_csharp_unload_detector, true)
    _ctx.csharp_db = load(Context.SOURCE_PATH + "RLinkDB.cs").new()
    add_child(_ctx.csharp_db, true)
    _ctx.csharp_ref_tracer = load(Context.SOURCE_PATH + "RLinkRefTracerSerialize.cs").new()
    add_child(_ctx.csharp_ref_tracer, true)


func _connect_signals() -> void:
    if ProjectSettings.has_signal(&"settings_changed"):
        ProjectSettings.connect(&"settings_changed", _on_settings_changed)
    else:
        connect(&"project_settings_changed", _on_settings_changed)
    if GDExtensionManager.has_signal(&"extensions_reloaded"):
        GDExtensionManager.connect(&"extensions_reloaded", _clear)
    resource_saved.connect(_on_resource_saved)


func _create_refresh_timer() -> void:
    _refresh_timer = Timer.new()
    _refresh_timer.wait_time = 0.4
    _refresh_timer.one_shot = true
    _refresh_timer.timeout.connect(_refresh_inspector)
    _refresh_callable = _refresh_timer.start
    add_child(_refresh_timer)


func _disconnect_signals() -> void:
    if ProjectSettings.has_signal(&"settings_changed"):
        ProjectSettings.disconnect(&"settings_changed", _on_settings_changed)
    else:
        disconnect(&"project_settings_changed", _on_settings_changed)
    if GDExtensionManager.has_signal(&"extensions_reloaded"):
        GDExtensionManager.disconnect(&"extensions_reloaded", _clear)
    resource_saved.disconnect(_on_resource_saved)


func _on_resource_saved(resource: Resource) -> void:
    if resource is Script:
        _clear()


func _on_settings_changed() -> void:
    _settings.update_plugin_settings()
    _clear()
    if _csharp_unload_detector != null:
        _csharp_unload_detector.CollectGC = _settings.csharp_collect_gc
        _csharp_unload_detector.ExecutePendingContinuations = _settings.csharp_execute_pending_continuations
        _csharp_unload_detector.SwallowBaseException = _settings.csharp_swallow_base_exception


func _refresh_inspector() -> void:
    var selection: EditorSelection = _ctx.compat.interface.get_selection()
    var nodes := selection.get_selected_nodes()
    if nodes.size() == 1:
        nodes[0].notify_property_list_changed()


func _copy_button_theme() -> void:
    var theme := Theme.new()
    _ctx.button_theme = theme
    
    var base: Control = _compat.get_editor_base_control()
    var editor_theme: Theme = _compat.get_editor_theme()

    var styles_to_copy := editor_theme.get_theme_item_list(Theme.DATA_TYPE_STYLEBOX, "InspectorActionButton")
    for item_name in styles_to_copy:
        var style: StyleBox = base.get_theme_stylebox(item_name, &"InspectorActionButton").duplicate()
        style.content_margin_left = 0
        style.content_margin_right = 0
        theme.set_stylebox(item_name, &"Button", style)
    theme.set_constant(&"h_separation", &"Button", 0)

    var left_margin := -1.0
    for style_name in styles_to_copy:
        var style: StyleBox = base.get_theme_stylebox(style_name, &"InspectorActionButton").duplicate()
        if not is_equal_approx(style.content_margin_left, style.content_margin_right):
            style.content_margin_right = style.content_margin_left
            if left_margin < 0: left_margin = style.content_margin_left
        theme.set_stylebox(style_name, &"IconButton", style)
    theme.set_constant(&"h_separation", &"IconButton", roundi(left_margin))

    theme.set_type_variation(&"IconButton", &"Button")
