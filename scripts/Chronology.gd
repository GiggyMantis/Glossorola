extends Resource
class_name Chronology

const MAX_YEAR = 9223372036854775800

enum MutationType {NULL, COMMENT, IRREGULAR_PRONUNCIATION, IRREGULAR_SPELLING, IRREGULAR_INFLECTION, WORD_CREATION, WORD_DELETION, SEMANTIC_SHIFT, INFLECTION_MERGE, INFLECTION_CREATE, SYNTACTIC_SHIFT, SOUND_CHANGE, PHONOLOGICAL_REANALYSIS}

# A single event on the Chronology
class Mutation extends Resource:
	
	var mutation_type := MutationType.NULL
	var date: int
	
	static func New(year: int, mutation_type: MutationType) -> Mutation:
		var ret = Mutation.new()
		ret.mutation_type = mutation_type
		ret.date = clamp(year, 0, MAX_YEAR)
		return ret
	
	static func from_dictionary(dict: Dictionary) -> Mutation:
		return New(dict["Year"], dict["Type"])
	
	func _to_string() -> String:
		var ret = "Mutation Type: " + MutationType.keys()[mutation_type]
		return ret
	
	func _to_dictionary() -> Dictionary:
		var ret = {}
		ret["Year"] = date
		ret["Type"] = mutation_type
		return ret

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
