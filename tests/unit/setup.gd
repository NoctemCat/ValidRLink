extends GutTest

const Context = preload("res://addons/valid_rlink/context.gd")
var _ctx: Context

#Runs once before all tests
func before_all():
    _ctx = Context.new()
    
#Runs before each test
func before_each():
    pass
    
#Runs after each test
func after_each():
    pass

#Runs once after all tests
func after_all():
    _ctx.free()
    
