extends RLinkTestBaseCSharp


func test_get_add_group() -> void:
    var script: Script = get_cs_script("GetSetGroup.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node)
    
    node.add_to_group("test")
    node.add_to_group("test_other")
    data.validate_changes("testing meta")
    
    assert_true(node.is_in_group("test"))
    assert_true(node.is_in_group("test_other"))
    assert_true(node.is_in_group("inside_test"))
    assert_true(node.is_in_group("inside_test_other"))


func test_remove_group() -> void:
    var script: Script = get_cs_script("RemoveGroup.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node)
    
    node.add_to_group("test")
    node.add_to_group("test_other")
    data.validate_changes("testing meta")
    assert_false(node.is_in_group(&"test"))
    assert_false(node.is_in_group(&"test_other"))
