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

func reload(list: Array[Word]):
	delete_children()
	for item in list:
		var item_node = word.instantiate()
		item_node.get_child(0).text = item.lemma
		item_node.get_child(1).text = item.pronunciation
		item_node.get_child(2).selected = item.part_of_speech
		item_node.get_child(3).text = item.gloss
		add_child(item_node)
		
func save_data() -> Array[Dictionary]:
	var ret: Array[Dictionary]
	for child in get_children():
		var word := Word.New(child.get_child(0).text, child.get_child(1).text, child.get_child(2).selected, child.get_child(3).text)
		ret.append(word._to_dictionary())
	return ret

func new_word():
	insert_new_word(-1)

func remove_word():
	remove_word_at(-1)

class Word extends Resource:
	var lemma: String
	var pronunciation: String
	var part_of_speech: int
	var gloss: String
	
	static func New(lemma: String, pronunciation: String, part_of_speech: int, gloss: String) -> Word:
		var ret = Word.new()
		ret.lemma = lemma
		ret.pronunciation = pronunciation
		ret.part_of_speech = part_of_speech
		ret.gloss = gloss
		return ret
	
	static func from_dictionary(dict: Dictionary) -> Word:
		var ret = Word.new()
		ret.lemma = dict["Lemma"]
		ret.pronunciation = dict["Pronunciation"]
		ret.part_of_speech = dict["PartOfSpeech"]
		ret.gloss = dict["Gloss"]
		return ret
	
	func _to_dictionary() -> Dictionary:
		var ret: Dictionary
		ret["Lemma"] = lemma
		ret["Pronunciation"] = pronunciation
		ret["PartOfSpeech"] = part_of_speech
		ret["Gloss"] = gloss
		return ret
