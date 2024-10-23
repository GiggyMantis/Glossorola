class_name SCA

static func apply(lexicon: String, rules: String, categories: String, rewrite_rules: String, apply_rewrite_rules_on_output: bool) -> String:
	var ret = lexicon
	ret = rewrite(ret, rewrite_rules, false)
	
	if apply_rewrite_rules_on_output:
		ret = rewrite(ret, rewrite_rules, true)
	return ret
	
static func rewrite(s: String, rules: String, reverse: bool) -> String:
	
	var rules_array = rules.split("\n")
	var replacement_left: Array[String]
	var replacement_right: Dictionary
	for rule in rules_array:
		var rule_individual = rule.split("|")
		if not reverse:
			replacement_left.append(rule_individual[0])
			replacement_right[rule_individual[0]] = (rule_individual[1])
		else:
			replacement_left.append(rule_individual[1])
			replacement_right[rule_individual[1]] = (rule_individual[0])
	
	if reverse:
		replacement_left.reverse()
	
	var ret = s
	for rule in replacement_left:
		ret = ret.replace(rule, replacement_right[rule])
	
	return ret

static func categories_to_dictionary(categories: String) -> Dictionary:
	var ret: Dictionary
	var categories_array = categories.split("\n")
	for category in categories_array:
		var category_split = category.replace(" = ", "=").split("=")
		if category_split[1].contains(" "):
			ret[category_split[0]] = category_split[1].split(" ")
		else:
			ret[category_split[0]] = category_split[1].split("")
	return ret
