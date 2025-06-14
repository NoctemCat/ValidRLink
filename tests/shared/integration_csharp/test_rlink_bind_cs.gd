extends GutTest


func concat_5(a: String, b: String, c: String, d: String, e: String) -> String:
    return a + b + c + d + e
func concat_4(a: String, b: String, c: String, d: String) -> String:
    return a + b + c + d
func concat_3(a: String, b: String, c: String) -> String:
    return a + b + c
func concat_2(a: String, b: String) -> String:
    return a + b
func concat_1(a: String) -> String:
    return a


func test_bind() -> void:
    var node: Node = autofree(get_cs_script().new())
    var res_callable: String = concat_4.bind("3", "4").callv(["1", "2"])
    var res_rlink_call: String = node.Get4().Bindv(["3", "4"]).RLinkCallv(["1", "2"])
    var res_rlink_await: String = await node.Get4().Bindv(["3", "4"]).RLinkCallvAwait(["1", "2"])
    assert_eq(res_callable, res_rlink_call)
    assert_eq(res_callable, res_rlink_await)
    gut.p(res_callable)


func test_unbind() -> void:
    var node: Node = autofree(get_cs_script().new())
    var res_callable1: String = concat_5.unbind(1).callv(["1", "2", "5", "6", "7", "8"])
    var res_rlink1: String = node.Get5().Unbind(1).RLinkCallv(["1", "2", "5", "6", "7", "8"])
    var res_rlink1_await: String = await node.Get5().Unbind(1).RLinkCallvAwait(["1", "2", "5", "6", "7", "8"])
    assert_eq(res_callable1, res_rlink1)
    assert_eq(res_callable1, res_rlink1_await)
    gut.p(res_callable1)
    
    var res_callable4: String = concat_2.unbind(4).callv(["1", "2", "5", "6", "7", "8"])
    var res_rlink4: String = node.Get2().Unbind(4).RLinkCallv(["1", "2", "5", "6", "7", "8"])
    var res_rlink4_await: String = await node.Get2().Unbind(4).RLinkCallvAwait(["1", "2", "5", "6", "7", "8"])
    assert_eq(res_callable4, res_rlink4)
    assert_eq(res_callable4, res_rlink4_await)
    gut.p(res_callable4)


func test_bind_unbind() -> void:
    var node: Node = autofree(get_cs_script().new())
    var res_callable: String = concat_3.bind("3", "4").unbind(1).callv(["1", "2"])
    var res_rlink: String = node.Get3().Bindv(["3", "4"]).Unbind(1).RLinkCallv(["1", "2"])
    var res_rlink_await: String = await node.Get3().Bindv(["3", "4"]).Unbind(1).RLinkCallvAwait(["1", "2"])
    assert_eq(res_callable, res_rlink)
    assert_eq(res_callable, res_rlink_await)


func test_bind_unbind_bind_unbind() -> void:
    var node: Node = autofree(get_cs_script().new())
    var res_callable: String = concat_4.bindv(["3", "4"]).unbind(2).bindv(["1", "2", "5"]).unbind(1).callv(["6", "7"])
    var res_rlink: String = node.Get4().Bindv(["3", "4"]).Unbind(2).Bindv(["1", "2", "5"]).Unbind(1).RLinkCallv(["6", "7"])
    var res_rlink_await: String = await node.Get4().Bindv(["3", "4"]).Unbind(2).Bindv(["1", "2", "5"]).Unbind(1).RLinkCallvAwait(["6", "7"])
    assert_eq(res_callable, res_rlink)
    assert_eq(res_callable, res_rlink_await)
    gut.p(res_callable)


func test_bind_unbind_bind_bind() -> void:
    var node: Node = autofree(get_cs_script().new())
    var res_callable: String = concat_5.bindv(["3", "4"]).unbind(4).bindv(["1", "2", "5"]).bindv(["6", "7", "8"]).call("10")
    var res_rlink: String = node.Get5().Bindv(["3", "4"]).Unbind(4).Bindv(["1", "2", "5"]).Bindv(["6", "7", "8"]).RLinkCall("10")
    var res_rlink_await: String = await node.Get5().Bindv(["3", "4"]).Unbind(4).Bindv(["1", "2", "5"]).Bindv(["6", "7", "8"]).RLinkCallAwait("10")
    assert_eq(res_callable, res_rlink)
    assert_eq(res_callable, res_rlink_await)
    gut.p(res_callable)
    

func get_cs_script() -> Script:
    return load("res://tests/integration_csharp/scripts/test_rlink_bind_cs_Binds.cs")
