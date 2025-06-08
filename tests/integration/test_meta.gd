extends RLinkTestBase


class GetSetMeta extends Node:
    func validate_changes() -> void:
        set_meta(&"from_data", get_meta(&"to_data"))
    
    
func test_get_set_meta() -> void:
    var node: GetSetMeta = autofree(GetSetMeta.new())
    var data := rlink_data_cache.get_data(node)
    
    node.set_meta(&"to_data", "hello world")
    data.validate_changes("testing meta")
    
    var value: String = node.get_meta(&"from_data")
    assert_not_null(value)
    assert_eq(value, "hello world")


class RemoveMeta extends Node:
    func validate_changes() -> void:
        remove_meta("to_data")
        
        
func test_remove_meta() -> void:
    var node: RemoveMeta = autofree(RemoveMeta.new())
    var data := rlink_data_cache.get_data(node)
    
    node.set_meta(&"to_data", "hello world")
    data.validate_changes("testing meta")
    assert_false(node.has_meta(&"to_data"))
    
    
class RemoveMetaNull extends Node:
    func validate_changes() -> void:
        set_meta("to_data", null)
        
        
func test_remove_meta_null() -> void:
    var node: RemoveMetaNull = autofree(RemoveMetaNull.new())
    var data := rlink_data_cache.get_data(node)
    
    node.set_meta(&"to_data", "hello world")
    data.validate_changes("testing meta")
    assert_false(node.has_meta(&"to_data"))
