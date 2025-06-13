extends RLinkTestBase


class Inner extends Resource:
    @export var inner_var: int
    @export var inner: Resource


class MaxDepth extends Node:
    @export var inner: Inner
    @export var int_var: int

    func validate_changes() -> void:
        var temp: Resource = inner
        while temp != null:
            int_var += 1
            temp = temp.inner


var max_depth_params := [
    [3, 10, 2],
    [5, 10, 4],
    [5, 3, 3],
    [1, 3, 0],
]

func test_max_depth(params: Array = use_parameters(max_depth_params)) -> void:    
    settings.max_depth = params[0]
    
    var node: MaxDepth = autofree(MaxDepth.new())
    var data := rlink_data_cache.get_data(node)
    
    var temp: Object = node
    @warning_ignore("untyped_declaration")
    for i in params[1]:
        temp.inner = Inner.new()
        temp = temp.inner
    
    data.validate_changes("valid")
    assert_eq(node.int_var, params[2])


class CustomName extends Node:
    @export var int_var: int

    func validate_changes() -> void:
        int_var = 100
        
    func validate_custom_name() -> void:
        int_var = 200


func test_validate_changes_names() -> void:
    var node: CustomName = autofree(CustomName.new())
    
    var data := rlink_data_cache.get_data(node)
    data.validate_changes("valid")
    assert_eq(node.int_var, 100)
    clear()
    
    settings.validate_changes_names = [&"validate_custom_name"]
    data = rlink_data_cache.get_data(node)
    data.validate_changes("valid")
    assert_eq(node.int_var, 200)
    clear()
    
    settings.validate_changes_names = []
    data = rlink_data_cache.get_data(node)
    assert_null(data)


class CustomSettingsName extends Node:
    @export var int_var: int

    func validate_changes() -> void:
        int_var = 100
        
    static func get_rlink_settings() -> RLinkSettings:
        return RLinkSettings.new().set_skip(true)

    static func get_rlink_settings_custom() -> RLinkSettings:
        return RLinkSettings.new().set_validate_name("no-name")


func test_custom_settings_name() -> void:
    var node: CustomSettingsName = autofree(CustomSettingsName.new())
    var scan := scan_cache.get_search(node)
    
    assert_true(scan.skip)
    clear()
    
    settings.get_rlink_settings_names = [&"get_rlink_settings_custom"]
    scan = scan_cache.get_search(node)
    assert_false(scan.skip)
    
    var data := rlink_data_cache.get_data(node)
    assert_null(data)
    clear()
    
    settings.get_rlink_settings_names = []
    data = rlink_data_cache.get_data(node)
    assert_not_null(data)
    data.validate_changes("test")
    assert_eq(node.int_var, 100)



class ExternalResource extends Node:
    @export var res: External
    @export var copy_int: int
    
    func validate_changes() -> void:
        copy_int = res.int_var
        res.int_var = 500


func test_external_resource() -> void:
    var node: ExternalResource = autofree(ExternalResource.new())
    node.res = load("res://tests/integration/test_setting_external.tres")
    var original := node.res.int_var
    assert_ne(original, 500)
    
    var data := rlink_data_cache.get_data(node)
    data.validate_changes("")
    assert_eq(node.res.int_var, original)
    assert_eq(node.copy_int, original)
    clear()
    node.copy_int = 0
    
    settings.apply_changes_to_external_user_resources = true
    data = rlink_data_cache.get_data(node)
    data.validate_changes("")
    assert_eq(node.copy_int, original)
    assert_eq(node.res.int_var, 500)
    
    var res: External = load("res://tests/integration/test_setting_external.tres")
    assert_ne(res.int_var, original)
    assert_eq(res.int_var, 500)
    res.int_var = original
    
    
    
