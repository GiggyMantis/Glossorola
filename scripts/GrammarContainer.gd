extends GridContainer

const TABLE_SIZE := Vector2(1152, 500)

var table = preload("res://scenes/table/table.tscn")
var background = preload("res://scenes/table/background.tscn")
@onready var lock_button = get_node("../../Lock")
@onready var new_table_button = get_node("../../NewTable")

func _ready():
	lock_button.pressed.connect(self.lock)
	new_table_button.pressed.connect(self._add_new_table)
	reload()

func get_data() -> Array[Dictionary]:
	var ret: Array[Dictionary]
	for child in get_children():
		ret.append(child.get_child(0).data._to_dictionary())
	return ret

func from_data(data) -> void:
	for child in get_children():
		child.queue_free()
	for d in data:
		var t = table.instantiate()
		t.data = DataFrame._from_dictionary(d)
		t.editable = not lock_button.button_pressed
		t.render()
		var b = background.instantiate()
		b.custom_minimum_size = TABLE_SIZE
		b.add_child(t)
		add_child(b)

func lock():
	for child in get_children():
		child.get_child(0).editable = not lock_button.button_pressed
		child.get_child(0).render()

func reload():
	lock_button.button_pressed = false
	
	for child in get_children():
		child.queue_free()

func _add_new_table():
	var columns = [TranslationServer.translate(&"NEW_GRAMMAR_TABLE") as String]
	var data = [
		[""]
	]
	var t = table.instantiate()
	t.data = DataFrame.New(data, columns)
	t.editable = not lock_button.button_pressed
	t.render()
	var b = background.instantiate()
	b.custom_minimum_size = TABLE_SIZE
	b.add_child(t)
	add_child(b)
	
