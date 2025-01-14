// Adds some modular languages to tongue languages
/obj/item/organ/internal/tongue

/obj/item/organ/internal/tongue/get_possible_languages()
	return ..() + list(
		/datum/language/isatoa,
		/datum/language/ratvarian,
		/datum/language/skrell,
		/datum/language/yangyu,
	)

// Skrell Tongue. Could use a sprite.
/obj/item/organ/internal/tongue/skrell
	name = "skrellian tongue"
	desc = "The source of the Skrellian people's warbling voice."
	say_mod = "warbles"
	languages_native = /datum/language/skrell
	liked_foodtypes = VEGETABLES | FRUIT
	disliked_foodtypes = GROSS
	toxic_foodtypes = MEAT | RAW | DAIRY | TOXIC | SEAFOOD

/obj/item/organ/internal/tongue/skrell/get_possible_languages()
	return ..() + /datum/language/skrell

/obj/item/organ/internal/tongue/ornithid
	name = "avian tongue"
	desc = "A seemingly normal looking tongue which causes ones voice to caw. However that works."
	say_mod = "caws"
	liked_foodtypes = FRUIT | SEAFOOD | NUTS | BUGS // birds like dice(d) nuts. Also bugs.
	disliked_foodtypes = DAIRY | CLOTH | GROSS
	toxic_foodtypes = SUGAR // chocolate is toxic to birds.

// High Draconic for lizard tongues
/obj/item/organ/internal/tongue/lizard
	languages_native = list(/datum/language/draconic, /datum/language/impdraconic)

/obj/item/organ/internal/tongue/lizard/get_possible_languages()
	return ..() + /datum/language/impdraconic

/obj/item/organ/internal/tongue/werewolf
	name = "wolf tongue"
	desc = "A large tongue that looks like a mix of a human's and a wolf's."
	icon_state = "werewolf_tongue"
	icon = 'maplestation_modules/icons/mob/mutant_bodyparts.dmi'
	say_mod = "growls"
	modifies_speech = TRUE
	taste_sensitivity = 5
	liked_foodtypes = GROSS | MEAT | RAW | GORE
	disliked_foodtypes = SUGAR

/obj/item/organ/internal/tongue/werewolf/modify_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")

		// all occurrences of characters "eiou" (case-insensitive) are replaced with "r"
		message = replacetext(message, regex(@"[eiou]", "ig"), "r")
		// all characters other than "zhrgbmna .!?-" (case-insensitive) are stripped
		message = replacetext(message, regex(@"[^zhrgbmna.!?-\s]", "ig"), "")
		// multiple spaces are replaced with a single (whitespace is trimmed)
		message = replacetext(message, regex(@"(\s+)", "g"), " ")

		var/list/old_words = splittext(message, " ")
		var/list/new_words = list()
		for(var/word in old_words)
			// lower-case "r" at the end of words replaced with "rh"
			word = replacetext(word, regex(@"\lr\b"), "rh")
			// an "a" or "A" by itself will be replaced with "hra"
			word = replacetext(word, regex(@"\b[Aa]\b"), "hra")
			new_words += word

		message = new_words.Join(" ")
		message = capitalize(message)
		speech_args[SPEECH_MESSAGE] = message
