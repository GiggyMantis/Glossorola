extends Control

const IPA_CHARACTERS = "
pbɓtdɗʈɖcɟʄȶȡkɡɠqɢʛʡʔmɱnɳɲȵŋɴʙⱱrɾɽʀɸβfvθðszʃʒʂʐçʝɕʑxɣχʁħʕʜʢhɦʍwɥʋɹɻjɰɬɮꞎlɫɭʎȴʟɺɧʘǀǃǂǁʦʣʧʤʨʥꭧꭦ
iyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔɐæɶaɑɒɚɝ
˩˨˧˦˥↓↑↗↘
◌̊◌̈◌̽◌̃◌͊◌͋◌̚◌ᵊ◌͡◌◌ː◌ˑ◌̆◌ʰ◌˭◌ʼ◌ⁿ◌ˡ◌ʷ◌ʲ◌ˤ◌ˠ◌ˀ◌̥◌̬◌̤◌̰◌͓◌̨◌̹◌̜◌̮◌̼◌̪◌̺◌̻◌̟◌̠◌̩◌̯◌͜◌◌̙◌̘◌̞◌̝◌̴◌˞◌̋◌́◌̄◌̀◌̏◌᷈◌᷅◌᷄◌̂◌̌
ˈˌ/[]∅|‖.‿⟨⟩
"

func _ready():
	
	var diacritic = false
	for char in IPA_CHARACTERS:
		# Ignore whitespace chars
		if char.strip_edges(true, true).is_empty():
			continue
		
		if char == "◌":
			diacritic = true
			continue
		
		if diacritic:
			diacritic = false
			if char == "͡" or char == "͜":
				create_button("◌" + char + "◌")
				continue
			create_button("◌" + char)
		else:
			create_button(char)
		

func create_button(c: String):
	var b = IPAButton.new()
	b.text = c
	b._ipa_key_pressed.connect(_button_pressed)
	$Keyboard.add_child(b)

func _button_pressed(c: String):
	$TextEdit.insert_text_at_caret(c.replace("◌",""))

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var caret = Vector2i($TextEdit.get_caret_line(), $TextEdit.get_caret_column())
		$TextEdit.grab_focus()
		$TextEdit.set_caret_line(caret.x)
		$TextEdit.set_caret_column(caret.y)
