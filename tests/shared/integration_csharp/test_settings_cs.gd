extends RLinkTestBaseCSharp


var max_depth_params := [
    [3, 10, 2],
    [5, 10, 4],
    [5, 3, 3],
    [1, 3, 0],
]

func test_max_depth(params: Array = use_parameters(max_depth_params)) -> void:
    settings.max_depth = params[0]
    
    var MaxDepth_script: Script = get_cs_script("MaxDepth.cs")
    var Inner_script: Script = get_cs_script("Inner.cs")
    var node: Node = autofree(MaxDepth_script.new())
    var data := rlink_data_cache.get_data(node)
    
    var temp: Object = node
    for i in params[1]:
        temp.Inner = Inner_script.new()
        temp = temp.Inner
    
    data.validate_changes("valid")
    assert_eq(node.IntVar, params[2])


func test_validate_changes_names() -> void:
    var CustomName_script: Script = get_cs_script("CustomName.cs")
    var node: Node = autofree(CustomName_script.new())
    
    var data := rlink_data_cache.get_data(node)
    data.validate_changes("valid")
    assert_eq(node.IntVar, 100)
    clear()
    
    settings.validate_changes_names = [&"ValidateCustomName"]
    data = rlink_data_cache.get_data(node)
    data.validate_changes("valid")
    assert_eq(node.IntVar, 200)
    clear()
    
    settings.validate_changes_names = []
    data = rlink_data_cache.get_data(node)
    assert_null(data)


func test_custom_settings_name() -> void:
    var CustomSettingsName_script: Script = get_cs_script("CustomSettingsName.cs")
    var node: Node = autofree(CustomSettingsName_script.new())
    var scan := scan_cache.get_search(node)
    
    assert_true(scan.skip)
    clear()
    
    settings.get_rlink_settings_names = [&"GetRLinkSettingsCustom"]
    scan = scan_cache.get_search(node)
    assert_false(scan.skip)
    
    var data := rlink_data_cache.get_data(node)
    assert_null(data)
    clear()
    
    settings.get_rlink_settings_names = []
    data = rlink_data_cache.get_data(node)
    assert_not_null(data)
    data.validate_changes("test")
    assert_eq(node.IntVar, 100)


func test_external_resource() -> void:
    var ExternalResource_script: Script = get_cs_script("ExternalResource.cs")
    var node: Node = autofree(ExternalResource_script.new())
    node.Res = load("res://tests/integration_csharp/scripts/test_setting_resource.tres")
    var original: int = node.Res.IntVar
    assert_ne(original, 500)
    
    var data := rlink_data_cache.get_data(node)
    data.validate_changes("")
    assert_eq(node.Res.IntVar, original)
    assert_eq(node.CopyInt, original)
    clear()
    node.CopyInt = 0
    
    settings.apply_changes_to_external_user_resources = true
    data = rlink_data_cache.get_data(node)
    data.validate_changes("")
    assert_eq(node.CopyInt, original)
    assert_eq(node.Res.IntVar, 500)
    
    var res: Resource = load("res://tests/integration_csharp/scripts/test_setting_resource.tres")
    assert_ne(res.IntVar, original)
    assert_eq(res.IntVar, 500)
    res.IntVar = original
