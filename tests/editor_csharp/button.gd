@tool 
extends Button
@export
var setr: bool:
    set(value):
        prints(get_tree(), Engine.get_main_loop())
        prints(get_tree().root, get_tree().edited_scene_root)
        print(get_callable().call(10))
        
    
func get_callable() -> Callable:
    
    return get_int.bindv([])


func get_int(int_var: int) -> int:
    return int_var + 3
