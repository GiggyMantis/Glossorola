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
	var u = Word.generate_uuid()
	get_child(i).uuid = u
	Word.uuids.append(u)
	get_child(i).get_child(4).value = get_child(i).uuid
	get_child(i).get_child(4)._pressed_get_value.connect(self.remove_word_at_uuid)
	get_child(i)._reload()

func get_word_from_uuid(uuid: int) -> Word:
	for child in get_children():
		if child.uuid == uuid:
			return Word.New(child.get_child(0).text, child.get_child(1).text, child.get_child(2).selected, child.get_child(3).gloss, child.uuid)
	return null

func remove_word_at_uuid(uuid: int):
	for child in get_children():
		if child.uuid == uuid:
			child.queue_free()
			Word.uuids.remove_at(Word.uuids.find(uuid))
			break

func remove_word_at(i: int):
	if get_child_count() == 0:
		return
	assert(get_child(i))
	Word.uuids.remove_at(Word.uuids.find(get_child(i).uuid))
	get_child(i).queue_free()

func delete_children():
	for child in get_children():
		child.queue_free()

func reload(list: Array[Word]):
	delete_children()
	for item in list:
		implement_word(item)

func implement_word(item: Word):
	var item_node = word.instantiate()
	item_node.get_child(0).text = item.lemma
	item_node.get_child(1).text = item.pronunciation
	item_node.get_child(3).text = item.gloss
	item_node.uuid = item.uuid
	item_node._reload()
	item_node.get_child(2).selected = item.part_of_speech
	add_child(item_node)

func load_data(a: Array[Dictionary]):
	var list = {}
	for word in a:
		list.append(Word.from_dictionary(word))
	reload(list)
		

func save_data() -> Array[Dictionary]:
	var ret: Array[Dictionary]
	for child in get_children():
		var word := Word.New(child.get_child(0).text, child.get_child(1).text, child.get_child(2).selected, child.get_child(3).text, child.uuid)
		ret.append(word._to_dictionary())
	return ret

func new_word():
	insert_new_word(-1)

func remove_word():
	remove_word_at(-1)

class Word extends Resource:
	static var uuids = []
	
	var uuid: int
	var lemma: String
	var pronunciation: String
	var part_of_speech: int
	var gloss: String
	
	static func generate_uuid() -> int:
		var ret = randi()
		while ret in uuids:
			ret = randi()
		return ret
	
	static func New(lemma: String, pronunciation: String, part_of_speech: int, gloss: String, uuid: int = generate_uuid()) -> Word:
		uuids.append(uuid)
		var ret = Word.new()
		ret.uuid = uuid
		ret.lemma = lemma
		ret.pronunciation = pronunciation
		ret.part_of_speech = part_of_speech
		ret.gloss = gloss
		return ret
	
	static func from_dictionary(dict: Dictionary) -> Word:
		var ret = Word.new()
		ret.uuid = dict["ID"]
		ret.lemma = dict["Lemma"]
		ret.pronunciation = dict["Pronunciation"]
		ret.part_of_speech = dict["PartOfSpeech"]
		ret.gloss = dict["Gloss"]
		return ret
		
	func _to_string() -> String:
		var display_pronunciation = "/" + pronunciation + "/"
		if pronunciation.begins_with("/") or pronunciation.begins_with("["):
			display_pronunciation = pronunciation
		
		return "⟨" + lemma + "⟩ " + display_pronunciation + " pos#" + str(part_of_speech) + " \"" + gloss + "\""
	
	func _to_dictionary() -> Dictionary:
		var ret: Dictionary
		ret["ID"] = uuid
		ret["Lemma"] = lemma
		ret["Pronunciation"] = pronunciation
		ret["PartOfSpeech"] = part_of_speech
		ret["Gloss"] = gloss
		return ret
