/// -- Loadout undersuits (jumpsuit kind) --
/obj/item/clothing/under/suit/teal
	name = "teal suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon = 'icons/obj/clothing/under/civilian.dmi'
	worn_icon = 'icons/mob/clothing/under/civilian.dmi'
	icon_state = "teal_suit"
	inhand_icon_state = "g_suit"
	can_adjust = FALSE

/obj/item/clothing/under/suit/teal/skirt
	name = "teal suitskirt"
	desc = "A teal suitskirt and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit_skirt"
	inhand_icon_state = "g_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/gladiator/loadout
	desc = "An almost pristine light-weight gladitorial armor set inspired by those the Ash Walkers wear. It's unarmored and looks very dated."

/obj/item/clothing/under/color/greyscale
	name = "tailored jumpsuit"
	desc = "A tailor made custom jumpsuit."
	greyscale_colors = "#eeeeee"

/obj/item/clothing/under/color/jumpskirt/greyscale
	name = "tailored jumpskirt"
	desc = "A tailor made custom jumpskirt."
	greyscale_colors = "#eeeeee"

/obj/item/clothing/under/spacer_turtleneck //skyrat's turtleneck, but recolorable, ported from starbloom
	name = "spacer's turtleneck"
	desc = "An old ship uniform from the days of spacefarers past. Bears similarity to what would become the Syndicate's tactical turtleneck."
	icon = 'maplestation_modules/icons/obj/clothing/under/spacer_turtleneck.dmi'
	worn_icon = 'maplestation_modules/icons/mob/clothing/under/spacer_turtleneck.dmi'
	icon_state = "turtleneck"
	icon_preview = 'maplestation_modules/icons/obj/clothing/under/spacer_turtleneck.dmi'
	icon_state_preview = "greyscale_sweater"
	greyscale_config = /datum/greyscale_config/spacer_turtleneck
	greyscale_config_worn = /datum/greyscale_config/spacer_turtleneck_worn
	greyscale_colors = "#5e483c#1c1c1c#4fb4e6"
	alt_covers_chest = TRUE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/spacer_turtleneck/plain
	name = "spacer's uniform"
	desc = "An old ship uniform from the days of spacefarers past. In the old days, engineering wore red and command wore gold."
	icon_state = "turtlefool"
	icon_state_preview = "greyscale_shirt"

/obj/item/clothing/under/spacer_turtleneck/skirt
	name = "spacer's skirtleneck"
	desc = "An old ship uniform from the days of spacefarers past. Bears similarity to what would become the Syndicate's tactical skirtleneck."
	icon_state = "turtleneck_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/spacer_turtleneck/skirt/plain
	name = "spacer's skirt"
	desc = "An old ship uniform from the days of spacefarers past. In the old days, engineering wore red and command wore gold. And women wore less."
	icon_state = "turtlefool_skirt"
	icon_state_preview = "greyscale_shirt"

/obj/item/clothing/under/arbitersuit
	name = "arbiter's suit"
	desc = "A curious garb that has varying cultural significance to many Ornithid groups. Doesn't pair well with the color red."
	icon = 'maplestation_modules/icons/obj/clothing/under/ornithid_clothes.dmi'
	worn_icon = 'maplestation_modules/icons/mob/clothing/under/ornithid_clothes.dmi'
	icon_state = "arbiter_suit"
	can_adjust = FALSE

/obj/item/clothing/under/chesedsuit
	name = "blue waistcoat"
	desc = "A simple and clean blue waist coat, light blue business shirt, and dark purple slacks combo. Smells faintly of coffee."
	icon = 'maplestation_modules/icons/obj/clothing/under/ornithid_clothes.dmi'
	worn_icon = 'maplestation_modules/icons/mob/clothing/under/ornithid_clothes.dmi'
	icon_state = "chesed_suit"
	clothing_traits = list(TRAIT_CAFFEINE_LOVER)

// https://github.com/Skyrat-SS13/Skyrat-tg/pull/17098
/obj/item/clothing/under/dress/countess
	name = "countess dress"
	desc = "A wide flowing dress fitting for a countess; may be prone to catching onto stuff as you pass."
	icon = 'maplestation_modules/icons/obj/clothing/under/countess.dmi'
	worn_icon = 'maplestation_modules/icons/mob/clothing/under/countess.dmi'
	icon_state = "countess"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESHOES
