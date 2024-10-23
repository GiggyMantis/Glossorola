extends Control

@export var open_file_button: Button
@export var save_file_button: Button

var phonology: Dictionary
var save_location = "unsaved.json"

func _ready():
	open_file_button.pressed.connect(self._open_file_dialog)
	save_file_button.pressed.connect(self._save_file_dialog)
	
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
	info["LanguageName"] = (get_node("TabManager/PROJECT_MENU/NameOfLanguage") as LineEdit).text
	info["Autonym"] = (get_node("TabManager/PROJECT_MENU/Autonym") as LineEdit).text
	info["LanguageType"] = (get_node("TabManager/PROJECT_MENU/Langtype") as OptionButton).selected
	info["Phonology"] = phonology
	info["Dictionary"] = (get_node("TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer") as DictionaryContainer).save_data()
	return info
	
func load_data(info: Dictionary):
	match info["Version"]:
		"1.0.0-alpha":
			(get_node("TabManager/PROJECT_MENU/NameOfLanguage") as LineEdit).text = info["LanguageName"]
			(get_node("TabManager/PROJECT_MENU/Autonym") as LineEdit).text = info["Autonym"]
			(get_node("TabManager/PROJECT_MENU/Langtype") as OptionButton).selected = info["LanguageType"]
			(get_node("TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer") as DictionaryContainer).reload(info["Dictionary"])
			phonology = info["Phonology"]
		_:
			assert(false, "Unknown version: " + info["Version"] + "	Current version: " + ProjectSettings.get_setting("application/config/version"))
