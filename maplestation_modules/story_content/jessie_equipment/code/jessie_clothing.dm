/obj/item/clothing/under/rank/rnd/research_director/jessie_turtleneck
	name = "holointegrated turtleneck"
	desc = "A black turtleneck paired with jeans. It's missing one sleeve and has a triad of small holoprojectors installed on its neck, back and belt buckle."
	icon = 'maplestation_modules/story_content/jessie_equipment/icons/jessieuniform_item.dmi'
	worn_icon = 'maplestation_modules/story_content/jessie_equipment/icons/jessieuniform_worn.dmi'
	icon_state = "turtleneck"
	base_icon_state = "turtleneck"
	inhand_icon_state = "bl_suit"
	can_adjust = TRUE
	alt_covers_chest = FALSE
	var/projectors_enabled = TRUE

/obj/item/clothing/under/rank/rnd/research_director/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/under/rank/rnd/research_director/jessie_turtleneck/alt_click_secondary(mob/user)
	. = ..()
	if(.)
		return
	projectors_enabled = !projectors_enabled
	update_appearance()
	if (user == loc)
		user.update_clothing(slot_flags)

/obj/item/clothing/under/rank/rnd/research_director/jessie_turtleneck/update_icon()
	. = ..()
	icon_state = "[base_icon_state][projectors_enabled ? "" : "_noholo"]"
	worn_icon_state = "[base_icon_state][adjusted ? "_d" : ""][projectors_enabled ? "" : "_noholo"]"

/obj/item/clothing/under/rank/rnd/research_director/jessie_turtleneck/update_overlays()
	. = ..()
	if(projectors_enabled)
		. += emissive_appearance(icon, "[icon_state]_e", offset_spokesman = src, alpha = src.alpha)

/obj/item/clothing/under/rank/rnd/research_director/jessie_turtleneck/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(projectors_enabled && !isinhands)
		. += emissive_appearance(worn_icon, "[icon_state]_e", offset_spokesman = loc, alpha = src.alpha)

/datum/loadout_item/under/jumpsuit/jessie_turtleneck
	name = "Holointegrated Turtleneck"
	item_path = /obj/item/clothing/under/rank/rnd/research_director/jessie_turtleneck
	additional_displayed_text = list("Character Item")

/obj/item/clothing/gloves/black/jessie_gloves
	name = "mixed gloves"
	desc = "A pair of uneven black gloves. Left glove has been cut into nothing more than a strip of fabric with a holoprojector built into it."
	icon = 'maplestation_modules/story_content/jessie_equipment/icons/jessieuniform_item.dmi'
	worn_icon = 'maplestation_modules/story_content/jessie_equipment/icons/jessieuniform_worn.dmi'
	icon_state = "gloves"
	base_icon_state = "gloves"
	var/projectors_enabled = TRUE

/obj/item/clothing/gloves/black/jessie_gloves/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/gloves/black/jessie_gloves/alt_click_secondary(mob/user)
	. = ..()
	if(.)
		return
	projectors_enabled = !projectors_enabled
	update_appearance()
	if (user == loc)
		user.update_clothing(slot_flags)

/obj/item/clothing/gloves/black/jessie_gloves/update_icon()
	. = ..()
	icon_state = "[base_icon_state][projectors_enabled ? "" : "_noholo"]"
	worn_icon_state = icon_state

/obj/item/clothing/gloves/black/jessie_gloves/update_overlays()
	. = ..()
	if(projectors_enabled)
		. += emissive_appearance(icon, "[icon_state]_e", offset_spokesman = src, alpha = src.alpha)

/obj/item/clothing/gloves/black/jessie_gloves/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(projectors_enabled && !isinhands)
		. += emissive_appearance(worn_icon, "[icon_state]_e", offset_spokesman = loc, alpha = src.alpha)

/datum/loadout_item/gloves/jessie_gloves
	name = "Mixed Gloves"
	item_path = /obj/item/clothing/gloves/black/jessie_gloves
	additional_displayed_text = list("Character Item")

// Retexture of RD's jacket
/obj/item/clothing/suit/toggle/labcoat/research_director/jessie_cape
	name = "researcher's shoulder cape"
	desc = "A white shoulder cape decorated with purple stripes made from an acid-proof material."
	icon = 'maplestation_modules/story_content/jessie_equipment/icons/jessieuniform_item.dmi'
	worn_icon = 'maplestation_modules/story_content/jessie_equipment/icons/jessieuniform_worn.dmi'
	icon_state = "cloak"
	base_icon_state = "cloak"
	slot_flags = ITEM_SLOT_NECK | ITEM_SLOT_OCLOTHING

/obj/item/clothing/suit/toggle/labcoat/research_director/jessie_cape/equipped(mob/living/user, slot)
	. = ..()
	if (slot == ITEM_SLOT_NECK)
		set_armor(/datum/armor/none)
	else
		set_armor(initial(armor_type))

/datum/loadout_item/suit/jessie_cape
	name = "Researcher's Shoulder Cape"
	item_path = /obj/item/clothing/suit/toggle/labcoat/research_director/jessie_cape
	additional_displayed_text = list("Character Item")
