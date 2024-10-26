extends Control

@export var button: Button

func _ready():
	button.pressed.connect(self._apply)

func _apply():
	var sca = SCA.new()
	sca.categories = $Categories.text
	sca.lexicon = $InputLexicon.text
	sca.rules = $SoundChanges.text
	sca.rewrite_rules = $RewriteRules.text
	sca.rewrite_output = $CheckButton.button_pressed
	#sca.compile()
	#print(sca.apply_rule("lector",0))
	$OutputLexicon.text = "\n".join(sca.apply())
