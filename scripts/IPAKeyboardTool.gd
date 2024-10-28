extends Control

# @export var shortcuts: Array[Shortcut]
var ipa_characters: Dictionary = {}

func _ready():
	var diacritic = false
	for char in "pbɓtdɗʈɖcɟʄȶȡkɡɠqɢʛʡʔmɱnɳɲȵŋɴʙⱱrɾɽʀɸβfvθðszʃʒʂʐçʝɕʑxɣχʁħʕʜʢhɦʍwɥʋɹɻjɰɬɮꞎlɫɭʎȴʟɺɧʘǀǃǂǁʦʣʧʤʨʥꭧꭦiyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔɐæɶaɑɒɚɝ˩˨˧˦˥↓↑↗↘◌̊◌̈◌̽◌̃◌͊◌͋◌̚◌ᵊ◌͡◌◌ː◌ˑ◌̆◌ʰ◌˭◌ʼ◌ⁿ◌ˡ◌ʷ◌ʲ◌ˤ◌ˠ◌ˀ◌̥◌̬◌̤◌̰◌͓◌̨◌̹◌̜◌̮◌̼◌̪◌̺◌̻◌̟◌̠◌̩◌̯◌͜◌◌̙◌̘◌̞◌̝◌̴◌˞◌̋◌́◌̄◌̀◌̏◌᷈◌᷅◌᷄◌̂◌̌ˈˌ/[]∅|‖.‿⟨⟩":
		if char == "◌":
			diacritic = true
			continue
		
		var keycap = char.replace("◌","")
		if diacritic:
			diacritic = false
			keycap = "◌" + keycap
			if char == "͡" or char == "͜":
				keycap += "◌"
				
		var dictionary
		
		# TODO: Give all non-QWERTY chars keyboard shortcuts
		# TODO: Give all of these descriptions
		
		dictionary["keycap"] = keycap
		ipa_characters[char] = dictionary
	
	for key in ipa_characters.keys():
		create_button(key, ipa_characters[key]["keycap"])
		

func create_button(char, keycap):
	var b = IPAButton.new()
	b.text = keycap
	b.char = char
	b._ipa_key_pressed.connect(_button_pressed)
	$Keyboard.add_child(b)

func _button_pressed(char, keycap):
	$TextEdit.insert_text_at_caret(char)

func _input(event):
	if not get_parent().get_child(get_parent().current_tab) == self:
		return
	if event is InputEventKey and event.is_pressed():
		var caret = Vector2i($TextEdit.get_caret_line(), $TextEdit.get_caret_column())
		$TextEdit.grab_focus()
		$TextEdit.set_caret_line(caret.x)
		$TextEdit.set_caret_column(caret.y)
