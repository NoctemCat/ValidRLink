extends RLinkTestBase


class ErrorDiscard extends Node:
    @export var int_var: int
    @export var callable := callable_discard
    @export var callable_bool := callable_discard_bool
    @export var button := RLinkButton.new(btn_discard)
    @export var button_bool := RLinkButton.new(btn_discard_bool)


    func validate_changes() -> bool:
        int_var = 200
        return false
    
    
    func callable_discard_bool() -> bool:
        int_var = 201
        return false
        
        
    @warning_ignore("untyped_declaration")
    func callable_discard():
        int_var = 202
        return null
        

    func btn_discard_bool() -> bool:
        int_var = 203
        return false
        
        
    @warning_ignore("untyped_declaration")
    func btn_discard():
        int_var = 204
        return null
        

## The behaviour would be the same if they had errors. I just 
## couldn't test it without triggering debugger
func test_error_discard() -> void:
    var node: ErrorDiscard = autofree(ErrorDiscard.new())
    var data := rlink_data_cache.get_data(node, true)
    assert_eq(node.int_var, int())
    
    data.validate_changes("test discard")
    assert_eq(node.int_var, int())
    
    data.call_callable(&"callable")
    assert_eq(node.int_var, int())
    data.call_callable(&"callable_bool")
    assert_eq(node.int_var, int())
    
    data.call_rlink_button(&"button")
    assert_eq(node.int_var, int())
    data.call_rlink_button(&"button_bool")
    assert_eq(node.int_var, int())
    
