class_name SCA

func apply(lexicon: String, rules: String, categories: String, rewrite_rules: String, apply_rewrite_rules_on_output: bool) -> String:
	var ret = lexicon
	ret = rewrite(ret, rewrite_rules, false)
	
	if apply_rewrite_rules_on_output:
		ret = rewrite(ret, rewrite_rules, true)
	return ret
	
func rewrite(s: String, rules: String, reverse: bool) -> String:
	var ret = s
	return ret
