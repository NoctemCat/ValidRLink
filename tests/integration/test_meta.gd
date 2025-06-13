extends RLinkTestBase


class GetSetMeta extends Node:
    func validate_changes() -> void:
        set_meta(&"from_data1", get_meta(&"to_data"))
        set_meta(&"from_data2", get_meta(&"to_data"))
        set_meta(&"from_data3", get_meta(&"to_data"))
        set_meta(&"from_data_int1", get_meta(&"to_data_int"))
        set_meta(&"from_data_int2", get_meta(&"to_data_int"))
        set_meta(&"from_data_int3", get_meta(&"to_data_int"))
    
    
func test_get_set_meta() -> void:
    var node: GetSetMeta = autofree(GetSetMeta.new())
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


class RemoveMeta extends Node:
    func validate_changes() -> void:
        remove_meta("to_data1")
        remove_meta("to_data2")
        remove_meta("to_data_int1")
        remove_meta("to_data_int2")
        
        
func test_remove_meta() -> void:
    var node: RemoveMeta = autofree(RemoveMeta.new())
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
    
    
class RemoveMetaNull extends Node:
    func validate_changes() -> void:
        set_meta("to_data1", null)
        set_meta("to_data2", null)
        set_meta("to_data_int1", null)
        set_meta("to_data_int2", null)
        
        
func test_remove_meta_null() -> void:
    var node: Node = autofree(RemoveMetaNull.new())
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
