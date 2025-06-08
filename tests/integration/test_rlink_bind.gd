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
    var res_callable: String = concat_4.bind("3", "4").callv(["1", "2"])
    var res_rlink: String = RLinkButton.new(concat_4).bindv(["3", "4"]).rlink_callv(["1", "2"])
    assert_eq(res_callable, res_rlink)
    gut.p(res_callable)


func test_unbind() -> void:
    var res_callable1: String = concat_5.unbind(1).callv(["1", "2", "5", "6", "7", "8"])
    var res_rlink1: String = RLinkButton.new(concat_5).unbind(1).rlink_callv(["1", "2", "5", "6", "7", "8"])
    assert_eq(res_callable1, res_rlink1)
    gut.p(res_callable1)
    
    var res_callable4: String = concat_2.unbind(4).callv(["1", "2", "5", "6", "7", "8"])
    var res_rlink4: String = RLinkButton.new(concat_2).unbind(4).rlink_callv(["1", "2", "5", "6", "7", "8"])
    assert_eq(res_callable4, res_rlink4)
    gut.p(res_callable4)


func test_bind_unbind() -> void:
    var res_callable: String = concat_3.bind("3", "4").unbind(1).callv(["1", "2"])
    var res_rlink: String = RLinkButton.new(concat_3).bindv(["3", "4"]).unbind(1).rlink_callv(["1", "2"])
    assert_eq(res_callable, res_rlink)


func test_bind_unbind_bind_unbind() -> void:
    var res_callable: String = concat_4.bindv(["3", "4"]).unbind(2).bindv(["1", "2", "5"]).unbind(1).callv(["6", "7"])
    var res_rlink: String = RLinkButton.new(concat_4).bindv(["3", "4"]).unbind(2).bindv(["1", "2", "5"]).unbind(1).rlink_callv(["6", "7"])
    assert_eq(res_callable, res_rlink)
    gut.p(res_callable)


func test_bind_unbind_bind_bind() -> void:
    var res_callable: String = concat_5.bind("3", "4").unbind(4).bindv(["1", "2", "5"]).bindv(["6", "7", "8"]).call("10")
    var res_rlink: String = RLinkButton.new(concat_5).bindv(["3", "4"]).unbind(4).bindv(["1", "2", "5"]).bindv(["6", "7", "8"]).rlink_call("10")
    assert_eq(res_callable, res_rlink)
    gut.p(res_callable)
    

#Runs once after all tests
func after_all() -> void:
    queue_free()
