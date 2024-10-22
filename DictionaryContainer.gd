extends VBoxContainer
class_name DictionaryContainer


var word_node = preload("res://word.tscn")

@export var add_button: Button
@export var delete_button: Button

func _ready():
	add_button.pressed.connect(self._add_new)
	delete_button.pressed.connect(self._delete)
	#reload([{"Lemma":"Test","Pronunciation":"/test/","PartOfSpeech":0,"Gloss":"Test"}])

func reload(list: Array[Dictionary]):
	for child in get_children():
		child.queue_free()
	for item in list:
		var item_node = word_node.instantiate()
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

func _add_new():
	add_child(word_node.instantiate())

func _delete():
	if get_child_count() == 0:
		return
	get_children()[get_child_count() - 1].queue_free()
