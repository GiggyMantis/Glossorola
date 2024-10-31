extends Node

func _ready():
	get_node("../Lock").pressed.connect(self.lock)
	reload()	

func get_data() -> Dictionary:
	return $Background/Table.data._to_dictionary()

func from_data(data: Dictionary) -> void:
	$Background/Table.data = DataFrame._from_dictionary(data)
	$Background/Table.render()

func lock():
	$Background/Table.editable = not get_node("../Lock").button_pressed
	$Background/Table.render()

func reload():
	get_node("../Lock").button_pressed = false
	
	var columns = [name]
	var data = [
		[""]
	]
	
	$Background/Table.data = DataFrame.New(data, columns)
	$Background/Table.render()
