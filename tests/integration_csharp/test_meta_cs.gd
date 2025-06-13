extends RLinkTestBaseCSharp
    
    
func test_get_set_meta() -> void:
    var script: Script = get_cs_script("GetSetMeta.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node)
    
    node.set_meta(&"to_data", "hello world")
    node.set_meta(&"to_data_int", 12345)
    data.validate_changes("testing meta")
    
    assert_eq(node.get_meta(&"from_data1"), "hello world")
    assert_eq(node.get_meta(&"from_data2"), "hello world")
    assert_eq(node.get_meta(&"from_data3"), "hello world")
    assert_eq(node.get_meta(&"from_data_int1"), 12345)
    assert_eq(node.get_meta(&"from_data_int1"), 12345)
    assert_eq(node.get_meta(&"from_data_int1"), 12345)


func test_remove_meta() -> void:
    var script: Script = get_cs_script("RemoveMeta.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node)
    
    node.set_meta(&"to_data1", "hello world")
    node.set_meta(&"to_data2", "bye world")
    node.set_meta(&"to_data_int1", 123)
    node.set_meta(&"to_data_int2", 456)
    data.validate_changes("testing meta")
    assert_false(node.has_meta(&"to_data1"))
    assert_false(node.has_meta(&"to_data2"))
    assert_false(node.has_meta(&"to_data_int1"))
    assert_false(node.has_meta(&"to_data_int2"))
    

func test_remove_meta_null() -> void:
    var script: Script = get_cs_script("RemoveMetaNull.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node)
    node.set_meta(&"to_data1", "hello world")
    node.set_meta(&"to_data2", "bye world")
    node.set_meta(&"to_data_int1", 123)
    node.set_meta(&"to_data_int2", 456)
    data.validate_changes("testing meta")
    assert_false(node.has_meta(&"to_data1"))
    assert_false(node.has_meta(&"to_data2"))
    assert_false(node.has_meta(&"to_data_int1"))
    assert_false(node.has_meta(&"to_data_int2"))
