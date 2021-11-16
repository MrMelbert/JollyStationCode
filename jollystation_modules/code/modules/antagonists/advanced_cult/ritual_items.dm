
/obj/item/melee/cultblade/dagger/advanced
	desc = "A special and strange dagger said to be used by cultists to prepare rituals, scribe runes, and combat heretics alike."

/obj/item/melee/cultblade/dagger/advanced/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/advanced_ritual_item, can_scrape_runes = FALSE, can_move_buildings = FALSE)

/obj/item/melee/cultblade/dagger/advanced/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) // Hacky hacky hacky

/obj/item/clockwork_slab
	name = "clockwork slab"
	desc = "A slab of brass covered in cogs and gizmos used by agents of Rat'var to invoke their spells."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "dread_ipad"
	worn_icon_state = "dread_ipad"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 4
	throwforce = 6
	block_chance = 20 // The slab protects
	actions_types = list(/datum/action/item_action/cult_dagger/slab)

/obj/item/clockwork_slab/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/advanced_ritual_item, required_cult_style = CULT_STYLE_RATVAR, turfs_that_boost_us = /turf/open/floor/bronze)

/datum/action/item_action/cult_dagger/slab
	name = "Draw Clockwork Rune"
	desc = "Use the clockwork slab to create a powerful rune."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "draw"
	buttontooltipstyle = "cult"
	background_icon_state = "bg_demon"
