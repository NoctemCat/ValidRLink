extends RLinkTestBaseCSharp


func test_validate_basic() -> void:
    var script_basic: Script = get_cs_script("BasicExports.cs")
    var test_res: Resource = script_basic.new()
    var data := rlink_data_cache.get_data(test_res)
    _check_default(test_res)
        
    data.validate_changes("")
    _check_export_set(test_res)
        
    test_res.ExportInt = 1000
    assert_eq(test_res.ExportInt, 1000)
    data.validate_changes("")
    assert_eq(test_res.ExportInt, 100)


func test_validate_basic_inner() -> void:
    var script_basic: Script = get_cs_script("BasicExports.cs")
    var script_node: Script = get_cs_script("OuterNode.cs")
    var outer: Node = autofree(script_node.new())
    outer.Res = script_basic.new()
    var data := rlink_data_cache.get_data(outer)
    _check_default(outer.Res)
    assert_eq(outer.SomeVar, String())
    
    data.validate_changes("")
    _check_export_set(outer.Res)
    assert_eq(outer.SomeVar, "after validate")
    
    outer.Res.NormalVector2I = Vector2i(123, 321)
    outer.Res.ExportVector2I = Vector2i(321, 123)
    outer.SomeVar = "set to value"
    
    data.validate_changes("")
    assert_eq(outer.Res.NormalVector2I, Vector2i(123, 321))
    assert_eq(outer.Res.ExportVector2I, Vector2i(100, 100))
    assert_eq(outer.SomeVar, "after validate")
    

func _check_default(basic_export: Resource) -> void:
    var script_basic: Script = get_cs_script("BasicExports.cs")

    @warning_ignore("untyped_declaration")
    for value in script_basic.GetValues():
        var type := typeof(value)
        var normal_name: String = "Normal%s" % script_basic.GetTypeString(type)
        var export_name: String = "Export%s" % script_basic.GetTypeString(type)

        assert_eq(basic_export.get(normal_name), script_basic.GetDefault(type))
        assert_eq(basic_export.get(export_name), script_basic.GetDefault(type))


func _check_export_set(basic_export: Resource) -> void:
    var script_basic: Script = get_cs_script("BasicExports.cs")

    @warning_ignore("untyped_declaration")
    for value in script_basic.GetValues():
        var type := typeof(value)
        var normal_name: String = "Normal%s" % script_basic.GetTypeString(type)
        var export_name: String = "Export%s" % script_basic.GetTypeString(type)
        
        assert_eq(basic_export.get(normal_name), script_basic.GetDefault(type))
        assert_ne(basic_export.get(export_name), script_basic.GetDefault(type))
        assert_eq(basic_export.get(export_name), value)
