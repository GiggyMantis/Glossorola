extends Control

@export var open_file_button: Button
@export var save_file_button: Button
@export var new_project_button: Button
@export var translation_settings: OptionButton
@export var part_of_speech_list: TextEdit

const DEFAULT_PARTS_OF_SPEECH = "noun
adjective
adverb
verb
adposition
interjection
conjunction
pronoun
phrase"
const CONFIG_FILENAME = "config/options.cfg"

var save_location = "unsaved.json"

func _ready():
	open_file_button.pressed.connect(self._open_file_dialog)
	save_file_button.pressed.connect(self._save_file_dialog)
	new_project_button.pressed.connect(self._new_project)
	translation_settings.item_selected.connect(self._translate)
	
	load_config_file()
	_translate($TabManager/HOME_MENU/TranslationSettings.selected)
	
	_new_project()
	$TabManager.current_tab = 0
	
	
func get_parts_of_speech():
	return part_of_speech_list.text.split("\n")
	
func _translate(language_index: int):
	save_config_file(translation_settings.selected)
	match language_index:
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
	%DictionaryContainer.delete_children()
	$TabManager/PROJECT_MENU/NameOfLanguage.text = ""
	$TabManager/PROJECT_MENU/Autonym.text = ""
	$TabManager/PROJECT_MENU/Langtype.selected = 0
	$TabManager/GRAMMAR_MODULE/ScrollContainer/ScrollControl/BriefGrammarOverview.text = ""
	$TabManager/PHONOLOGY_MODULE/Vowels.reload()
	$TabManager/PHONOLOGY_MODULE/Consonants.reload()
	
	_reload_parts_of_speech()
	_reload_sound_changes()
	
	$TabManager.current_tab = 1

func _reload_parts_of_speech():
	part_of_speech_list.text = DEFAULT_PARTS_OF_SPEECH

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
		save_config_file(translation_settings.selected)
		save_lang(save_location, collate_data())
		get_tree().quit() # default behavior

func save_config_file(language: int):
	var config = ConfigFile.new()
	
	config.set_value("Glossorola", "language", language)
	
	config.save(CONFIG_FILENAME)

func load_config_file():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILENAME)
	
	# If the file didn't load, ignore.
	if err != OK:
		return
	
	translation_settings.select(config.get_value("Glossorola", "language"))
	
func collate_data() -> Dictionary:
	var info: Dictionary
	info["Version"] = ProjectSettings.get_setting("application/config/version")
	info["Project/LanguageName"] = $TabManager/PROJECT_MENU/NameOfLanguage.text
	info["Project/Autonym"] = $TabManager/PROJECT_MENU/Autonym.text
	info["Project/LanguageType"] = $TabManager/PROJECT_MENU/Langtype.selected
	info["Project/Dictionary"] = %DictionaryContainer.save_data()
	info["Grammar/PartsOfSpeech"] = get_parts_of_speech()
	info["Grammar/BriefGrammarbook"] = $TabManager/GRAMMAR_MODULE/BriefGrammarOverview.text
	info["SCA/Categories"] = $TabManager/SOUND_CHANGE_TOOL/Categories.text
	info["SCA/Rewrite"] = $TabManager/SOUND_CHANGE_TOOL/RewriteRules.text
	info["SCA/Rules"] = $TabManager/SOUND_CHANGE_TOOL/SoundChanges.text
	info["SCA/RewriteOnOutput"] = $TabManager/SOUND_CHANGE_TOOL/RewriteOnOutput.button_pressed
	info["Phonology/Lock"] = $TabManager/PHONOLOGY_MODULE/Lock.button_pressed
	info["Phonology/Vowels"] = $TabManager/PHONOLOGY_MODULE/Vowels.get_data()
	info["Phonology/Consonants"] = $TabManager/PHONOLOGY_MODULE/Consonants.get_data()
	return info
	
func load_data(info: Dictionary):
	var minor_version = info["Version"].substr(0,4)
	if info["Version"].ends_with("-beta"):
		match minor_version:
			"1.2.":
				$TabManager/PROJECT_MENU/NameOfLanguage.text = info["Project/LanguageName"]
				$TabManager/PROJECT_MENU/Autonym.text = info["Project/Autonym"]
				$TabManager/PROJECT_MENU/Langtype.selected = info["Project/LanguageType"]
				%DictionaryContainer.reload(info["Project/Dictionary"])
				$TabManager/GRAMMAR_MODULE/ScrollContainer/ScrollControl/PartOfSpeechList.text = "\n".join(info["Grammar/PartsOfSpeech"])
				$TabManager/GRAMMAR_MODULE/ScrollContainer/ScrollControl/BriefGrammarOverview.text = info["Grammar/BriefGrammarbook"]
				$TabManager/SOUND_CHANGE_TOOL/Categories.text = info["SCA/Categories"]
				$TabManager/SOUND_CHANGE_TOOL/RewriteRules.text = info["SCA/Rewrite"]
				$TabManager/SOUND_CHANGE_TOOL/SoundChanges.text = info["SCA/Rules"]
				$TabManager/SOUND_CHANGE_TOOL/RewriteOnOutput.button_pressed = info["SCA/RewriteOnOutput"]
				$TabManager/PHONOLOGY_MODULE/Lock.button_pressed = info["Phonology/Lock"]
				$TabManager/PHONOLOGY_MODULE/Vowels.from_data(info["Phonology/Vowels"])
				$TabManager/PHONOLOGY_MODULE/Consonants.from_data(info["Phonology/Consonants"])
			"1.1.":
				$TabManager/PROJECT_MENU/NameOfLanguage.text = info["Project/LanguageName"]
				$TabManager/PROJECT_MENU/Autonym.text = info["Project/Autonym"]
				$TabManager/PROJECT_MENU/Langtype.selected = info["Project/LanguageType"]
				%DictionaryContainer.reload(info["Project/Dictionary"])
				$TabManager/GRAMMAR_MODULE/ScrollContainer/ScrollControl/PartOfSpeechList.text = "\n".join(info["Grammar/PartsOfSpeech"])
				$TabManager/GRAMMAR_MODULE/ScrollContainer/ScrollControl/BriefGrammarOverview.text = info["Grammar/BriefGrammarbook"]
				$TabManager/SOUND_CHANGE_TOOL/Categories.text = info["SCA/Categories"]
				$TabManager/SOUND_CHANGE_TOOL/RewriteRules.text = info["SCA/Rewrite"]
				$TabManager/SOUND_CHANGE_TOOL/SoundChanges.text = info["SCA/Rules"]
				$TabManager/SOUND_CHANGE_TOOL/RewriteOnOutput.button_pressed = info["SCA/RewriteOnOutput"]
			"1.0.":
				$TabManager/PROJECT_MENU/NameOfLanguage.text = info["LanguageName"]
				$TabManager/PROJECT_MENU/Autonym.text = info["Autonym"]
				$TabManager/PROJECT_MENU/Langtype.selected = info["LanguageType"]
				%DictionaryContainer.reload(info["Dictionary"])
				$TabManager/GRAMMAR_MODULE/ScrollContainer/ScrollControl/PartOfSpeechList.text = "\n".join(info["PartsOfSpeech"])
				$TabManager/GRAMMAR_MODULE/ScrollContainer/ScrollControl/BriefGrammarOverview.text = ""
	else:
		match minor_version:
			_:
				assert(false, "Unknown version: " + info["Version"] + "	Current version: " + ProjectSettings.get_setting("application/config/version"))
