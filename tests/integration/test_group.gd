extends RLinkTestBase


class GetSetGroup extends Node:
    func validate_changes() -> void:
        if is_in_group("test"):
            add_to_group("inside_test")
        if is_in_group("test_other"):
            add_to_group("inside_test_other")
    
    
func test_get_add_group() -> void:
    var node: GetSetGroup = autofree(GetSetGroup.new())
    var data := rlink_data_cache.get_data(node)
    
    node.add_to_group("test")
    node.add_to_group("test_other")
    data.validate_changes("testing meta")
    
    assert_true(node.is_in_group("test"))
    assert_true(node.is_in_group("test_other"))
    assert_true(node.is_in_group("inside_test"))
    assert_true(node.is_in_group("inside_test_other"))


class RemoveGroup extends Node:
    func validate_changes() -> void:
        remove_from_group("test")
        remove_from_group("test_other")
        
        
func test_remove_group() -> void:
    var node: RemoveGroup = autofree(RemoveGroup.new())
    var data := rlink_data_cache.get_data(node)
    
    node.add_to_group("test")
    node.add_to_group("test_other")
    data.validate_changes("testing meta")
    assert_false(node.is_in_group(&"test"))
    assert_false(node.is_in_group(&"test_other"))
