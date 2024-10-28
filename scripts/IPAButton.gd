extends Button
class_name IPAButton

signal _ipa_key_pressed

func _pressed():
	_ipa_key_pressed.emit(text)
