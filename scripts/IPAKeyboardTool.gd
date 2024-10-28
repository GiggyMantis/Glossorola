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
	$TextEdit.text += c.replace("◌","")
