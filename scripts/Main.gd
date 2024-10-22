extends Control

var phonology: Dictionary
	
func save_lang(filename: String, info: Dictionary):
	var save_file = FileAccess.open(filename, FileAccess.WRITE)
	save_file.store_line(JSON.new().stringify(info))
	save_file.close()
	
func load_lang(filename: String) -> Dictionary:
	var load_file = FileAccess.open(filename, FileAccess.READ)
	var lines = load_file.get_as_text()
	return JSON.new().parse_string(lines)
	
func collate_data() -> Dictionary:
	var info: Dictionary
	info["LanguageName"] = (get_node("TabManager/ProjectMenu/NameOfLanguage") as LineEdit).text
	info["Autonym"] = (get_node("TabManager/ProjectMenu/Autonym") as LineEdit).text
	info["LanguageType"] = (get_node("TabManager/ProjectMenu/Langtype") as OptionButton).selected
	info["Phonology"] = phonology
	info["Dictionary"] = (get_node("TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer") as DictionaryContainer).save_data()
	return info
	
func load_data(info: Dictionary):
	(get_node("TabManager/ProjectMenu/NameOfLanguage") as LineEdit).text = info["LanguageName"]
	(get_node("TabManager/ProjectMenu/Autonym") as LineEdit).text = info["Autonym"]
	(get_node("TabManager/ProjectMenu/Langtype") as OptionButton).selected = info["LanguageType"]
	(get_node("TabManager/DICTIONARY_MODULE/DictionaryScrollContainer/DictionaryContainer") as DictionaryContainer).reload(info["Dictionary"])
	phonology = info["Phonology"]
	
# Debug Functions

#func _ready():
	#save_lang("Test.json", collate_data())
