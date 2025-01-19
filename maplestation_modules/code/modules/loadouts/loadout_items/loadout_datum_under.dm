// --- Loadout item datums for under suits ---

/// Underslot - Jumpsuit Items (Deletes overrided items)
/datum/loadout_category/undersuit
	category_name = "Jumpsuit"
	type_to_generate = /datum/loadout_item/under/jumpsuit
	tab_order = 7

/// Underslot - Formal Suit Items (Deletes overrided items)
/datum/loadout_category/undersuit/formal
	category_name = "Formal"
	type_to_generate = /datum/loadout_item/under/formal
	tab_order = 8

/datum/loadout_item/under
	abstract_type = /datum/loadout_item/under

/datum/loadout_item/under/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE, job_equipping_step = FALSE)
	if(isplasmaman(equipper))
		if(!visuals_only)
			to_chat(equipper, "Your loadout uniform was not equipped directly due to your envirosuit.")
			LAZYADD(outfit.backpack_contents, item_path)
	else
		outfit.uniform = item_path

// jumpsuit undersuits
/datum/loadout_item/under/jumpsuit
	abstract_type = /datum/loadout_item/under/jumpsuit

/datum/loadout_item/under/jumpsuit/greyscale
	name = "Greyscale Jumpsuit"
	item_path = /obj/item/clothing/under/color/greyscale

/datum/loadout_item/under/jumpsuit/greyscale_skirt
	name = "Greyscale Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt/greyscale

/datum/loadout_item/under/jumpsuit/random
	name = "Random Jumpsuit"
	can_be_greyscale = DONT_GREYSCALE
	item_path = /obj/item/clothing/under/color/random
	additional_displayed_text = list("Random Color")

/datum/loadout_item/under/jumpsuit/random/on_equip_item(
	obj/item/equipped_item,
	datum/preferences/preference_source,
	list/preference_list,
	mob/living/carbon/human/equipper,
	visuals_only = FALSE,
)
	return NONE // acts funky

/datum/loadout_item/under/jumpsuit/random/skirt
	name = "Random Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt/random

/datum/loadout_item/under/jumpsuit/rainbow
	name = "Rainbow Jumpsuit"
	item_path = /obj/item/clothing/under/color/rainbow

/datum/loadout_item/under/jumpsuit/rainbow_skirt
	name = "Rainbow Jumpskirt"
	item_path = /obj/item/clothing/under/color/jumpskirt/rainbow

/datum/loadout_item/under/jumpsuit/jeans
	name = "Jeans"
	item_path = /obj/item/clothing/under/pants/jeans

/datum/loadout_item/under/jumpsuit/shorts
	name = "Shorts"
	item_path = /obj/item/clothing/under/shorts

/datum/loadout_item/under/jumpsuit/track
	name = "Track Pants"
	item_path = /obj/item/clothing/under/pants/track

/datum/loadout_item/under/jumpsuit/camo
	name = "Camo Pants"
	item_path = /obj/item/clothing/under/pants/camo

/datum/loadout_item/under/jumpsuit/kilt
	name = "Kilt"
	item_path = /obj/item/clothing/under/costume/kilt

/datum/loadout_item/under/jumpsuit/gladiator
	name = "Gladiator Armor"
	item_path = /obj/item/clothing/under/costume/gladiator/loadout

/datum/loadout_item/under/jumpsuit/treasure_hunter
	name = "Treasure Hunter"
	item_path = /obj/item/clothing/under/rank/civilian/curator/treasure_hunter

/datum/loadout_item/under/jumpsuit/overalls
	name = "Overalls"
	item_path = /obj/item/clothing/under/misc/overalls

/datum/loadout_item/under/jumpsuit/pj_blue
	name = "Mailman Jumpsuit"
	item_path = /obj/item/clothing/under/misc/mailman

/datum/loadout_item/under/jumpsuit/vice_officer
	name = "Vice Officer Jumpsuit"
	item_path = /obj/item/clothing/under/misc/vice_officer

/datum/loadout_item/under/jumpsuit/soviet
	name = "Soviet Uniform"
	item_path = /obj/item/clothing/under/costume/soviet

/datum/loadout_item/under/jumpsuit/redcoat
	name = "Redcoat"
	item_path = /obj/item/clothing/under/costume/redcoat

/datum/loadout_item/under/jumpsuit/pj_red
	name = "Red PJs"
	item_path = /obj/item/clothing/under/misc/pj/red

/datum/loadout_item/under/jumpsuit/pj_blue
	name = "Blue PJs"
	item_path = /obj/item/clothing/under/misc/pj/blue

/datum/loadout_item/under/jumpsuit/hoodie
	name = "Workout Hoodie"
	item_path = /obj/item/clothing/under/jumpsuit/casualhoodie

/datum/loadout_item/under/jumpsuit/casualdress
	name = "Casual Dress"
	item_path = /obj/item/clothing/under/jumpsuit/blueskirt

/datum/loadout_item/under/jumpsuit/albertshirt
	name = "Deep Red Shirt"
	item_path = /obj/item/clothing/under/jumpsuit/albertshirt

/datum/loadout_item/under/jumpsuit/spacer_uniform
	name = "Spacer's Uniform"
	item_path = /obj/item/clothing/under/spacer_turtleneck/plain

/datum/loadout_item/under/jumpsuit/spacer_turtleneck
	name = "Spacer's Turtleneck"
	item_path = /obj/item/clothing/under/spacer_turtleneck

/datum/loadout_item/under/jumpsuit/spacer_uniform_skirt
	name = "Spacer's Skirt"
	item_path = /obj/item/clothing/under/spacer_turtleneck/skirt/plain

/datum/loadout_item/under/jumpsuit/spacer_turtleneck_skirt
	name = "Spacer's Skirtleneck"
	item_path = /obj/item/clothing/under/spacer_turtleneck/skirt

// formal undersuits
/datum/loadout_item/under/formal
	abstract_type = /datum/loadout_item/under/formal

/datum/loadout_item/under/formal/assistant
	name = "Assistant Formal"
	item_path = /obj/item/clothing/under/misc/assistantformal

/datum/loadout_item/under/formal/beige_suit
	name = "Beige Suit"
	item_path = /obj/item/clothing/under/suit/beige

/datum/loadout_item/under/formal/black_suit
	name = "Black Suit"
	item_path = /obj/item/clothing/under/suit/black

/datum/loadout_item/under/formal/executive_suit_alt
	name = "Beige and Blue Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/beige

/datum/loadout_item/under/formal/executive_skirt_alt
	name = "Beige and Blue Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/beige/skirt

/datum/loadout_item/under/formal/black_suitskirt
	name = "Black Suitskirt"
	item_path = /obj/item/clothing/under/suit/black/skirt

/datum/loadout_item/under/formal/tango
	name = "Tango Dress"
	item_path = /obj/item/clothing/under/dress/tango

/datum/loadout_item/under/formal/black_lawyer_suit
	name = "Black Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/black

/datum/loadout_item/under/formal/black_lawyer_skirt
	name = "Black Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/black/skirt

/datum/loadout_item/under/formal/blue_suit
	name = "Blue Button Down with Slacks"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit

/datum/loadout_item/under/formal/blue_suitskirt
	name = "Blue Button Down with Skirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit/skirt

/datum/loadout_item/under/formal/blue_lawyer_suit
	name = "Blue Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/blue

/datum/loadout_item/under/formal/blue_lawyer_skirt
	name = "Blue Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/blue/skirt

/datum/loadout_item/under/formal/burgundy_suit
	name = "Burgundy Suit"
	item_path = /obj/item/clothing/under/suit/burgundy

/datum/loadout_item/under/formal/buttondown_slacks
	name = "Button Down with Slacks"
	item_path = /obj/item/clothing/under/costume/buttondown/slacks

/datum/loadout_item/under/formal/buttondown_shorts
	name = "Button Down with Shorts"
	item_path = /obj/item/clothing/under/costume/buttondown/shorts

/datum/loadout_item/under/formal/charcoal_suit
	name = "Charcoal Suit"
	item_path = /obj/item/clothing/under/suit/charcoal

/datum/loadout_item/under/formal/checkered_suit
	name = "Checkered Suit"
	item_path = /obj/item/clothing/under/suit/checkered

/datum/loadout_item/under/formal/executive_suit
	name = "Executive Suit"
	item_path = /obj/item/clothing/under/suit/black_really

/datum/loadout_item/under/formal/executive_skirt
	name = "Executive Suitskirt"
	item_path = /obj/item/clothing/under/suit/black_really/skirt

/datum/loadout_item/under/formal/green_suit
	name = "Green Suit"
	item_path = /obj/item/clothing/under/suit/green

/datum/loadout_item/under/formal/skirt_greyscale
	name = "Greyscale Skirt"
	item_path = /obj/item/clothing/under/dress/skirt

/datum/loadout_item/under/formal/plaid_skirt_greyscale
	name = "Greyscale Plaid Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/plaid

/datum/loadout_item/under/formal/navy_suit
	name = "Navy Suit"
	item_path = /obj/item/clothing/under/suit/navy

/datum/loadout_item/under/formal/maid_outfit
	name = "Maid Outfit"
	item_path = /obj/item/clothing/under/costume/maid

/datum/loadout_item/under/formal/maid_uniform
	name = "Maid Uniform"
	item_path = /obj/item/clothing/under/rank/civilian/janitor/maid

/datum/loadout_item/under/formal/purple_suit
	name = "Purple Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit

/datum/loadout_item/under/formal/purple_suitskirt
	name = "Purple Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/purpsuit/skirt

/datum/loadout_item/under/formal/red_lawyer
	name = "Red Lawyer Suit"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/red

/datum/loadout_item/under/formal/red_lawyer_skirt
	name = "Red Lawyer Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/lawyer/red/skirt

/datum/loadout_item/under/formal/red_gown
	name = "Red Evening Gown"
	item_path = /obj/item/clothing/under/dress/redeveninggown

/datum/loadout_item/under/formal/sailor
	name = "Sailor Suit"
	item_path = /obj/item/clothing/under/costume/sailor

/datum/loadout_item/under/formal/sailor_skirt
	name = "Sailor Dress"
	item_path = /obj/item/clothing/under/dress/sailor

/datum/loadout_item/under/formal/striped_skirt
	name = "Striped Dress"
	item_path = /obj/item/clothing/under/dress/striped

/datum/loadout_item/under/formal/sensible_suit
	name = "Sensible Suit"
	item_path = /obj/item/clothing/under/rank/civilian/curator

/datum/loadout_item/under/formal/sensible_skirt
	name = "Sensible Suitskirt"
	item_path = /obj/item/clothing/under/rank/civilian/curator/skirt

/datum/loadout_item/under/formal/sundress
	name = "Sundress"
	item_path = /obj/item/clothing/under/dress/sundress

/datum/loadout_item/under/formal/tan_suit
	name = "Tan Suit"
	item_path = /obj/item/clothing/under/suit/tan

/datum/loadout_item/under/formal/teal_suit
	name = "Teal Suit"
	item_path = /obj/item/clothing/under/suit/teal

/datum/loadout_item/under/formal/teal_skirt
	name = "Teal Suitskirt"
	item_path = /obj/item/clothing/under/suit/teal/skirt

/datum/loadout_item/under/formal/turtleneck_skirt
	name = "Turtleneck Skirt"
	item_path = /obj/item/clothing/under/dress/skirt/turtleskirt

/datum/loadout_item/under/formal/tuxedo
	name = "Tuxedo Suit"
	item_path = /obj/item/clothing/under/suit/tuxedo

/datum/loadout_item/under/formal/waiter
	name = "Waiter's Suit"
	item_path = /obj/item/clothing/under/suit/waiter

/datum/loadout_item/under/formal/wedding
	name = "Wedding Dress"
	item_path = /obj/item/clothing/under/dress/wedding_dress

/datum/loadout_item/under/formal/white_suit
	name = "White Suit"
	item_path = /obj/item/clothing/under/suit/white

/datum/loadout_item/under/formal/white_skirt
	name = "White Suitskirt"
	item_path = /obj/item/clothing/under/suit/white/skirt

/datum/loadout_item/under/formal/nndress
	name = "Blue Dress"
	item_path = /obj/item/clothing/under/dress/nndress
	additional_displayed_text = list("Character Item")

/datum/loadout_item/under/formal/ritzuniform
	name = "Malheur Research Association uniform"
	item_path = /obj/item/clothing/under/rank/rnd/mrauniform
	additional_displayed_text = list("Character Item")

/datum/loadout_item/under/formal/reshiacoat
	name = "Black Uniform Coat"
	item_path = /obj/item/clothing/under/jumpsuit/reshiacoat
	additional_displayed_text = list("Character Item")

/datum/loadout_item/under/formal/arbitersuit
	name = "Arbiter's Suit"
	item_path = /obj/item/clothing/under/arbitersuit

/datum/loadout_item/under/formal/chesedsuit
	name = "Blue Waistcoat"
	item_path = /obj/item/clothing/under/chesedsuit

/datum/loadout_item/under/formal/kimono
	name = "Black Kimono"
	item_path = /obj/item/clothing/under/kimono

/datum/loadout_item/under/formal/kimono2
	name = "Red Kimono"
	item_path = /obj/item/clothing/under/kimono/red

/datum/loadout_item/under/formal/kimono3
	name = "Purple Kimono"
	item_path = /obj/item/clothing/under/kimono/purple

/datum/loadout_item/under/formal/yukata
	name = "Black Yukata"
	item_path = /obj/item/clothing/under/yukata

/datum/loadout_item/under/formal/yukata2
	name = "Green Yukata"
	item_path = /obj/item/clothing/under/yukata/green

/datum/loadout_item/under/formal/yukata3
	name = "Blue Yukata"
	item_path = /obj/item/clothing/under/yukata/blue

/datum/loadout_item/under/formal/grey
	name = "Designer Outfit"
	item_path = /obj/item/clothing/under/jumpsuit/greyshirt
	additional_displayed_text = list("Character Item")

/datum/loadout_item/under/formal/countess
	name = "Countess Dress"
	item_path = /obj/item/clothing/under/dress/countess

/datum/loadout_item/under/jumpsuit/pilot
	name = "Berbier Uniform"
	item_path = /obj/item/clothing/under/jumpsuit/lini
	additional_displayed_text = list("Character Item")

/datum/loadout_item/under/jumpsuit/jessie_turtleneck
	name = "Holointegrated Turtleneck"
	item_path = /obj/item/clothing/under/rank/rnd/research_director/jessie_turtleneck
	additional_displayed_text = list("Character Item")

/datum/loadout_item/under/jumpsuit/belli
	name = "Modified Nun Uniform"
	item_path = /obj/item/clothing/under/jumpsuit/belli
	additional_displayed_text = list("Character Item")

/datum/loadout_item/under/jumpsuit/vince
	name = "Violet Nurse Uniform"
	item_path = /obj/item/clothing/under/dress/vince
	additional_displayed_text = list("Character Item")
