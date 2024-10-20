extends Control

@export var tab_index: int
var parent: TabBar

func _ready():
	parent = get_parent() as TabBar

func _process(delta):
	if (parent.current_tab == tab_index):
		true_show()
	else:
		true_hide()
		
func true_show():
	show()
	for c in get_children():
		c.set_process(true)

func true_hide():
	hide()
	for c in get_children():
		c.set_process(false)
