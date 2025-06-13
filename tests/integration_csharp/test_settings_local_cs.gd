extends RLinkTestBaseCSharp


func test_skip_properties() -> void:
    var SkipProps_script: Script = get_cs_script("SkipProps.cs")
    var Inner_script: Script = get_cs_script("Inner.cs")
    var node: Node = autofree(SkipProps_script.new())
    node.Inner = Inner_script.new()
    var data := rlink_data_cache.get_data(node)
    
    data.validate_changes("valid")
    assert_eq(node.IntVar, 200)
    assert_true(is_zero_approx(node.FloatVar))

        
func test_allow_properties() -> void:
    var AllowProps_script: Script = get_cs_script("AllowProps.cs")
    var Inner_script: Script = get_cs_script("Inner.cs")
    var node: Node = autofree(AllowProps_script.new())
    node.Inner = Inner_script.new()
    var data := rlink_data_cache.get_data(node)
    
    data.validate_changes("valid")
    assert_eq(node.Inner.InnerVar, 250)
    assert_eq(node.IntVar, int())
    assert_true(is_equal_approx(node.FloatVar, 200.0))

    
func test_custom_name() -> void:
    var CustomName_script: Script = get_cs_script("CustomName.cs")
    var node: Node = autofree(CustomName_script.new())
    var data := rlink_data_cache.get_data(node)
    
    var res := scan_cache.get_search(node)
    print("---", res.validate_name)
    data.validate_changes("valid")
    assert_eq(node.IntVar, 200)


func test_max_depth() -> void:
    var MaxDepth_script: Script = get_cs_script("MaxDepth.cs")
    var Inner_script: Script = get_cs_script("Inner.cs")
    var node: Node = autofree(MaxDepth_script.new())
    node.Inner = Inner_script.new()
    var data := rlink_data_cache.get_data(node)
    
    data.validate_changes("valid")
    assert_eq(node.IntVar, 200)

 
func test_skips() -> void:
    var Skips_script: Script = get_cs_script("Skips.cs")
    var Inner_script: Script = get_cs_script("Inner.cs")
    var InnerSkip_script: Script = get_cs_script("InnerSkip.cs")
    var node: Node = autofree(Skips_script.new())
    node.Inner = Inner_script.new()
    node.InnerMeta = Inner_script.new()
    node.InnerMeta.set_meta(&"rlink_skip", true)
    node.InnerSkip = InnerSkip_script.new()
    
    var data := rlink_data_cache.get_data(node)
    data.validate_changes("valid")
    assert_eq(node.Inner.InnerVar, 110)
    assert_eq(node.IntVar, 220)
