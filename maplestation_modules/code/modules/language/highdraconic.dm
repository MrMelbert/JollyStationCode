/// -- High draconic language. It's like Draconic, but more posh. --
// Credit to EOBgames for the initial syllables list / concept, changed and adapted for use.

/datum/language/impdraconic
	name = "Tiziran Draconic"
	desc = "A distinct dialect of Draconic common to lizards born and raised on Tizira."
	key = "l"
	flags = TONGUELESS_SPEECH
	space_chance = 25
	syllables = list(
		"ta", "te", "ti", "to", "tu", "ez", "la", "ro", "fe", "ss", "es", "me", "da",
		"ra", "re", "ri", "ll", "as", "fa", "mer", "za", "ze", "ssa", "ko", "ka", "de",
		"ba", "be", "ma", "bi", "sk", "hi", "hs", "ke", "ssi", "le", "mo", "is", "ek", "a",
		"e", "i", "o", "u", "u", "ru", "sa", "sr", "rs", "us"
	)
	icon = 'maplestation_modules/icons/misc/language.dmi'
	icon_state = "lizardred"
	default_priority = 85

// So I wrote a few unit tests for /tg/ that rely on Lizards not knowing what high draconic is.
// And since rewriting them is out of the questions, Lizards don't know high draconic in unit tests.
#ifndef UNIT_TESTS

// Edit to the base lizard language holder - lizards can understand high draconic.
/datum/language_holder/lizard
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/impdraconic = list(LANGUAGE_ATOM),
	)

#endif

// Edit to the silverscale language holder - silverscales can speak high draconic.
/datum/language_holder/lizard/silver
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/impdraconic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/impdraconic = list(LANGUAGE_ATOM),
	)
	selected_language = /datum/language/uncommon

/datum/language_holder/lizard/ash/primative
	selected_language = /datum/language/impdraconic
	understood_languages = list(
		/datum/language/impdraconic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/impdraconic = list(LANGUAGE_ATOM),
	)
