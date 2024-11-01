extends Resource
class_name Mutation

enum MutationType {NULL, COMMENT, IRREGULAR_PRONUNCIATION, IRREGULAR_SPELLING, IRREGULAR_INFLECTION, WORD_CREATION, WORD_DELETION, SEMANTIC_SHIFT, INFLECTION_MERGE, INFLECTION_CREATE, SYNTACTIC_SHIFT, SOUND_CHANGE, PHONOLOGICAL_REANALYSIS}

var year: int
var value: Variant

static func _new(year: int, value):
	var ret = Mutation.new()
	ret.year = clamp(year, 0, Chronology.MAX_YEAR)
	ret.value = value
	return ret

static func from_dictionary(dict: Dictionary):
	match dict["Type"] as MutationType:
		_:
			return _new(dict["Year"], dict["x"])
	return _new(dict["Year"], dict["x"])	

func _mutate(input: Dictionary) -> Dictionary:
	return input

func _mutation_type() -> MutationType:
	return MutationType.NULL

func _to_string() -> String:
	var year_abbrv = TranslationServer.translate(&"YEAR_ABBREVIATION") as String
	return year_abbrv + " " + str(year) + ": <blank mutation>"

func _to_dictionary() -> Dictionary:
	var ret = {}
	ret["Year"] = year
	ret["x"] = value
	ret["Type"] = _mutation_type()
	return ret

class CommentMutation extends Mutation:
	static func _new(year: int, value: String):
		var ret = CommentMutation.new()
		ret.year = clamp(year, 0, Chronology.MAX_YEAR)
		ret.value = value
		return ret
	
	func _mutation_type() -> MutationType:
		return MutationType.COMMENT
	
	func _to_string() -> String:
		var year_abbrv = TranslationServer.translate(&"YEAR_ABBREVIATION") as String
		return year_abbrv + " " + str(year) + ": \"" + value + "\""

class WordCreationMutation extends Mutation:
	static func _new(year: int, value: DictionaryContainer.Word):
		var ret = WordCreationMutation.new()
		ret.year = clamp(year, 0, Chronology.MAX_YEAR)
		ret.value = value
		return ret
	
	func _mutation_type() -> MutationType:
		return MutationType.WORD_CREATION
	
	func _to_string() -> String:
		var year_abbrv = TranslationServer.translate(&"YEAR_ABBREVIATION") as String
		var new_word = TranslationServer.translate(&"NEW_WORD_MUTATION") as String
		return year_abbrv + " " + str(year) + ": " + new_word + " " + str(value)
