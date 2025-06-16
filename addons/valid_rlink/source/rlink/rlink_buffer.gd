@tool
extends RefCounted

const Context = preload("./../context.gd")
const Settings = Context.Settings
const Compat = Context.Compatibility
const ScanResult = preload("./scan_result.gd")
const ScanCache = preload("./scan_cache.gd")

var __ctx: Context
var __settings: Settings
var __compat: Compat
var __undo_redo: EditorUndoRedoManager

#region: Converter State
var result: ScanResult
var max_depth: int:
    get: return result.max_depth
var object_name: String:
    get: return result.object_name
var visit: Dictionary
var script_error := false
var converter_converted_object := false
var has_changes := false
var track_tool_instances := true
#endregion

#region: Buffer State
var _changes: Array
var _remove_metas: Array
var _add_groups: Dictionary
var _erase_groups: Dictionary
var _add_children: Dictionary
var _remove_children: Dictionary
var _connect_signals: Array
var _disconnect_signals: Array
var _do_methods: Array
var _undo_methods: Array
#endregion


func _init(context: Context) -> void:
    __ctx = context
    __settings = __ctx.settings
    __compat = __ctx.compat
    __undo_redo = __ctx.undo_redo


#region: Changes buffer
func object_add_changes(object: Object, property: StringName, old_value: Variant, new_value: Variant) -> void:
    _changes.push_back(object)
    _changes.push_back(property)
    _changes.push_back(old_value)
    _changes.push_back(new_value)
    has_changes = true


func object_remove_meta(object: Object, property: StringName) -> void:
    _remove_metas.push_back(object)
    _remove_metas.push_back(property)
    has_changes = true


func add_do_method(args_runtime: Array) -> void:
    _do_methods.push_back(args_runtime)
    has_changes = true
    
    
func add_undo_method(args_runtime: Array) -> void:
    _undo_methods.push_back(args_runtime)
    has_changes = true


func node_add_groups(node: Node, groups: Array[StringName]) -> void:
    var arr: Variant = _add_groups.get(node)
    if arr == null:
        arr = Array([], TYPE_STRING_NAME, &"", null)
        _add_groups[node] = arr
    arr.append_array(groups)
    has_changes = true


func node_remove_groups(node: Node, groups: Array[StringName]) -> void:
    var arr: Variant = _erase_groups.get(node)
    if arr == null:
        arr = Array([], TYPE_STRING_NAME, &"", null)
        _erase_groups[node] = arr
    arr.append_array(groups)
    has_changes = true
    
    
func node_add_child(node: Node, child: Node) -> void:
    var arr: Variant = _add_children.get(node)
    if arr == null:
        arr = Array([], TYPE_OBJECT, &"Node", null)
        _add_children[node] = arr
    arr.append(child)
    has_changes = true


func node_remove_child(node: Node, child: Node) -> void:
    var arr: Variant = _remove_children.get(node)
    if arr == null:
        arr = Array([], TYPE_OBJECT, &"Node", null)
        _remove_children[node] = arr
    arr.append(child)
    has_changes = true


func signal_add_connect(signal_value: Signal, callable: Callable) -> void:
    _connect_signals.push_back(signal_value)
    _connect_signals.push_back(callable)
    has_changes = true


func signal_add_disconnect(signal_value: Signal, callable: Callable) -> void:
    _disconnect_signals.push_back(signal_value)
    _disconnect_signals.push_back(callable)
    has_changes = true


func flush_changes(use_history: bool = true) -> void:
    if __undo_redo == null: use_history = false
    
    if use_history: _flush_changes_history()
    else: _flush_changes_direct()
    
    var needs_updating := _connect_signals.size() > 0 or _disconnect_signals.size() > 0
    _clear_buffer()
    if needs_updating: _update_tree()


## Made a separate method, so that if for some reason any of them failed, 
## clear functions after it still got called
func _flush_changes_history() -> void:
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        __undo_redo.add_undo_property(_changes[i], _changes[i + 1], _changes[i + 2])
        
    for i in range(0, _remove_metas.size(), 2):
        var object: Object = _remove_metas[i]
        var meta: StringName = _remove_metas[i + 1]
        __undo_redo.add_undo_method(object, &"set_meta", meta, object.get_meta(meta))
    
    for node in _add_children:
        for child in _add_children[node]:
            __undo_redo.add_do_method(node, &"add_child", child, true)
            if node.is_inside_tree():
                __undo_redo.add_do_method(child, &"set_owner", node.owner if node.owner != null else node)
            __undo_redo.add_do_reference(child)
            __undo_redo.add_undo_method(node, &"remove_child", child)

    for node in _remove_children:
        for child in _remove_children[node]:
            __undo_redo.add_do_method(node, &"remove_child", child)
            __undo_redo.add_undo_method(node, &"add_child", child, true)
            if node.is_inside_tree():
                var owner: Node = node.owner if node.owner != null else node
                @warning_ignore("unassigned_variable")
                var owned: Array[Node]
                _get_owned_by(owner, child, owned)
                __undo_redo.add_undo_method(__ctx, &"set_owners", owner, owned)
            __undo_redo.add_undo_method(node, &"move_child", child, child.get_index())
            __undo_redo.add_undo_reference(child)
            
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        __undo_redo.add_do_property(_changes[i], _changes[i + 1], _changes[i + 3])
        
    for i in range(0, _remove_metas.size(), 2):
        var object: Object = _remove_metas[i]
        var meta: StringName = _remove_metas[i + 1]
        __undo_redo.add_do_method(object, &"remove_meta", meta)
        
    for i in range(0, _do_methods.size(), 1):
        __undo_redo.callv(&"add_do_method", _do_methods[i])
        
    for i in range(0, _undo_methods.size(), 1):
        __undo_redo.callv(&"add_undo_method", _undo_methods[i])
    
    for node in _add_groups:
        for group in _add_groups[node]:
            __undo_redo.add_do_method(node, &"add_to_group", group, true)
            __undo_redo.add_undo_method(node, &"remove_from_group", group)

    for node in _erase_groups:
        for group in _erase_groups[node]:
            __undo_redo.add_do_method(node, &"remove_from_group", group)
            __undo_redo.add_undo_method(node, &"add_to_group", group, true)
    
    for i in range(0, _connect_signals.size(), 2):
        var signal_value: Signal = _connect_signals[i]
        var callable: Callable = _connect_signals[i + 1]

        __undo_redo.add_do_method(signal_value.get_object(), &"connect", signal_value.get_name(), callable, Object.CONNECT_PERSIST)
        __undo_redo.add_undo_method(signal_value.get_object(), &"disconnect", signal_value.get_name(), callable)
        
    for i in range(0, _disconnect_signals.size(), 2):
        var signal_value: Signal = _disconnect_signals[i]
        var callable: Callable = _disconnect_signals[i + 1]
        
        __undo_redo.add_do_method(signal_value.get_object(), &"disconnect", signal_value.get_name(), callable)
        __undo_redo.add_undo_method(signal_value.get_object(), &"connect", signal_value.get_name(), callable, Object.CONNECT_PERSIST)


func _flush_changes_direct() -> void:
    for node in _add_children:
        for child in _add_children[node]:
            node.add_child(child, true)
            if node.is_inside_tree():
                child.owner = node.owner if node.owner != null else node

    for node in _remove_children:
        for child in _remove_children[node]:
            node.remove_child(child)
            
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        _changes[i].set(_changes[i + 1], _changes[i + 3])
        
    for i in range(0, _remove_metas.size(), 2):
        var object: Object = _remove_metas[i]
        object.remove_meta(_remove_metas[i + 1])
        
    for i in range(0, _do_methods.size(), 1):
        var args: Array = _do_methods[i]
        var object: Object = args.pop_front()
        var method: StringName = args.pop_front()
        object.callv(method, args)

    for node in _add_groups:
        for group in _add_groups[node]:
            node.add_to_group(group, true)
    
    for node in _erase_groups:
        for group in _erase_groups[node]:
            node.remove_from_group(group)
    
    for i in range(0, _connect_signals.size(), 2):
        var signal_value: Signal = _connect_signals[i]
        var callable: Callable = _connect_signals[i + 1]
        signal_value.connect(callable, Object.CONNECT_PERSIST)
        
    for i in range(0, _disconnect_signals.size(), 2):
        var signal_value: Signal = _disconnect_signals[i]
        var callable: Callable = _disconnect_signals[i + 1]
        signal_value.disconnect(callable)


func discard_changes() -> void:
    for node in _add_children:
        for child in _add_children[node]:
            child.queue_free()
    _clear_buffer()
   

func _clear_buffer() -> void:
    _add_children.clear()
    _remove_children.clear()
    _changes.clear()
    _remove_metas.clear()
    _do_methods.clear()
    _undo_methods.clear()
    _add_groups.clear()
    _erase_groups.clear()
    _connect_signals.clear()
    _disconnect_signals.clear()
    has_changes = false


func commit_action(execute: bool = true) -> void:
    if __undo_redo != null:
        __undo_redo.commit_action(execute)
    
    
func create_action(
    name: String,
    merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE,
    custom_context: Object = null,
    backward_undo_ops: bool = false
) -> void:
    if __undo_redo != null:
        __undo_redo.create_action(name, merge_mode, custom_context, backward_undo_ops)


func push_action(name: String, object: Object, merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE) -> void:
    create_action(name, merge_mode, object)
    if has_changes:
        flush_changes()
    else:
        # unlikely to store changes, but if for some reason 
        # any are present discard them
        discard_changes()
    commit_action()


func push_validate_action(name: String, object: Object) -> void:
    if has_changes and __settings.validate_use_history:
        create_action(name, UndoRedo.MERGE_ALL, object)
        flush_changes()
        commit_action()
    elif has_changes:
        flush_changes(false)
    else:
        discard_changes()


# Pretty ugly workaround
func _update_tree() -> void:
    if not __settings.update_tree_on_signal_change:
        return
    
    if __compat.engine_version >= 0x040400:
        return
    
    var root: Node = Engine.get_main_loop().edited_scene_root
    if root != null:
        var temp := Node.new()
        root.add_child(temp)
        temp.owner = root
        temp.queue_free()
        
        
func _get_owned_by(owner: Node, node: Node, owned: Array[Node]) -> void:
    if owner == node.owner:
        owned.push_back(node)
    
    for idx in node.get_child_count():
        _get_owned_by(owner, node.get_child(idx), owned)
        

static func find_child_by_class(node: Node, cls: String):
    for child in node.get_children():
        if child.get_class() == cls:
            return child
#endregion
