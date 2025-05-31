@tool
extends EditorInspectorPlugin

const Context = preload("./../context.gd")
#const Settings = preload("./../settings.gd")
#const Compatibility = preload("./../compatibility.gd")
const ScanResult = preload("./scan_result.gd")
const ScanCache = preload("./scan_cache.gd")

const RLinkMap = preload("./rlink_map.gd")
const RLinkData = preload("./rlink_data.gd")
const RLinkDataCache = preload("./rlink_data_cache.gd")
const ConverterToTool = preload("./converter_to_tool.gd")
const ConverterToRuntime = preload("./converter_to_runtime.gd")

const RLinkActionButton = preload("./rlink_action_button.gd")
const PropertyWatcher = preload("./property_watcher.gd")

var __ctx: Context
var _rlink_map: RLinkMap
var _scan_cache: ScanCache
var _rlink_data_cache: RLinkDataCache

var _edited_root: Node
var _watchers: Dictionary
var _prev_objects: Array[int]
var _prop_names: Dictionary


func _init(context: Context) -> void:
    __ctx = context
    __ctx.rlink_map = RLinkMap.new()
    __ctx.scan_cache = ScanCache.new(__ctx)
    __ctx.rlink_data_cache = RLinkDataCache.new(__ctx)
    __ctx.converter_to_tool = ConverterToTool.new(__ctx)
    __ctx.converter_to_runtime = ConverterToRuntime.new(__ctx)
    
    _rlink_map = __ctx.rlink_map
    _scan_cache = __ctx.scan_cache
    _rlink_data_cache = __ctx.rlink_data_cache


func _can_handle(object: Object) -> bool:
    var needs_clear := _prev_objects.size() >= 4
    
    if object is Node and _edited_root != object.get_tree().edited_scene_root:
        _edited_root = object.get_tree().edited_scene_root
        needs_clear = true
        
    if needs_clear:
        clear()
        _watchers.clear()
    var res := _scan_cache.get_search(object)
    if res.skip or object.get_meta(&"rlink_skip", false): return false
    
    if "MultiNode" in object.get_class(): return false
    return true


func _parse_begin(object: Object) -> void:
    var res := _scan_cache.get_search(object)
    if not res.has_validate and not _rlink_map.is_runtime(object):
        return
        
    var object_name: String = _prop_names.get(object.get_instance_id(), "")
    if object_name.is_empty():
        if object is Node:
            object_name = object.name
        elif object is Resource and object.resource_name:
            object_name = object.resource_name
        else:
            var script: Script = object.get_script() as Script
            if script != null:
                object_name = script.resource_path.get_file()
            else:
                object_name = object.to_string()
        _prop_names[object.get_instance_id()] = object_name

    var data := _rlink_data_cache.get_data(object)
    var prop_watcher := PropertyWatcher.new(__ctx, data, object_name)
    prop_watcher.name = "PropertyWatcher"
    prop_watcher.read_only = true
    var object_id := object.get_instance_id()
    _watchers[object_id] = prop_watcher
    prop_watcher.tree_exiting.connect(erase_watcher.bind(object_id))
        
func erase_watcher(object_id: int) -> void: _watchers.erase(object_id)


func _parse_category(object: Object, _category: String) -> void:
    if not object.get_instance_id() in _prev_objects:
        _prev_objects.push_back(object.get_instance_id())


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, _usage_flags: int, _wide: bool) -> bool:
    const TOOL_BUTTON = 39 # PROPERTY_HINT_TOOL_BUTTON
    if hint_type == TOOL_BUTTON: return false

    if hint_type == TYPE_OBJECT:
        var prop_value: Object = object.get(name) 
        if prop_value != null:
            _prop_names[prop_value.get_instance_id()] = name
    
    if hint_string == RLinkButton.CLASS_NAME:
        var data := _rlink_data_cache.get_data(object, true)
        if data._editor_holder == null: return false
        var rlink_button: RLinkButton = data._editor_holder.get(name)
        if rlink_button == null:
            push_error("ValidRLink._parse_property: expected button at '%s'" % name)
            return false
            
        var btn := RLinkActionButton.new(__ctx, object.get_instance_id(), name, rlink_button)
        btn.pressed.connect(data.call_rlink_button.bind(name))

        _add_button(object, btn)
        return true
    if type == TYPE_CALLABLE: 
        var data := _rlink_data_cache.get_data(object, true)
        if data._editor_holder == null: return false
        var btn := RLinkActionButton.new(__ctx, object.get_instance_id(), name)
        btn.pressed.connect(data.call_callable.bind(name))
        
        #add_property_editor("name", btn)
        _add_button(object, btn)
        return true
    return false


func _add_button(object: Object, button: RLinkActionButton) -> void:
    add_custom_control(button)
    
    var watcher: PropertyWatcher = _watchers.get(object.get_instance_id())
    if watcher == null: return 
    button.pressed.connect(watcher._update_property)


func _parse_end(object: Object) -> void:
    var watcher: PropertyWatcher = _watchers.get(object.get_instance_id())
    if watcher == null: return
    
    var props_arr: PackedStringArray = []
    for prop in object.get_property_list():
        if (
            prop["usage"] & PROPERTY_USAGE_DEFAULT == 0 
            or prop["name"] in ["_import_path", "resource_path"]
        ): 
            continue
        props_arr.append(prop["name"])
    print("leaked ", __ctx.get_instance_id())
    add_property_editor_for_multiple_properties("", props_arr, watcher)


func clear() -> void:
    _rlink_map.clear()
    _prev_objects.clear()
    _scan_cache.clear()
    _rlink_data_cache.clear()
    _prop_names.clear()


func establish_tracking(runtime: Object, name: String) -> void:
    var btn: Resource = runtime.get(name)
    if btn == null: return
    var tool: Object = __ctx.rlink_map.tool_from_obj(runtime)
    if tool == null: return
    var tool_btn: Object = tool.get(name)
    if tool_btn == null: return
    
    __ctx.rlink_map.add_pair_no_tracking(btn, tool_btn)
    btn.changed.emit()
