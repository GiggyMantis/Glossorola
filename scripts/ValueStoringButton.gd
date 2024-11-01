extends Button
class_name ValueStoringButton

signal _pressed_get_value
signal _pressed_get_text
signal _pressed_get_text_and_value
var value

func _pressed():
	_pressed_get_value.emit(value)
	_pressed_get_text.emit(text)
	_pressed_get_text_and_value.emit(text, value)
