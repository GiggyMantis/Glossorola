extends HBoxContainer

@export var pos_selector: OptionButton

var uuid: int

func _ready():
	pos_selector.pressed.connect(self._reload)
	
func _reload():
	var old_selected = pos_selector.get_item_text(pos_selector.selected)
	var to_select = -1
	pos_selector.clear()
	var poses = Main.get_parts_of_speech()
	for i in len(poses):
		if poses[i] == old_selected:
			to_select = i
		pos_selector.add_item(poses[i],i)
	pos_selector.select(to_select)
