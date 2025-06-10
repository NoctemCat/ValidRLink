extends RLinkTestBaseCSharp


## The behaviour would be the same if they had errors. I just 
## couldn't test it without triggering debugger
func test_error_discard() -> void:
    var script := get_cs_script("ErrorDiscard.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node, true)
    assert_eq(node.IntVar, int())
    
    data.validate_changes("test discard")
    assert_eq(node.IntVar, int())
    
    data.call_callable(&"CallableBoolVar")
    assert_eq(node.IntVar, int())
    data.call_callable(&"CallableVar")
    assert_eq(node.IntVar, int())
    
    data.call_rlink_button_cs(&"ButtonBool")
    await wait_frames(1)
    assert_eq(node.IntVar, int())
    data.call_rlink_button_cs(&"Button")
    await wait_frames(1)
    assert_eq(node.IntVar, int())
    data.call_rlink_button_cs(&"ButtonSet")
    await wait_frames(1)
    assert_eq(node.IntVar, 205)
