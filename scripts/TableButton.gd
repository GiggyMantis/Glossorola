extends Button

signal _button_pressed

var represents: Variant

func _pressed():
	_button_pressed.emit(represents)
