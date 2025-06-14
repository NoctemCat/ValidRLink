extends Node

@export var toggle_direct_child := toggle_direct_child_impl
@export var toggle_direct_child_path := toggle_direct_child_path_impl
@export var toggle_child_path := toggle_child_path_impl
@export var toggle_child_from := toggle_child_from_impl
@export var toggle_child_get_parent := toggle_child_get_parent_impl
@export var toggle_has_from := toggle_has_from_impl
@export var remove_all_children := remove_all_children_impl
@export var remove_all_children_from := remove_all_children_from_impl
@export var remove_all_children_path := remove_all_children_path_impl


func toggle_direct_child_impl(rlink: RLink) -> void:
    var child := rlink.get_node_or_null("DirectChild")
    if child != null:
        rlink.remove_child(child)
    else:
        child = Node.new()
        child.name = "DirectChild"
        rlink.add_child(child)
        
        
func toggle_child_path_impl(rlink: RLink) -> void:
    if rlink.has_node("DirectChild/ChildPath"):
        rlink.remove_child_path("DirectChild/ChildPath")
    else:
        rlink.add_child_path("DirectChild/ChildPath", Node.new())


func toggle_direct_child_path_impl(rlink: RLink) -> void:
    if rlink.has_node("DirectChildPath"):
        rlink.remove_child_path("DirectChildPath")
    else:
        rlink.add_child_path("DirectChildPath", Node.new())


func toggle_child_from_impl(rlink: RLink) -> void:
    var direct_child := rlink.get_node_or_null("DirectChild")
    if direct_child == null: return
    
    var grand_child := rlink.get_node_or_null_from(direct_child, "ChildFrom")
    if grand_child != null:
        rlink.remove_child_from(direct_child, grand_child)
    else:
        grand_child = Node.new()
        grand_child.name = "ChildFrom"
        rlink.add_child_to(direct_child, grand_child)


func toggle_child_get_parent_impl(rlink: RLink) -> void:
    var grand_child := rlink.get_node_or_null("DirectChild/GetParent")
    if grand_child != null:
        rlink.remove_child_from(rlink.get_parent_for(grand_child), grand_child)
    else:
        rlink.add_child_path("DirectChild/GetParent", Node.new())


## Purely to test RLink methods
func toggle_has_from_impl(rlink: RLink) -> void:
    if not rlink.has_node("DirectChild"): return
    var direct_child := rlink.get_node_or_null("DirectChild")
    
    if rlink.has_node_from(direct_child, "HasFrom"):
        var grand_child := rlink.get_node_or_null_from(direct_child, "HasFrom")
        rlink.remove_child_from(direct_child, grand_child)
    else:
        rlink.add_child_path("DirectChild/HasFrom", Node.new())


func remove_all_children_impl(rlink: RLink) -> void:
    rlink.remove_all_children()


func remove_all_children_from_impl(rlink: RLink) -> void:
    var child := rlink.get_node_or_null("DirectChild")
    if child == null: return
    rlink.remove_all_children_from(child)


func remove_all_children_path_impl(rlink: RLink) -> void:
    rlink.remove_all_children_path("DirectChild")
