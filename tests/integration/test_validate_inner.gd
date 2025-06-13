extends RLinkTestBase


class Resource3 extends Resource:
    @export var int_var: int
    
    func _validate_changes() -> void:
        int_var = 300
        
        
class Resource2 extends Resource:
    @export var inner: Resource3
    @export var int_var: int
    
    func _validate_changes() -> void:
        int_var = 200


class Resource1 extends Resource:
    @export var inner1: Resource2
    @export var inner2: Resource2
    @export var inner3: Resource2
    @export var int_var: int
    
    func _validate_changes() -> void:
        int_var = 100


class OuterNode extends Node:
    @export var inner1: Resource1
    @export var inner2: Resource1
    @export var inner3: Resource1
    
    func _validate_changes() -> void:
        pass


func test_validate_recursion() -> void:
    var node: OuterNode = _get_structure()
    
    var data := rlink_data_cache.get_data(node)
    data.validate_changes("")
    assert_eq(node.inner1.int_var, 100)
    assert_eq(node.inner1.inner1.int_var, 200)
    assert_eq(node.inner1.inner1.inner.int_var, int())
    assert_eq(node.inner1.inner2.int_var, 200)
    assert_eq(node.inner1.inner2.inner.int_var, int())
    assert_eq(node.inner1.inner3.int_var, 200)
    assert_eq(node.inner1.inner3.inner.int_var, int())
    assert_eq(node.inner2.int_var, 100)
    assert_eq(node.inner2.inner1.int_var, 200)
    assert_eq(node.inner2.inner1.inner.int_var, int())
    assert_eq(node.inner2.inner2.int_var, 200)
    assert_eq(node.inner2.inner2.inner.int_var, int())
    assert_eq(node.inner2.inner3.int_var, 200)
    assert_eq(node.inner2.inner3.inner.int_var, int())
    assert_eq(node.inner3.int_var, 100)
    assert_eq(node.inner3.inner1.int_var, 200)
    assert_eq(node.inner3.inner1.inner.int_var, int())
    assert_eq(node.inner3.inner2.int_var, 200)
    assert_eq(node.inner3.inner2.inner.int_var, int())
    assert_eq(node.inner3.inner3.int_var, 200)
    assert_eq(node.inner3.inner3.inner.int_var, int())


func test_validate_exception() -> void:
    var node: OuterNode = _get_structure()
    
    var data := rlink_data_cache.get_data(node)
    var data_inner := rlink_data_cache.get_data(node.inner1)
    data.add_validate_exception(data_inner.tool_obj.get_instance_id())
    
    data.validate_changes("")
    assert_eq(node.inner1.int_var, int())
    assert_eq(node.inner1.inner1.int_var, int())
    assert_eq(node.inner1.inner1.inner.int_var, int())
    assert_eq(node.inner1.inner2.int_var, int())
    assert_eq(node.inner1.inner2.inner.int_var, int())
    assert_eq(node.inner1.inner3.int_var, int())
    assert_eq(node.inner1.inner3.inner.int_var, int())
    assert_eq(node.inner2.int_var, 100)
    assert_eq(node.inner2.inner1.int_var, 200)
    assert_eq(node.inner2.inner1.inner.int_var, int())
    assert_eq(node.inner2.inner2.int_var, 200)
    assert_eq(node.inner2.inner2.inner.int_var, int())
    assert_eq(node.inner2.inner3.int_var, 200)
    assert_eq(node.inner2.inner3.inner.int_var, int())
    assert_eq(node.inner3.int_var, 100)
    assert_eq(node.inner3.inner1.int_var, 200)
    assert_eq(node.inner3.inner1.inner.int_var, int())
    assert_eq(node.inner3.inner2.int_var, 200)
    assert_eq(node.inner3.inner2.inner.int_var, int())
    assert_eq(node.inner3.inner3.int_var, 200)
    assert_eq(node.inner3.inner3.inner.int_var, int())
    
    data_inner.validate_changes("")
    assert_eq(node.inner1.int_var, 100)
    assert_eq(node.inner1.inner1.int_var, 200)
    assert_eq(node.inner1.inner1.inner.int_var, 300)
    assert_eq(node.inner1.inner2.int_var, 200)
    assert_eq(node.inner1.inner2.inner.int_var, 300)
    assert_eq(node.inner1.inner3.int_var, 200)
    assert_eq(node.inner1.inner3.inner.int_var, 300)

    
func _get_structure() -> OuterNode:
    var node: OuterNode = autofree(OuterNode.new())
    node.inner1 = Resource1.new()
    node.inner1.inner1 = Resource2.new()
    node.inner1.inner1.inner = Resource3.new()
    node.inner1.inner2 = Resource2.new()
    node.inner1.inner2.inner = Resource3.new()
    node.inner1.inner3 = Resource2.new()
    node.inner1.inner3.inner = Resource3.new()
    node.inner2 = Resource1.new()
    node.inner2.inner1 = Resource2.new()
    node.inner2.inner1.inner = Resource3.new()
    node.inner2.inner2 = Resource2.new()
    node.inner2.inner2.inner = Resource3.new()
    node.inner2.inner3 = Resource2.new()
    node.inner2.inner3.inner = Resource3.new()
    node.inner3 = Resource1.new()
    node.inner3.inner1 = Resource2.new()
    node.inner3.inner1.inner = Resource3.new()
    node.inner3.inner2 = Resource2.new()
    node.inner3.inner2.inner = Resource3.new()
    node.inner3.inner3 = Resource2.new()
    node.inner3.inner3.inner = Resource3.new()
    return node
