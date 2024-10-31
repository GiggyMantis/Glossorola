extends Control

@onready var table_row = preload("res://scenes/table/table_row.tscn")
@onready var table_cell = preload("res://scenes/table/table_cell.tscn")
@onready var table_header_cell = preload("res://scenes/table/table_header_cell.tscn")
@onready var table_delete_button = preload("res://scenes/table/table_delete_button.tscn")
@onready var table_add_button = preload("res://scenes/table/table_add_button.tscn")

@export var data: DataFrame
@export var editable := false

func _edit_cell(s: Variant, column: int, row: int):
	data.set_cell(s, column, row)

func _add_button(represented):
	if represented is String: # Columns
		data.new_blank_column("new")
	else: # Rows
		data.new_blank_row()
	render()

func _delete_button(represented):
	if represented is String: # Columns
		if data.size().x > 1:
			data.remove_column(represented)
	else: # Rows
		if data.size().y > 1:
			data.remove_row(represented)
	render()

func render():
	for child in $Rows.get_children():
		child.queue_free()
	
	assert(data)
	
	var header = table_row.instantiate()
	for column in data.get_columns():
		var cell = table_header_cell.instantiate()
		cell.text = str(column)
		cell.editable = self.editable
		cell.text_changed.connect(cell._submit)
		cell._on_submit.connect(self._edit_cell)
		cell.column = data.get_column_index(column)
		cell.row = -1
		if editable:
			var delete_button = table_delete_button.instantiate()
			delete_button.represents = str(column)
			delete_button._button_pressed.connect(self._delete_button)
			cell.add_child(delete_button)
			if column == data.get_final_column():
				var add_button = table_add_button.instantiate()
				add_button.represents = str(column)
				add_button._button_pressed.connect(self._add_button)
				add_button.anchor_left = 1.0
				add_button.offset_left = -31
				add_button.offset_right = 0
				cell.add_child(add_button)
		header.add_child(cell)
	$Rows.add_child(header)
	
	var row_count = data.size().y
	for r in row_count:
		var row = table_row.instantiate()
		$Rows.add_child(row)
		
		for i in len(data.get_row(r)):
			var cell = table_cell.instantiate()
			cell.text = str(data.get_row(r)[i])
			cell.editable = self.editable
			cell.text_changed.connect(cell._submit)
			cell._on_submit.connect(self._edit_cell)
			cell.column = i
			cell.row = r
			if editable and i == 0:
				var delete_button = table_delete_button.instantiate()
				delete_button.represents = r
				delete_button._button_pressed.connect(self._delete_button)
				cell.add_child(delete_button)
				if r == data.size().y - 1:
					var add_button = table_add_button.instantiate()
					add_button.represents = r
					add_button._button_pressed.connect(self._add_button)
					cell.add_child(add_button)
			row.add_child(cell)
		
	if not editable:
		return
	
	
