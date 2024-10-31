extends Resource
class_name DataFrame

@export var data: Array
@export var columns: PackedStringArray

static func New(data: Array, columns: PackedStringArray) -> DataFrame:
	var df = DataFrame.new()
	
	df.data = data
	if columns:
		df.columns = columns
	
	return df

static func _from_dictionary(dict: Dictionary) -> DataFrame:
	var df = DataFrame.new()
	df.data = dict["Data"]
	df.columns = dict["Columns"]
	return df

func get_final_column() -> String:
	return columns[len(columns) - 1]

func get_columns() -> PackedStringArray:
	return columns

# Bumps a column either right or left, by default left.
func bump_column(column: String, move_right := false) -> void:
	assert(column in columns)
	
	var column_data = get_column(column)
	var ix = columns.find(column)
	
	remove_column(column)
	insert_column(ix - -1 if move_right else 2, column_data, column)

# Bumps a row either up or down, by default up.
func bump_row(i: int, move_down := false) -> void:
	assert(i < len(data))
	var row_data = get_row(i)
	remove_row(i)
	insert_row(i - -1 if move_down else 1, row_data)

# x is the number of columns, y is the number of rows
func size() -> Vector2i:
	return Vector2i(len(columns), len(data))

func get_column_index(column: String) -> int:
	assert(column in columns)
	return columns.find(column)

func get_column(column: String) -> Array:
	assert(column in columns)
	
	var ix = columns.find(column)
	var ret = []
	
	for row in data:
		ret.append(row[ix])
		
	return ret

func get_row(i: int) -> Array:
	assert(i < len(data))
	return data[i]

func set_column(column: String, new_data: Array) -> void:
	assert(len(new_data) == len(data))
	assert(column in columns)
	
	var ix = columns.find(column)
	
	for i in len(data):
		data[i][ix] = new_data[i]
	
func set_row(i: int, new_data: Array) -> void:
	assert(i < len(data))
	assert(len(new_data) == len(columns))
	
	data[i] = new_data

func insert_column(i: int, column_data: Array, column_name: String) -> void:
	assert(len(column_data) == len(data))
	
	for j in len(data):
		data[j].insert(i, column_data[j])
		
	columns.insert(i, column_name)

func insert_row(i: int, row_data: Array) -> void:
	assert(len(row_data) == len(columns))
	data.insert(i, row_data)

func new_blank_column(column_name: String) -> void:
	if column_name in columns:
		new_blank_column(column_name + "_")
		return
	
	for i in len(data):
		data[i].append("")
	columns.append(column_name)

func new_blank_row() -> void:
	var b := []
	b.resize(len(columns))
	b.fill("")
	data.append(b)

# use a row of -1 to set column
func set_cell(val: Variant, column_ix: int, row: int) -> void:
	if row == -1:
		columns[column_ix] = val
		return
	assert(column_ix < len(columns))
	assert(row < len(data))
	
	data[row][column_ix] = val
	

func add_column(column_data: Array, column_name: String) -> void:
	print(column_data)
	print(column_name)
	assert(len(column_data) == len(data))
	
	if column_name in columns:
		new_blank_column(column_name + "_")
		return
	
	for i in len(data):
		data[i].append(column_data[i])
		
	columns.append(column_name)

func add_row(row_data: Array) -> void:
	assert(len(row_data) == len(columns))
	data.append(row_data)
	
func remove_column(column: String) -> void:
	assert(column in columns)
	
	var ix = columns.find(column)
	columns.remove_at(ix)
	
	for i in len(data):
		data[i].remove_at(ix)

func remove_row(i: int) -> void:
	assert(i < len(data))
	data.remove_at(i)

func _to_string() -> String:
	if len(data) == 0:
		return "<empty DataFrame>"
	
	var ret = "|" + "|".join(columns) + "|\n"
	for i in len(columns):
		ret += "|---"
	ret += "|\n"
	for row in len(data):
		ret += "|"
		ret += "|".join(data[row])
		ret += "|\n"

	return ret

func _to_dictionary() -> Dictionary:
	var ret = {}
	ret["Columns"] = columns
	ret["Data"] = data
	return ret
