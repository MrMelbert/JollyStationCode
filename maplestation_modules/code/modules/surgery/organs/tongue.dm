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
/obj/item/organ/internal/tongue/high_skrell
	name = "High Skrellian tongue"
	desc = "The source of the High Skrellian people's warbling voice."
	say_mod = "warbles"
	languages_native = /datum/language/skrell
	liked_foodtypes = VEGETABLES | FRUIT | SUGAR
	disliked_foodtypes = FRIED | GRAIN | BUGS
	toxic_foodtypes = MEAT | RAW | DAIRY | GROSS | GORE | TOXIC

/obj/item/organ/internal/tongue/high_skrell/get_possible_languages()
	return ..() + /datum/language/skrell

/obj/item/organ/internal/tongue/deep_skrell
	name = "Deep Skrellian tongue"
	desc = "The source of the Deep Skrellian people's warbling voice."
	say_mod = "warbles"
	languages_native = /datum/language/skrell
	liked_foodtypes = MEAT | SEAFOOD | GORE | RAW | BUGS
	disliked_foodtypes = SUGAR | FRIED | NUTS
	toxic_foodtypes = FRUIT | TOXIC | DAIRY | GROSS

/obj/item/organ/internal/tongue/deep_skrell/get_possible_languages()
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
