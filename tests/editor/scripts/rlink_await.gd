extends Node

@export var int_var: int
@export var set_int := RLinkButton.new(set_int_impl)
@export var success: bool
@export var set_int_checked := RLinkButton.new(set_int_checked_impl)


func set_int_impl(rlink: RLink) -> void:
    int_var -= 1
    print("Before")
    await rlink.get_tree().create_timer(2).timeout
    int_var -= 1
    print("After")
    
    
func set_int_checked_impl(rlink: RLink) -> bool:
    int_var += 1
    print("Before")
    await rlink.get_tree().create_timer(4).timeout
    int_var += 1
    print("After")
    return success
