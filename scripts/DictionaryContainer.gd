extends VBoxContainer
class_name DictionaryContainer

@onready var word = preload("res://scenes/word.tscn")

@export var add_button: Button
@export var delete_button: Button

func _ready():
	add_button.pressed.connect(self.new_word)
	delete_button.pressed.connect(self.remove_word)

func insert_new_word(i: int):
	add_child(word.instantiate(), i)
	get_child(i).get_child(4).value = get_child(i).get_path()
	get_child(i).get_child(4)._pressed_get_value.connect(self.remove_word_at_path)

func remove_word_at_path(path: String):
	get_node(path).queue_free()

func remove_word_at(i: int):
	if get_child_count() == 0:
		return
	assert(get_child(i))
	get_child(i).queue_free()

func delete_children():
	for child in get_children():
		child.queue_free()

func reload(list):
	delete_children()
	for item in list:
		var item_node = word.instantiate()
		item_node.get_child(0).text = item["Lemma"]
		item_node.get_child(1).text = item["Pronunciation"]
		item_node.get_child(2).selected = item["PartOfSpeech"]
		item_node.get_child(3).text = item["Gloss"]
		add_child(item_node)
		
func save_data() -> Array[Dictionary]:
	var ret: Array[Dictionary]
	for child in get_children():
		var dict: Dictionary
		dict["Lemma"] = child.get_child(0).text
		dict["Pronunciation"] = child.get_child(1).text
		dict["PartOfSpeech"] = child.get_child(2).selected
		dict["Gloss"] = child.get_child(3).text
		ret.append(dict)
	return ret

func new_word():
	insert_new_word(-1)

func remove_word():
	remove_word_at(-1)
