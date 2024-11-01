extends Node

@onready var lock_button = get_node("../Lock")

func _ready():
	lock_button.pressed.connect(self.lock)
	reload()	

func get_data() -> Dictionary:
	return $Background/Table.data._to_dictionary()

func from_data(data: Dictionary) -> void:
	$Background/Table.data = DataFrame._from_dictionary(data)
	$Background/Table.render()

func lock():
	$Background/Table.editable = not lock_button.button_pressed
	$Background/Table.render()

func reload():
	lock_button.button_pressed = false
	
	var columns = [name]
	var data = [
		[""]
	]
	
	$Background/Table.data = DataFrame.New(data, columns)
	$Background/Table.render()
	$Background/Table.editable = not lock_button.button_pressed
