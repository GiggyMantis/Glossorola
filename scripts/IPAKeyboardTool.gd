extends Control

@export var convert_xsampa_button: Button

const XSAMPA := {"_":"͡","<":"⟨",">":"⟩","=":"̩","`":"˞","b_<":"ɓ","d`":"ɖ","d_<":"ɗ","g":"ɡ","g_<":"ɠ","h\\":"ɦ","j\\":"ʝ","l`":"ɭ","l\\":"ɺ","n`":"ɳ","p\\":"ɸ","r`":"ɽ","r\\":"ɹ","r\\`":"ɻ","s`":"ʂ","s\\":"ɕ","t`":"ʈ","v\\":"ʋ","x\\":"ɧ","z`":"ʐ","z\\":"ʑ","A":"ɑ","B":"β","B\\":"ʙ","C":"ç","D":"ð","E":"ɛ","F":"ɱ","G":"ɣ","G\\":"ɢ","G\\_<":"ʛ","H":"ɥ","H\\":"ʜ","I":"ɪ","I\\":"ɨ̞","J":"ɲ","J\\":"ɟ","J\\_<":"ʄ","K":"ɬ","K\\":"ɮ","L":"ʎ","L\\":"ʟ","M":"ɯ","M\\":"ɰ","N":"ŋ","N\\":"ɴ","O":"ɔ","O\\":"ʘ","P":"ʋ","Q":"ɒ","R":"ʁ","R\\":"ʀ","S":"ʃ","T":"θ","U":"ʊ","U\\":"ʉ̞","V":"ʌ","W":"ʍ","X":"χ","X\\":"ħ","Y":"ʏ","Z":"ʒ","\"":"ˈ","%":"ˌ","\'":"ʲ",":":"ː",":\\":"ˑ","@":"ə","@\\":"ɘ","@`":"ɚ","{":"æ","}":"ʉ","1":"ɨ","2":"ø","3":"ɜ","3\\":"ɞ","4":"ɾ","5":"ɫ","6":"ɐ","7":"ɤ","8":"ɵ","9":"œ","&":"ɶ","?":"ʔ","?\\":"ʕ","<\\":"ʢ",">\\":"ʡ","^":"ꜛ","!":"ꜜ","!\\":"ǃ","|":"|","|\\":"ǀ","||":"‖","|\\|\\":"ǁ","=\\":"ǂ","-\\":"‿","_\"":"̈","_+":"̟","_-":"̠","_/":"̌","_0":"̥","_=":"̩","_>":"ʼ","_?\\":"ˤ","_\\":"̂","_^":"̯","_}":"̚","~":"̃","_~":"̃","_A":"̘","_a":"̺","_B":"̏","_L":"̀","_B_L":"᷅","_c":"̜","_d":"̪","_e":"̴","<F>":"↘","_F":"̂","_G":"ˠ","_H":"́","_T":"̋","_H_T":"᷄","_h":"ʰ","_j":"ʲ","_k":"̰","_l":"ˡ","_M":"̄","_m":"̻","_N":"̼","_n":"ⁿ","_O":"̹","_o":"̞","_q":"̙","<R>":"↗","_R":"̌","_R_F":"᷈","_r":"̝","_t":"̤","_v":"̬","_w":"ʷ","_X":"̆","_x":"̽"}
const IPA_CHARS := "pbɓtdɗʈɖcɟʄȶȡkɡɠqɢʛʡʔmɱnɳɲȵŋɴʙⱱrɾɽʀɸβfvθðszʃʒʂʐçʝɕʑxɣχʁħʕʜʢhɦʍwɥʋɹɻjɰɬɮꞎlɫɭʎȴʟɺɧʘǀǃǂǁʦʣʧʤʨʥꭧꭦiyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔɐæɶaɑɒɚɝ˩˨˧˦˥↓↑↗↘◌̊◌̈◌̽◌̃◌͊◌͋◌̚◌ᵊ◌͡◌◌ː◌ˑ◌̆◌ʰ◌˭◌ʼ◌ⁿ◌ˡ◌ʷ◌ʲ◌ˤ◌ˠ◌ˀ◌̥◌̬◌̤◌̰◌͓◌̨◌̹◌̜◌̮◌̼◌̪◌̺◌̻◌̟◌̠◌̩◌̯◌͜◌◌̙◌̘◌̞◌̝◌̴◌˞◌̋◌́◌̄◌̀◌̏◌᷈◌᷅◌᷄◌̂◌̌ˈˌ/[]∅|‖.‿⟨⟩"

# @export var shortcuts: Array[Shortcut]
var ipa_characters: Dictionary = {}

func _convert_xsampa():
	var text = $TextEdit.text
	for key in XSAMPA.keys():
		text = text.replace(key, XSAMPA[key])
	$TextEdit.text = text
			

func _ready():
	
	convert_xsampa_button.pressed.connect(self._convert_xsampa)
	
	var diacritic = false
	for char in IPA_CHARS:
		if char == "◌":
			diacritic = true
			continue
		
		var keycap = char.replace("◌","")
		if diacritic:
			diacritic = false
			keycap = "◌" + keycap
			if char == "͡" or char == "͜":
				keycap += "◌"
				
		var dictionary = {}
		
		# TODO: Give all non-QWERTY chars keyboard shortcuts
		# TODO: Give all of these descriptions
		
		dictionary["keycap"] = keycap
		ipa_characters[char] = dictionary
	
	for key in ipa_characters.keys():
		create_button(key, ipa_characters[key]["keycap"])
		

func create_button(char, keycap):
	var b = ValueStoringButton.new()
	b.text = keycap
	b.char = char
	b._pressed_get_text_and_value.connect(_button_pressed)
	$Keyboard.add_child(b)

func _button_pressed(keycap, char):
	$TextEdit.insert_text_at_caret(char)

func _input(event):
	if not get_parent().get_child(get_parent().current_tab) == self:
		return
	if event is InputEventKey and event.is_pressed():
		var caret = Vector2i($TextEdit.get_caret_line(), $TextEdit.get_caret_column())
		$TextEdit.grab_focus()
		$TextEdit.set_caret_line(caret.x)
		$TextEdit.set_caret_column(caret.y)
