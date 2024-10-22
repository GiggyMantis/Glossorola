extends GridContainer

@export var add_button: Button
@export var delete_button: Button

func _ready():
	add_button.pressed.connect(self._add_new)
	delete_button.pressed.connect(self._delete)

func reload(list: Array[String]):
	for child in get_children():
		child.queue_free()
	for item in list:
		var item_node = LineEdit.new()
		item_node.text = item
		add_child(item_node)

func _add_new():
	add_child(LineEdit.new())

func _delete():
	if get_child_count() == 0:
		return
	get_children()[get_child_count() - 1].queue_free()
