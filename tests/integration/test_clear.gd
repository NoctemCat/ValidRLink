extends RLinkTestBase


class NodeHolder extends Node:
    @export var node1: Node
    @export var node2: Node
    @export var node3: Node
    @export var node4: Node
    @export var node5: Node
    @export var node6: Node
    
    
func test_clear() -> void:
    var counter: Object = gut.get_orphan_counter()
    counter.add_counter("clear_test")

    var test_node := NodeHolder.new()
    for i in 6:
        var child := NodeHolder.new()
        test_node.set("node" + str(i + 1), child)
        test_node.add_child(child)
    for i in 6:
        var child := NodeHolder.new()
        test_node.node1.set("node" + str(i + 1), child)
        test_node.node1.add_child(child)
        
    var data := rlink_data_cache.get_data(test_node, true)
    assert_not_null(data)
    
    assert_eq(roundi(counter.get_orphans_since("clear_test")), 26)
    test_node.node2.free()
    assert_eq(roundi(counter.get_orphans_since("clear_test")), 25)
    test_node.node1.free()
    assert_eq(roundi(counter.get_orphans_since("clear_test")), 18)
    test_node.free()
    assert_eq(roundi(counter.get_orphans_since("clear_test")), 13)
    rlink_map.clear()
    assert_no_new_orphans('should pass')
