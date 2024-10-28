extends Button
class_name IPAButton

signal _ipa_key_pressed

var char

func _pressed():
	_ipa_key_pressed.emit(char, text)
