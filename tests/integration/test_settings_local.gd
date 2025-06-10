extends RLinkTestBase


class Inner extends Resource:
    @export var inner_var: int


class InnerSkip extends Resource:
    @export var inner_var: int

    static func get_rlink_settings() -> RLinkSettings:
        var settings := RLinkSettings.new()
        settings.skip = true
        return settings


class SkipProps extends Node:
    @export var int_var: int
    @export var float_var: float
    @export var inner: Inner


    func validate_changes() -> void:
        if inner == null:
            int_var = 200
        else:
            int_var = 150
        float_var = 200.0


    static func get_rlink_settings() -> RLinkSettings:
        var settings := RLinkSettings.new()
        settings.skip_properties = ["float_var", "inner"]
        return settings


func test_skip_properties() -> void:
    var node: SkipProps = autofree(SkipProps.new())
    node.inner = Inner.new()
    var data := rlink_data_cache.get_data(node)
    
    data.validate_changes("valid")
    assert_eq(node.int_var, 200)
    assert_eq(node.float_var, float())


class AllowProps extends Node:
    @export var int_var: int
    @export var float_var: float
    @export var inner: Inner


    func validate_changes() -> void:
        inner.inner_var = 250
        int_var = 100
        float_var = 200.0


    static func get_rlink_settings() -> RLinkSettings:
        var settings := RLinkSettings.new()
        settings.allowed_properties = ["inner", "float_var"]
        return settings
        
        
func test_allow_properties() -> void:
    var node: AllowProps = autofree(AllowProps.new())
    node.inner = Inner.new()
    var data := rlink_data_cache.get_data(node)
    
    data.validate_changes("valid")
    assert_eq(node.inner.inner_var, 250)
    assert_eq(node.int_var, int())
    assert_eq(node.float_var, 200.0)


class CustomName extends Node:
    @export var int_var: int
    
    
    func validate_custom_name() -> void:
        int_var = 200
        
    
    static func get_rlink_settings() -> RLinkSettings:
        var settings := RLinkSettings.new()
        settings.validate_name = &"validate_custom_name"
        return settings
    
    
func test_custom_name() -> void:
    var node: CustomName = autofree(CustomName.new())
    var data := rlink_data_cache.get_data(node)
    
    data.validate_changes("valid")
    assert_eq(node.int_var, 200)
    

class MaxDepth extends Node:
    @export var inner: Inner
    @export var int_var: int


    func validate_changes() -> void:
        if inner == null:
            int_var = 200
        else:
            int_var = 150
        
    
    static func get_rlink_settings() -> RLinkSettings:
        var settings := RLinkSettings.new()
        settings.max_depth = 1
        return settings
    
    
func test_max_depth() -> void:
    var node: MaxDepth = autofree(MaxDepth.new())
    node.inner = Inner.new()
    var data := rlink_data_cache.get_data(node)
    
    data.validate_changes("valid")
    assert_eq(node.int_var, 200)


class Skips extends Node:
    @export var inner: Inner
    @export var inner_meta: Inner
    @export var inner_skip: InnerSkip
    @export var int_var: int
    
    
    func validate_changes() -> void:
        inner.inner_var = 110
        if inner_meta == null:
            int_var += 120
        if inner_skip == null:
            int_var += 100
            
            
func test_skips() -> void:
    var node: Skips = autofree(Skips.new())
    node.inner = Inner.new()
    node.inner_meta = Inner.new()
    node.inner_meta.set_meta(&"rlink_skip", true)
    node.inner_skip = InnerSkip.new()
    
    var data := rlink_data_cache.get_data(node)
    data.validate_changes("valid")
    assert_eq(node.inner.inner_var, 110)
    assert_eq(node.int_var, 220)
    
