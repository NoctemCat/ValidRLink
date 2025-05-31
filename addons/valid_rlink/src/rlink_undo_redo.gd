extends RefCounted

var _undo_redo: EditorUndoRedoManager
var _changes: Array
var _add_groups: Dictionary
var _erase_groups: Dictionary
var _add_children: Dictionary
var _remove_children: Dictionary
var _connect_signals: Array
var _disconnect_signals: Array


func _init(undo_redo: EditorUndoRedoManager) -> void:
    _undo_redo = undo_redo
    
    
func add_changes(obj: Object, property: String, old_value: Variant, new_value: Variant) -> void:
    _changes.push_back(obj)
    _changes.push_back(property)
    _changes.push_back(old_value)
    _changes.push_back(new_value)


@warning_ignore_start("untyped_declaration")
@warning_ignore_start("unsafe_method_access")
func node_add_groups(node: Node, groups: Array[StringName]) -> void:
    var arr = _add_groups.get(node) 
    if arr == null:
        arr = Array([], TYPE_STRING_NAME, &"", null)
        _add_groups[node] = arr
    arr.append_array(groups)


func node_remove_groups(node: Node, groups: Array[StringName]) -> void:
    var arr = _erase_groups.get(node) 
    if arr == null:
        arr = Array([], TYPE_STRING_NAME, &"", null)
        _erase_groups[node] = arr
    arr.append_array(groups)
    
    
func node_add_child(node: Node, child: Node) -> void:
    var arr = _add_children.get(node) 
    if arr == null:
        arr = Array([], TYPE_OBJECT, &"Node", null)
        _add_children[node] = arr
    arr.append(child)


func node_remove_child(node: Node, child: Node) -> void:
    var arr = _remove_children.get(node) 
    if arr == null:
        arr = Array([], TYPE_OBJECT, &"Node", null)
        _remove_children[node] = arr
    arr.append(child)
    
@warning_ignore_restore("untyped_declaration")
@warning_ignore_restore("unsafe_method_access")


func add_connect_signal(signal_value: Signal, callable: Callable) -> void:
    _connect_signals.push_back(signal_value)
    _connect_signals.push_back(callable)
    
    
func add_disconnect_signal(signal_value: Signal, callable: Callable) -> void:
    _disconnect_signals.push_back(signal_value)
    _disconnect_signals.push_back(callable)
    
    
@warning_ignore_start("untyped_declaration")
@warning_ignore_start("unsafe_method_access")
func flush_changes() -> void:
    _flush_changes_impl()
    
    var needs_updating = _connect_signals.size() > 0 or _disconnect_signals.size() > 0
    
    _add_children.clear()
    _remove_children.clear()
    _changes.clear()
    _add_groups.clear()
    _erase_groups.clear()
    _connect_signals.clear()
    _disconnect_signals.clear()
    
    if needs_updating: _update_tree() 

## Made a separate method, so that if for some reason any of them failed, 
## clear functions after it still got called
func _flush_changes_impl() -> void:
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        _undo_redo.add_undo_property(_changes[i], _changes[i + 1], _changes[i + 2])
        
    for node in _add_children:
        for child in _add_children[node]:
            if not node.is_inside_tree():
                push_warning("ValidRLink: node '%s' is not inside tree" % node.to_string())
                continue
            _undo_redo.add_do_method(node, &"add_child", child, true)
            _undo_redo.add_do_method(child, &"set_owner", node.get_tree().edited_scene_root)
            _undo_redo.add_do_reference(child)
            _undo_redo.add_undo_method(node, &"remove_child", child)
            
    for node in _remove_children:
        for child in _remove_children[node]:
            if not node.is_inside_tree():
                push_warning("ValidRLink: node '%s' is not inside tree" % node.to_string())
                continue
            _undo_redo.add_do_method(node, &"remove_child", child)
            _undo_redo.add_undo_method(node, &"add_child", child, true)
            _undo_redo.add_undo_method(child, &"set_owner", node.get_tree().edited_scene_root)
            _undo_redo.add_undo_method(node, &"move_child", child.get_index(), true)
            _undo_redo.add_undo_reference(child)
            
    # obj, prop_name, original, new
    for i in range(0, _changes.size(), 4):
        _undo_redo.add_do_property(_changes[i], _changes[i + 1], _changes[i + 3])

    for node in _add_groups:
        for group in _add_groups[node]:
            _undo_redo.add_do_method(node, &"add_to_group", group, true)
            _undo_redo.add_undo_method(node, &"remove_from_group", group)
            
    for node in _erase_groups:
        for group in _erase_groups[node]:
            _undo_redo.add_do_method(node, &"remove_from_group", group)
            _undo_redo.add_undo_method(node, &"add_to_group", group, true) 
    
    for i in range(0, _connect_signals.size(), 2):
        var signal_value: Signal = _connect_signals[i] 
        var callable: Callable = _connect_signals[i + 1] 
        
        _undo_redo.add_do_method(signal_value.get_object(), &"connect", signal_value.get_name(), callable, Object.CONNECT_PERSIST)
        _undo_redo.add_undo_method(signal_value.get_object(), &"disconnect", signal_value.get_name(), callable)
        
    for i in range(0, _disconnect_signals.size(), 2):
        var signal_value: Signal = _disconnect_signals[i]
        var callable: Callable = _disconnect_signals[i + 1]
        
        _undo_redo.add_do_method(signal_value.get_object(), &"disconnect", signal_value.get_name(), callable)
        _undo_redo.add_undo_method(signal_value.get_object(), &"connect", signal_value.get_name(), callable, Object.CONNECT_PERSIST)

@warning_ignore_restore("untyped_declaration")
@warning_ignore_restore("unsafe_method_access")


func commit_action(execute: bool = true) -> void:
    _undo_redo.commit_action(execute)
    #_undo_redo.add_do_method()
    
    
func create_action(
    name: String, 
    merge_mode: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE, 
    custom_context: Object = null, 
    backward_undo_ops: bool = false
) -> void:
    _undo_redo.create_action(name, merge_mode, custom_context, backward_undo_ops)
    

# Pretty ugly workaround
func _update_tree() -> void:
    @warning_ignore("unsafe_property_access")
    var root: Node = Engine.get_main_loop().edited_scene_root
    if root != null:
        var temp := Node.new()
        root.add_child(temp)
        temp.owner = root
        prints("leaked temp ", temp)
        temp.queue_free()
