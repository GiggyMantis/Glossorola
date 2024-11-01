extends Resource
class_name Chronology

const MAX_YEAR: int = 9000000000000000000

static func New() -> Chronology:
	var ret = Chronology.new()
	
	return ret

static func from_dictionary(dict: Dictionary) -> Chronology:
	return New()

func get_final_year() -> int:
	return 0

func _to_string() -> String:
	return ""
	
func _to_dictionary() -> Dictionary:
	return {}
