@warning_ignore_start("untyped_declaration", "shadowed_variable", "unused_variable", "unused_private_class_variable", "unused_parameter", "shadowed_variable_base_class")
# ------------------------------------------------------------------------------
# This datastructure represents a simple one-to-many relationship.  It manages
# a dictionary of value/array pairs.  It ignores duplicates of both the "one"
# and the "many".
# ------------------------------------------------------------------------------
var _items = {}

# return the size of _items or the size of an element in _items if "one" was
# specified.
func size(one = null):
	var to_return = 0
	if (one == null):
		to_return = _items.size()
	elif (_items.has(one)):
		to_return = _items[one].size()
	return to_return

# Add an element to "one" if it does not already exist
func add(one, many_item):
	if (_items.has(one) and !_items[one].has(many_item)):
		_items[one].append(many_item)
	else:
		_items[one] = [many_item]

func clear():
	_items.clear()

func has(one, many_item):
	var to_return = false
	if (_items.has(one)):
		to_return = _items[one].has(many_item)
	return to_return

func to_s():
	var to_return = ''
	for key in _items:
		to_return += str(key, ":  ", _items[key], "\n")
	return to_return
