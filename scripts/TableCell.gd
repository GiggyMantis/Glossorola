extends LineEdit

signal _on_submit

var column: int
var row: int

func _submit(new_text: String):
	_on_submit.emit(new_text, column, row)
