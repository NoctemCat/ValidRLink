@tool
extends RefCounted

var engine_version: int
var interface: Object
var _expr_get_arg_count: Expression


@warning_ignore_start("unsafe_method_access")
func set_interface(plugin: EditorPlugin) -> void:
    engine_version = Engine.get_version_info()["hex"]
    if Engine.has_singleton(&"EditorInterface"):
        interface = Engine.get_singleton(&"EditorInterface")
    else:
        interface = plugin.call(&"get_editor_interface")
        
    if callable_arg_count_available():
        _expr_get_arg_count = Expression.new()
        _expr_get_arg_count.parse("callable.get_argument_count()", ["callable"])


func comp_has_method(obj: Object, method: StringName) -> bool:
    if engine_version >= 0x040300:
        return obj.has_method(method)
    else:
        var script: Script = obj.get_script()
        if script != null and not script.is_tool():
            for m in script.get_script_method_list():
                if m["name"] == method: return true
        return obj.has_method(method)


func get_editor_scale() -> float:
    if interface == null: return 1.0
    return interface.get_editor_scale()
    
    
func save_scene() -> void:
    if interface == null: return
    interface.save_scene()


func callable_arg_count_available() -> bool:
    return engine_version > 0x040300
    
    
func get_arg_count(callable: Callable) -> int:
    if callable_arg_count_available():
        return _expr_get_arg_count.execute([callable])
    else:
        return -1


func get_editor_theme() -> Theme:
    if engine_version > 0x040200:
        return interface.call(&"get_editor_theme")
    else:
        var base: Control = interface.get_base_control()
        return base.theme

func get_editor_base_control() -> Control:
    if interface == null: return null
    return interface.get_base_control()
    
@warning_ignore_restore("unsafe_method_access")
