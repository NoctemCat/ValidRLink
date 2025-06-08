@tool
extends EditorProperty

const Context = preload("./../context.gd")
const Settings = Context.Settings
const MetaWrapper = preload("./meta_wrapper.gd")
const RLinkData = preload(Context.RLINK_PATH + "rlink_data.gd")

#var _compat: Compatibility 
#var __ctx: Context
var __settings: Settings

# self type
var _parent_property_id: int = 0
var _parent_property: EditorProperty:
    get: return instance_from_id(_parent_property_id)
var _data_id: int
var _data: RLinkData:
    get: return instance_from_id(_data_id)
var object_name: String
var _timer: Timer
var _validate_callable: Callable


func _init(ctx: Context, data: RLinkData, obj_name: String) -> void:
    __settings = ctx.settings
    if data != null:
        _data_id = data.get_instance_id()
    object_name = obj_name


func _enter_tree() -> void:
    visible = false
    if _data != null:
        get_parent().set_meta("_rlink_watcher", MetaWrapper.new(self))
        
    _search_parent_property.call_deferred()
    
    
func _exit_tree() -> void:
    if _data != null:
        get_parent().set_meta("_rlink_watcher", null)
    _data = null


func _ready() -> void:
    _timer = Timer.new()
    _timer.one_shot = true
    _timer.wait_time = __settings.validate_wait_time
    _timer.timeout.connect(call_validate_changes)
    _validate_callable = _timer.start
    add_child(_timer)


func _update_property() -> void:
    _validate_callable.call()
    _propagate_validate()


func _input(event: InputEvent) -> void:
    var mouse_event := event  as InputEventMouseButton
    if mouse_event != null and mouse_event.button_index == MOUSE_BUTTON_LEFT: 
        _timer.paused = mouse_event.pressed


func _search_parent_property() -> void:
    var node := get_parent()
    while node != null and node.get_class() != "InspectorDock":
        node = node.get_parent()
        
        if node.has_meta("_rlink_watcher"):
            var wrapper: MetaWrapper = node.get_meta("_rlink_watcher")
            if is_instance_id_valid(wrapper.value_id):
                _parent_property_id = wrapper.value_id
                object_name = _parent_property.object_name
            else:
                node.set_meta("_rlink_watcher", null)
            break


func call_validate_changes() -> void:
    if _data != null: 
        _data.validate_changes(object_name)


func _propagate_validate() -> void:
    if _parent_property != null:
        @warning_ignore("unsafe_method_access")
        _parent_property._update_property()
        
    #elif Settings.save_after_validate: 
        #Settings.compat.save_scene()
