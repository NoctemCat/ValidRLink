extends Node

@export var noise_texture: NoiseTexture2D
@export var set_noise := set_noise_impl
@export var set_noise_property := set_noise_property_impl

func validate_changes() -> bool:
    if noise_texture == null:
        noise_texture = NoiseTexture2D.new()
    return true


func set_noise_impl(rlink: RLink) -> bool:
    if noise_texture == null: return true
    
    if noise_texture.noise == null:
        var noise := FastNoiseLite.new()
        rlink.add_changes(noise_texture, &"noise", null, noise)
    else:
        rlink.add_changes(noise_texture, &"noise", noise_texture.noise, null)
    return true
    
    
func set_noise_property_impl(rlink: RLink) -> bool:
    if noise_texture == null: return true
    if noise_texture.noise == null: return true
    print(noise_texture.noise.seed)
    
    if noise_texture.noise.seed == 0:
        rlink.add_do_method(noise_texture.noise, &"set_seed", [1234])
        rlink.add_undo_method(noise_texture.noise, &"set_seed", [0])
    else:
        rlink.add_do_method(noise_texture.noise, &"set_seed", [0])
        rlink.add_undo_method(noise_texture.noise, &"set_seed", [1234])
    return true
