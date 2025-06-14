extends RLinkTestBaseCSharp
        

func test_call_buttons() -> void:
    var script := get_cs_script("Callables.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node, true)
    assert_eq(node.IntVar, int())
    await data.call_rlink_button_cs(&"Button")
    assert_eq(node.IntVar, 50)
    if callables_supported():
        await data.call_callable(&"CallableVar")
        assert_eq(node.IntVar, 100)


func test_await() -> void:
    var script := get_cs_script("CallablesAwait.cs")
    var node: Node = autofree(script.new())
    var data := rlink_data_cache.get_data(node, true)
    assert_eq(node.IntVar, int())
    
    data.call_rlink_button_cs(&"Button")
    assert_eq(node.IntVar, int())
    await wait_seconds(0.25)
    assert_eq(node.IntVar, 100)
    node.IntVar = 0
    
    data.call_rlink_button_cs(&"Button")
    data.validate_changes("changes")
    assert_eq(node.IntVar, 0)
    await wait_seconds(0.25)
    assert_eq(node.IntVar, 200)
