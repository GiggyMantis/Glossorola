extends RefCounted
class_name SCA
# Based on code by Mark Rosenfelder, originally written in JavaScript

@export var categories: String
@export var lexicon: String
@export var rules: String
@export var rewrite_rules: String
@export var rewrite_output := true

var rewritten_categories
var number_of_categories
var rewritten_rules
var number_of_rules
var category_index = ""

func find(s: String, ch: String) -> int:
	for i in len(s):
		if (s[i] == ch):
			return i
	return -1

func reverse(s: String) -> String:
	var r = "" 
	for i in range(len(s)-1, -1, -1):
		r += s[i]
	return r

# Take an input string, apply rewrite rules, and split results
func rewrite(s: String):
	var ret = s

	var rewrite_rules_array = rewrite_rules.split("\n")
	for rule in rewrite_rules_array:
		if len(rule) > 2 and find(rule, "|") != -1:
			var parse = rule.split("|")
			var regex = RegEx.create_from_string(parse[0])
			ret = regex.sub(ret, parse[1], true)
	return ret.split("\n")

# Take a string and apply the rewrite rules backwards
func unrewrite(s: String, rev: bool):
	if !rewrite_output:
		return s

	var ret = s
	
	var rewrite_rules_array = rewrite_rules.split("\n")

	var p1 = 0 if rev else 1
	var p2 = 1 if rev else 0

	for rule in rewrite_rules_array:
		if len(rule) > 2 and find(rule, "|") != -1:
			var parse = rule.split("|")
			var regex = RegEx.create_from_string(parse[p1])
			ret = regex.sub(ret, parse[p2], true)
	return ret

# "Read in the input fields"
# Compiles all necessary things before processing (categories, rewrite rules, etc.)
func compile() -> void:
	# Parse the category list
	rewritten_categories = rewrite(categories);
	number_of_categories = len(rewritten_categories)
	var bad_categories = false;

	# Make sure cats have structure like V=aeiou, if they exist at all
	if not categories.strip_edges(true, true).is_empty():
		category_index = "";
		for w in number_of_categories:
			# A final empty cat can be ignored
			var thiscat = rewritten_categories[w]
			if thiscat[len(thiscat) - 1] == "\n":
				thiscat = thiscat.substr(0, len(thiscat) - 1)
				rewritten_categories[w] = thiscat
				
			if len(thiscat) == 0 and w == number_of_categories - 1:
				number_of_categories -= 1
			elif len(thiscat) < 3:
				bad_categories = true
			else:
				if find(thiscat, "=") == -1:
					bad_categories = true
				else:
					category_index += thiscat[0]

	# Parse the sound changes 
	rewritten_rules = rewrite(rules)
	number_of_rules = len(rewritten_rules)
	
	# Remove trailing returns
	var w = 0
	while w < number_of_rules:
		var t = rewritten_rules[w]
		if t[len(t) - 1] == "\n":
			rewritten_rules[w] = t.substr(0, len(t) - 1)
			t = rewritten_rules[w]

		# Intermediate results marker has to stay in rules
		if (t.substr(0, 2) == '-*'):
			continue

		# Sanity checks for valid rules
		var valid = len(t) > 0 and find(t, "_") != -1
		if valid:
			var thisrule = t.replace("→","/").split("/") # Slight difference from zompist.com implementation
			valid = len(thisrule) >= 2
			if valid:
				# Insertions must have repl & nonuniversal env
				if len(thisrule[0]) == 0:
					valid = len(thisrule[1]) > 0 and thisrule[2] != "_"

		# Invalid rules: move 'em all up
		if not valid:
			number_of_rules -= 1
			for q in range(w, number_of_rules):
				rewritten_rules[q] = rewritten_rules[q + 1]
			w -= 1
		
		# For Loop is performed manually to allow for modification of w 
		w += 1
	
	# Error strings
	assert(not bad_categories, "Categories must be of the form V=aeiou \nThat is, a single letter, an equal sign, then a list of possible expansions.")
	assert(number_of_rules > 0, "There are no valid sound changes, so no output can be generated. Rules must be of the form s1/s2/e1_e2. The strings are optional, but the slashes are not.")

# Globals for Match as we don't have pass by reference
var gix
var glen = 0
var gcat

# Are we at a word boundary?
func at_space(inword: String, i, global_ix) -> bool:
	if global_ix == -1:
		# Before _ this must match beginning of word
		if i == 0 or inword[i - 1] == ' ':
			return true
	else:
		# After _ this must match end of word
		if i >= len(inword) or inword[i] == ' ':
			return true
	return false

# Does this character match directly, or via a category?
func match_char_or_cat(inwordCh, target_character) -> bool:
	var ix = find(category_index, target_character)
	if ix != -1:
		return find(rewritten_categories[ix], inwordCh) != -1
	else:
		return inwordCh == target_character

func is_target(target, inword, i) -> bool: 
	if find(target, "[") != -1:
		glen = 0
		var inbracket = false
		var foundinside = false
		for j in len(target):
			if target[j] == "[":
				inbracket = true
			elif target[j] == "]":
				if !foundinside:
					return false
				i += 1
				glen += 1
				inbracket = false
			elif inbracket:
				if i >= len(inword):
					return false
				if !foundinside:
					foundinside = target[j] == inword[i]
			else:
				if i >= len(inword):
					return false
				if target[j] != inword[i]:
					return false
				i += 1
				glen += 1
	else:
		glen = len(target)
		for k in glen:
			if i + k < len(inword):
				if match_char_or_cat(inword[i + k], target[k]) == false:
					return false
		return true
	return true

# Does this environment match this rule?
# That is, starting at inword[i], we have a substring matching env (with _ = target).
# General structure is: return false as soon as we have a mismatch.
func _match(inword, i, target, env) -> bool:
	var optional = false
	gix = -1
	# location of target

	# Advance through env.  i will change too, but not always one-for-one
	var j = 0
	while j < len(env):
		print(env[j])
		match (env[j]):
			"[":
				# Nonce category
				var found = false
				j += 1
				while j < len(env) and env[j] != "]":
					j += 1
					if found:
						continue
				var cx = find(category_index, env[j])

				if env[j] == '#':
					found = at_space(inword, i, gix)
				elif cx != -1:
					# target is a category
					if find(rewritten_categories[cx], inword[i]) != -1:
						found = true
						i += 1
				else:
					found = i < len(inword) and env[j] == inword[i]
					if found:
						i += 1
				if !found and !optional:
					return false
			'(':
				# Start optional
				optional = true
			')':
				# End optional
				optional = false
			'#':
				# Word boundary
				if not at_space(inword, i, gix):
					return false
			'²':
				# Degemination 
				if i == 0 or i >= len(inword) or inword[i] != inword[i - 1]:
					return false
				i += 1
			'…':
				# Wildcard	
				var tempgix = gix
				var tempgcat = gcat
				var tempglen = glen
				var anytrue = false

				var newenv = env.substr(j + 1, len(env) - (j) - 1)

				# This is a rule like ...V.
				# Get a new environment from what's past the wildcard.
				# We test every spot in the rest of inword against that.
				# At the first match if any, we're satisfied and leave.

				var k = i
				while k < len(inword) and anytrue == false:
					if inword[k] == ' ':
						break

					if _match(inword, k, target, newenv):
						anytrue = true
					k += 1
				if tempgix != -1:
					gix = tempgix
					gcat = tempgcat
					glen = tempglen

				return anytrue
			'_':
				# Location of target 
				gix = i
				if len(target) == 0:
					glen = 0

				if i >= len(inword):
					return false

				var ix = find(category_index, target[0])
				if ix != -1:
					# target is a category
					gcat = find(rewritten_categories[ix], inword[i])
					if gcat == -1:
						return false
					else:
						glen = 0 if len(target) == 0 else 1
						if len(target) > 1:
							var tlen = len(target) - 1
							if !is_target(target.substr(1, tlen - 1), inword, i + 1):
								return false
							glen += tlen
					i += len(target)
				else:
					if !is_target(target, inword, i):
						return false
					i += glen
			_:
				# elsewhere in the environment

				var cont = i < len(inword)
				if cont:
					cont = match_char_or_cat(inword[i], env[j])
					if cont:
						i += 1
				if not (optional or cont):
					return false
		j += 1
	return true

func category_sub(repl):
	var outs = ""
	var lastch = ""
	
	for i in len(repl):
		var ix = find(category_index, repl[i])
		if ix != -1:
			if gcat < len(rewritten_categories[ix]):
				lastch = rewritten_categories[ix][gcat]
				outs += lastch
		elif repl[i] == '²':
			outs += lastch
		else:
			lastch = repl[i]
			outs += lastch
	return outs

# Apply a single rule to this word
func apply_rule(inword: String, r: int) -> String:
	var outword = ""

	var t = rewritten_rules[r].replace('→', "/")

	# Intermediate results
	if t.substr(0, 2) == "-*":
		return inword

	# Regular rules
	var thisrule = t.split("/")

	var i = 0
	while i < len(inword) and inword[i] != '‣':
		var x = _match(inword, i, thisrule[0], thisrule[2])
		if x:
			var target = thisrule[0]
			var repl = thisrule[1]

			if len(thisrule) > 3:
				# There's an exception
				var slix = find(thisrule[3], "_")
				if slix != -1:
					var tgix = gix
					var tglen = glen
					var tgcat = gcat

					# How far before _ do we check?
					var brackets = false
					var precount = 0
					for k in slix:
						match thisrule[3][k]:
							'[':
								brackets = true
							']':
								brackets = false
							_:
								if thisrule[3][k] != "#":
									if not brackets:
										precount += 1

					if gix - precount >= 0 and _match(inword, gix - precount, thisrule[0], thisrule[3]):
						i += 1
						continue
					gix = tgix
					glen = tglen
					gcat = tgcat

			outword = inword.substr(0, gix)

			if len(repl) > 0:
				if repl == "\\\\":
					var found = inword.substr(gix, glen - gix)
					outword += reverse(found)
				elif gcat != -1:
					outword += category_sub(repl)
				else:
					outword += repl
			gix += glen
			i = len(outword)

			if len(target) == 0:
				i += 1

			outword += inword.substr(gix, len(inword) - (gix))

			inword = outword
		else:
			i += 1

	if not outword.is_empty():
		return outword
	else:
		return inword

# Transform a single word
func transform(word: String) -> String:
	var inword = word
	if len(inword) > 0:
		# Try out each rule in turn
		for r in number_of_rules:
			inword = apply_rule(inword, r)
	return inword

# Read in each word in turn from the input file,
# transform it according to the rules,
# and output it to the output file.
func do_words() -> Array[String]:
	var ret: Array[String]
	
	# Parse the input lexicon
	var rewritten_lexicon = rewrite(lexicon)
	var number_of_lexicon = len(rewritten_lexicon)

	for w in number_of_lexicon:
		var inword = rewritten_lexicon[w]

		if len(inword) > 0:
			# remove trailing blanks
			while inword[len(inword) - 1] == " ":
				inword = inword.substr(0, len(inword) - 1)
			
			if inword[len(inword) - 1] == "\n":
				inword = inword.substr(0, len(inword) - 1)

			var outword = transform(inword)
			var outs

			var parts = inword.split(" ‣")
			if len(parts) > 1:
				inword = parts[0]

			outs = outword

			ret.append(unrewrite(outs, false))
	return ret

# Compiles and applies rules
func apply() -> Array[String]: 

	compile()
	return do_words()
