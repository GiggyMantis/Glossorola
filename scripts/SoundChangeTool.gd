extends Control

@export var apply_lexicon: Button
@export var apply_lemma: Button
@export var apply_ipa: Button

func _ready():
	apply_lexicon.pressed.connect(self._apply_lexicon)
	apply_lemma.pressed.connect(self._apply_lemma)
	apply_ipa.pressed.connect(self._apply_ipa)

func _apply(text: String) -> Array[String]:
	var sca = SCA.new()
	sca.categories = $Categories.text
	sca.lexicon = text
	sca.rules = $SoundChanges.text
	sca.rewrite_rules = $RewriteRules.text
	sca.rewrite_output = $RewriteOnOutput.button_pressed
	return sca.apply()
	
func _apply_lemma():
	var dict = %DictionaryContainer.save_data()
	var new_dict = dict
	for i in dict.size():
		new_dict[i]["Lemma"] = _apply(dict[i]["Lemma"])[0]
		
	%DictionaryContainer.reload(new_dict)

func _apply_ipa():
	var dict = %DictionaryContainer.save_data()
	var new_dict = dict
	for i in dict.size():
		new_dict[i]["Pronunciation"] = _apply(dict[i]["Pronunciation"])[0]
		
	%DictionaryContainer.reload(new_dict)

func _apply_lexicon():
	$OutputLexicon.text = "\n".join(_apply($InputLexicon.text))
