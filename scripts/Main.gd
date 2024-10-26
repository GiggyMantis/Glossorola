extends Control

@export var open_file_button: Button
@export var save_file_button: Button
@export var new_project_button: Button
@export var translation_settings: OptionButton
@export var part_of_speech_list: TextEdit

var save_location = "unsaved.json"

func _ready():
	open_file_button.pressed.connect(self._open_file_dialog)
	save_file_button.pressed.connect(self._save_file_dialog)
	new_project_button.pressed.connect(self._new_project)
	translation_settings.item_selected.connect(self._translate)
	
func get_parts_of_speech():
	return part_of_speech_list.text.split("\n")
	
func _translate(i: int):
	match i:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("es")
		2:
			TranslationServer.set_locale("pt_BR")

	
func save_lang(filename: String, info: Dictionary):
	var save_file = FileAccess.open(filename, FileAccess.WRITE)
	save_file.store_line(JSON.new().stringify(info))
	save_file.close()
	
func _load_from_file(filename: String):
	save_location = filename
	load_data(load_lang(filename))
	
func _save_to_file(filename: String):
	save_location = filename
	save_lang(filename, collate_data())
	
func _new_project():
	$TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer.delete_children()
	$TabManager/PROJECT_MENU/NameOfLanguage.text = ""
	$TabManager/PROJECT_MENU/Autonym.text = ""
	$TabManager/PROJECT_MENU/Langtype.selected = 0
	$TabManager.current_tab = 1

func load_lang(filename: String) -> Dictionary:
	var load_file = FileAccess.open(filename, FileAccess.READ)
	var lines = load_file.get_as_text()
	return JSON.new().parse_string(lines)
	
func _open_file_dialog():
	var dialog = FileDialog.new()
	dialog.position = Vector2(500, 100)
	dialog.size = Vector2(200, 400)
	dialog.file_selected.connect(self._load_from_file)
	dialog.title = "OPEN_FILE"
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.show()
	add_child(dialog)
	
func _save_file_dialog():
	var dialog = FileDialog.new()
	dialog.position = Vector2(500, 100)
	dialog.size = Vector2(200, 400)
	dialog.file_selected.connect(self._save_to_file)
	dialog.title = "SAVE_FILE"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.show()
	add_child(dialog)
		
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_lang(save_location, collate_data())
		get_tree().quit() # default behavior

func collate_data() -> Dictionary:
	var info: Dictionary
	info["Version"] = ProjectSettings.get_setting("application/config/version")
	info["LanguageName"] = $TabManager/PROJECT_MENU/NameOfLanguage.text
	info["Autonym"] = $TabManager/PROJECT_MENU/Autonym.text
	info["LanguageType"] = $TabManager/PROJECT_MENU/Langtype.selected
	info["Dictionary"] = $TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer.save_data()
	info["PartsOfSpeech"] = get_parts_of_speech()
	return info
	
func load_data(info: Dictionary):
	match info["Version"]:
		"1.0.0-beta":
			$TabManager/PROJECT_MENU/NameOfLanguage.text = info["LanguageName"]
			$TabManager/PROJECT_MENU/Autonym.text = info["Autonym"]
			$TabManager/PROJECT_MENU/Langtype.selected = info["LanguageType"]
			$TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer.reload(info["Dictionary"])
			$TabManager/GRAMMAR_MODULE/PartOfSpeechList.text = "\n".join(info["PartsOfSpeech"])
		_:
			assert(false, "Unknown version: " + info["Version"] + "	Current version: " + ProjectSettings.get_setting("application/config/version"))
