extends RLinkTestBase


class Callables extends Node:
    @export var int_var: int
    
    @export var button := RLinkButton.new(from_button)
    @export var callable := from_callable
    
    
    func from_button() -> void:
        int_var = 50
    
    
    func from_callable() -> void:
        int_var = 100
        

func test_call_buttons() -> void:
    var node: Callables = autofree(Callables.new())
    var data := rlink_data_cache.get_data(node, true)
    
    assert_eq(node.int_var, int())
    data.call_rlink_button(&"button")
    assert_eq(node.int_var, 50)
    data.call_callable(&"callable")
    assert_eq(node.int_var, 100)


class CallablesAwait extends Node:
    @export var int_var: int
    @export var callable := from_callable
    
    
    func from_callable() -> void:
        await Engine.get_main_loop().create_timer(0.25).timeout
        int_var = 100
    
    
    func validate_changes() -> void:
        int_var = 200
        
        
func test_await() -> void:
    var node: CallablesAwait = autofree(CallablesAwait.new())
    var data := rlink_data_cache.get_data(node, true)
    assert_eq(node.int_var, int())
    
    data.call_callable(&"callable")
    assert_eq(node.int_var, int())
    await wait_seconds(0.25)
    assert_eq(node.int_var, 100)
    node.int_var = 0
    
    data.call_callable(&"callable")
    data.validate_changes("await test")
    assert_eq(node.int_var, 0)
    await wait_seconds(0.25)
    assert_eq(node.int_var, 200)
