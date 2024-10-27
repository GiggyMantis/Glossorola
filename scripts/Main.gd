extends Control

@export var open_file_button: Button
@export var save_file_button: Button
@export var new_project_button: Button
@export var translation_settings: OptionButton
@export var part_of_speech_list: TextEdit

const default_parts_of_speech_filename = "res://config/default_parts_of_speech.txt"
const config_filename = "res://config/options.cfg"

var save_location = "unsaved.json"

func _ready():
	open_file_button.pressed.connect(self._open_file_dialog)
	save_file_button.pressed.connect(self._save_file_dialog)
	new_project_button.pressed.connect(self._new_project)
	translation_settings.item_selected.connect(self._translate)
	_new_project()
	$TabManager.current_tab = 0
	
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
	save_file.store_line(JSON.stringify(info))
	save_file.close()
	
func _load_from_file(filename: String):
	save_location = filename
	load_data(load_lang(filename))
	
func _save_to_file(filename: String):
	save_location = filename
	save_lang(filename, collate_data())
	
func _new_project():
	save_location = "unsaved.json"
	$TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer.delete_children()
	$TabManager/PROJECT_MENU/NameOfLanguage.text = ""
	$TabManager/PROJECT_MENU/Autonym.text = ""
	$TabManager/PROJECT_MENU/Langtype.selected = 0
	
	_reload_parts_of_speech()
	_reload_sound_changes()
	
	$TabManager.current_tab = 1

func _reload_parts_of_speech():
	var f = FileAccess.open(default_parts_of_speech_filename, FileAccess.READ)
	part_of_speech_list.text = f.get_as_text()

func _reload_sound_changes():
	$TabManager/SOUND_CHANGE_TOOL/Categories.text = ""
	$TabManager/SOUND_CHANGE_TOOL/RewriteRules.text = ""
	$TabManager/SOUND_CHANGE_TOOL/InputLexicon.text = ""
	$TabManager/SOUND_CHANGE_TOOL/OutputLexicon.text = ""
	$TabManager/SOUND_CHANGE_TOOL/RewriteOnOutput.button_pressed = true

func load_lang(filename: String) -> Dictionary:
	var load_file = FileAccess.open(filename, FileAccess.READ)
	var lines = load_file.get_as_text()
	return JSON.parse_string(lines)
	
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
		save_config_file(translation_settings.selected)
		get_tree().quit() # default behavior

func save_config_file(language: int):
	var config = ConfigFile.new()
	
	config.set_value("Glossorola", "language", language)
	
	config.save(config_filename)

func load_config_file():
	var config = ConfigFile.new()
	var err = config.load(config_filename)
	
	# If the file didn't load, ignore.
	if err != OK:
		return
	
	translation_settings.select(config.get_value("Glossorola", "language"))
	

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
	var minor_version = info["Version"].substr(0,4)
	if info["Version"].ends_with("-beta"):
		match minor_version:
			"1.0.":
				$TabManager/PROJECT_MENU/NameOfLanguage.text = info["LanguageName"]
				$TabManager/PROJECT_MENU/Autonym.text = info["Autonym"]
				$TabManager/PROJECT_MENU/Langtype.selected = info["LanguageType"]
				$TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer.reload(info["Dictionary"])
				$TabManager/GRAMMAR_MODULE/PartOfSpeechList.text = "\n".join(info["PartsOfSpeech"])
	else:
		match minor_version:
			_:
				assert(false, "Unknown version: " + info["Version"] + "	Current version: " + ProjectSettings.get_setting("application/config/version"))
