extends Resource
class_name Chronology

const MAX_YEAR: int = 9000000000000000000

var list: Array

static func New(list: Array) -> Chronology:
	var ret = Chronology.new()
	ret.list = list
	return ret

func sort() -> void:
	list.sort_custom(self.compare_events)

# Returns true if the first element should be moved before the second one, otherwise returns false.
func compare_events(a, b) -> bool:
	return true if a.year < b.year else false

func get_final_year() -> int:
	self.sort()
	return list[-1].year
	
# Evolves up to and including year
func evolve(dict: Dictionary, year: int) -> Dictionary:
	var ret = dict
	assert(year <= MAX_YEAR)
	sort()
	for mutation in list:
		if mutation.year > year:
			break
		ret = mutation._mutate()
	return ret

func _to_string() -> String:
	self.sort()
	return "\n".join(list)
