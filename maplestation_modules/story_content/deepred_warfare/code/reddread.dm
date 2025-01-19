#define DREAD_TOTAL_LAYERS 2
#define DREAD_HEAD_LAYER 1
#define DREAD_NECK_LAYER 2

#define DOAFTER_SOURCE_DREAD_INTERACTION "dreadnought interaction"
#define SHIELDING_FILTER "shielding filter"

/mob/living/basic/redtechdread
	name = "Redtech Dreadnought Pattern"
	desc = "A terrifying robotic multi-limbed monstrosity, covered in armour plating."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/reddreadnought64.dmi'
	icon_state = "dreadnought_active"
	icon_living = "dreadnought_active"
	icon_dead = "dreadnought_dead"
	health_doll_icon = "dreadnought_active"
	pixel_x = -16
	base_pixel_x = -16
	health = 1000 // On par with Lavaland elites.
	maxHealth = 1000
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	speed = 3 // Slow as balls base speed.
	density = TRUE
	pass_flags = NONE
	sight = SEE_TURFS
	status_flags = NONE
	gender = PLURAL
	mob_biotypes = MOB_ROBOTIC | MOB_SPECIAL
	speak_emote = list("grinds")
	speech_span = SPAN_ROBOT
	bubble_icon = "machine"
	initial_language_holder = /datum/language_holder/redtech
	mob_size = MOB_SIZE_LARGE
	// has_unlimited_silicon_privilege = TRUE // Change later, maybe. // Nah, The Collector can just carry around an ID.
	damage_coeff = list(BRUTE = 1.2, BURN = 0.8, TOX = 0, STAMINA = 0, OXY = 0)
	faction = list(FACTION_DEEPRED)
	hud_type = /datum/hud/dextrous/dreadnought
	layer = LARGE_MOB_LAYER
	pressure_resistance = 200

	death_sound = 'sound/machines/clockcult/ark_deathrattle.ogg'
	death_message = "comes to a grinding halt, its systems shutting down with crackles of red lightning."

	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_NORMAL

	attack_verb_continuous = "crushes"
	attack_verb_simple = "crush"

	attack_sound = 'sound/effects/tableslam.ogg'
	attack_vis_effect = ATTACK_EFFECT_PUNCH

	melee_damage_upper = 15
	melee_damage_lower = 10
	obj_damage = 20
	armour_penetration = 0

	melee_attack_cooldown = (CLICK_CD_MELEE/2) // Many limbs, fast attacking.

	var/heavy_emp_damage = 80 // If the EMP is heavy, the pattern is damaged by this value.
	var/light_emp_damage = 40 // The pattern is damaged by this value when hit by an EMP.

	var/hands = 4

	var/list/dread_overlays[DREAD_TOTAL_LAYERS]

	var/obj/item/back_storage // Only used to hold the red lightning container.

	var/obj/item/default_storage = /obj/item/reagent_containers/cup/beaker/redlightning/filled

	var/obj/item/belt_storage // Can hold anything (but typically holds the storage module).

	var/obj/item/default_belt = /obj/item/storage/dread_storage

	var/obj/item/neck // Only used to hold the cloak.

	var/obj/item/default_neckwear = /obj/item/clothing/neck/cloak/redtech_dread

	var/obj/item/head // Multipurpose for masks and hats. (but usually the mask)

	var/obj/item/default_headwear = /obj/item/clothing/mask/collector

	/// Actions to grant on spawn (persistent slots)
	var/static/list/actions_to_add = list(
		/datum/action/cooldown/mob_cooldown/high_energy = null,
		/datum/action/cooldown/mob_cooldown/lightning_energy = null,
		/datum/action/access_printer = null,
		/datum/action/cooldown/mob_cooldown/dreadscan = null,
	)

	var/RLEnergy = 100 // Red lightning reserves (-100 to 100).
	var/RL_energy_regen = 2 // How much red lightning energy is regenerated per second.

	var/energy_level = 0 // Used for the red lightning system.

	var/shielding_level = 0 // Used for the faraday shielding system.

	var/datum/action/cooldown/mob_cooldown/faraday_shield/internalshield // Used to hold the shielding system.

	var/datum/action/dynamicSlot1 // Used to hold various projectile attacks.

	var/datum/action/dynamicSlot2 // Used to hold various AOE melee attacks.

	var/datum/action/dynamicSlot3 // Used to hold repair abilities.

	var/datum/action/dynamicSlot4 // Used to hold various AOE special attacks.

/datum/language_holder/redtech // Literally just the TG silicon language list (so far).
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/machine = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/moffic = list(LANGUAGE_ATOM),
		/datum/language/calcic = list(LANGUAGE_ATOM),
		/datum/language/voltaic = list(LANGUAGE_ATOM),
		/datum/language/nekomimetic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/machine = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/moffic = list(LANGUAGE_ATOM),
		/datum/language/calcic = list(LANGUAGE_ATOM),
		/datum/language/voltaic = list(LANGUAGE_ATOM),
		/datum/language/nekomimetic = list(LANGUAGE_ATOM),
	)

/mob/living/basic/redtechdread/get_speech_sounds(sound_type) // Hopefully works.
	return string_assoc_list(list('goon/sound/voice/radio_ai.ogg' = 100))

/mob/living/basic/redtechdread/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/dextrous, hud_type = hud_type)
	AddComponent(/datum/component/basic_inhands, y_offset = 0)
	change_number_of_hands(hands) // Cring.
	// AddComponent(/datum/component/simple_access, SSid_access.get_region_access_list(list(REGION_ALL_GLOBAL))) // I'm a dumbass.
	AddComponent(/datum/component/personal_crafting)

	AddComponent(/datum/component/regenerator, regeneration_delay = 10 MINUTES, brute_per_second = 10, outline_colour = NONE) // Highly suggested to use the self repair option, but this will kick in after 10 minutes if you are too lazy.

	add_traits(list(TRAIT_NO_PLASMA_TRANSFORM, // Just in case of Icebox.
					TRAIT_KNOW_ROBO_WIRES, // Big brain.
					TRAIT_MADNESS_IMMUNE, // Doesn't go insanae due to SM.
					TRAIT_NO_SOUL, // Only useful in case of revenant, but it's a nice thematic thing.
					TRAIT_PLANT_SAFE, // Metallic hands prevent plant exposure.
					TRAIT_QUICKER_CARRY, // Can't carry yet (oops).
					TRAIT_STRONG_GRABBER, // Many limbs provide strong grabbing.
					TRAIT_SURGEON, // Certified:tm: medical robotics.
					TRAIT_REAGENT_SCANNER, // Look at reagents to see what it is.
					TRAIT_GOOD_HEARING, // I HEARD YOU WHISPERING.
					TRAIT_FASTMED, // Certified:tm: medical robotics.
					TRAIT_NOFIRE, // Don't want the cloak and stuff to burn.
					TRAIT_PUSHIMMUNE, // Literal 3m tall tank of a robot.
					TRAIT_FIST_MINING, // Just in case of Icebox.
					TRAIT_NEGATES_GRAVITY, // Grabby grabby hands.
					TRAIT_LITERATE, // Basically needed.
					TRAIT_KNOW_ENGI_WIRES, // Big brain.
					TRAIT_ADVANCEDTOOLUSER, // Also basically needed
					TRAIT_CAN_STRIP), INNATE_TRAIT) // Also also basically needed.

	if(default_storage)
		var/obj/item/storage = new default_storage(src)
		equip_to_slot_or_del(storage, ITEM_SLOT_BACK)

	if(default_belt)
		var/obj/item/storage = new default_belt(src)
		equip_to_slot_or_del(storage, ITEM_SLOT_BELT)

	if(default_neckwear)
		var/obj/item/storage = new default_neckwear(src)
		equip_to_slot_or_del(storage, ITEM_SLOT_NECK)

	if(default_headwear)
		var/obj/item/storage = new default_headwear(src)
		equip_to_slot_or_del(storage, ITEM_SLOT_HEAD)

	grant_actions_by_list(actions_to_add)

	internalshield = new /datum/action/cooldown/mob_cooldown/faraday_shield(src)
	internalshield.Grant(src)

	// AddComponent(/datum/component/seethrough_mob)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(pre_attack))
	RegisterSignal(src, COMSIG_LIVING_LIFE, PROC_REF(on_life))

	var/obj/item/implant/radio/redtech/comms = new(src)
	comms.implant(src)

	update_base_stats() // This proc basically makes everything else redundant.

	shielding_level = 0
	updating_shield(0)
	// Maybe fixes the EMP thing.

/datum/hud/dextrous/dreadnought/New(mob/owner)
	..()
	var/atom/movable/screen/inventory/inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal red lightning storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = ITEM_SLOT_BACK
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "internal belt storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = ITEM_SLOT_BELT
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "cloak"
	inv_box.icon = ui_style
	inv_box.icon_state = "neck"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = ITEM_SLOT_NECK
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "head/mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = ITEM_SLOT_HEAD
	static_inventory += inv_box

/datum/hud/dextrous/dreadnought/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/basic/redtechdread/drone = mymob

	if(hud_shown)
		if(!isnull(drone.back_storage))
			drone.back_storage.screen_loc = ui_back
			drone.client.screen += drone.back_storage
		if(!isnull(drone.belt_storage))
			drone.belt_storage.screen_loc = ui_belt
			drone.client.screen += drone.belt_storage
		if(!isnull(drone.neck))
			drone.neck.screen_loc = ui_id
			drone.client.screen += drone.neck
		if(!isnull(drone.head))
			drone.head.screen_loc = ui_sstore1
			drone.client.screen += drone.head
	else
		drone.back_storage?.screen_loc = null
		drone.belt_storage?.screen_loc = null
		drone.neck?.screen_loc = null
		drone.head?.screen_loc = null
	..()

/mob/living/basic/redtechdread/doUnEquip(obj/item/item, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(..())
		update_held_items()
		if(item == head)
			head = null
			update_worn_head()
		if(item == neck)
			neck = null
			update_worn_neck()
		if(item == belt_storage)
			belt_storage = null
			update_worn_belt()
		if(item == back_storage)
			back_storage = null
			update_worn_back()
		return TRUE
	return FALSE

/mob/living/basic/redtechdread/can_equip(obj/item/item, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	switch(slot)
		if(ITEM_SLOT_HEAD)
			if(head)
				return FALSE
			if(!((item.slot_flags & ITEM_SLOT_HEAD) || (item.slot_flags & ITEM_SLOT_MASK)))
				return FALSE
			if(!(istype(item, /obj/item/clothing/mask/collector)))
				return FALSE
			return TRUE
		if(ITEM_SLOT_NECK)
			if(neck)
				return FALSE
			if(energy_level != 0)
				return FALSE
			if(!(istype(item, /obj/item/clothing/neck/cloak/redtech_dread)))
				return FALSE
			return TRUE
		if(ITEM_SLOT_BELT)
			if(belt_storage)
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACK)
			if(back_storage)
				return FALSE
			if(!(istype(item, /obj/item/reagent_containers/cup/beaker/redlightning)))
				return FALSE
			return TRUE
	..()

/mob/living/basic/redtechdread/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_NECK)
			return neck
		if(ITEM_SLOT_BELT)
			return belt_storage
		if(ITEM_SLOT_BACK)
			return back_storage

	return ..()

/mob/living/basic/redtechdread/get_slot_by_item(obj/item/looking_for)
	if(back_storage == looking_for)
		return ITEM_SLOT_BACK
	if(belt_storage == looking_for)
		return ITEM_SLOT_BELT
	if(neck == looking_for)
		return ITEM_SLOT_NECK
	if(head == looking_for)
		return ITEM_SLOT_HEAD
	return ..()

/mob/living/basic/redtechdread/equip_to_slot(obj/item/equipping, slot, initial = FALSE, redraw_mob = FALSE, indirect_action = FALSE)
	if(!slot)
		return
	if(!istype(equipping))
		return

	var/index = get_held_index_of_item(equipping)
	if(index)
		held_items[index] = null
	update_held_items()

	if(equipping.pulledby)
		equipping.pulledby.stop_pulling()

	equipping.screen_loc = null // will get moved if inventory is visible
	equipping.forceMove(src)
	SET_PLANE_EXPLICIT(equipping, ABOVE_HUD_PLANE, src)

	switch(slot)
		if(ITEM_SLOT_HEAD)
			head = equipping
			update_worn_head()
		if(ITEM_SLOT_NECK)
			neck = equipping
			update_worn_neck()
		if(ITEM_SLOT_BELT)
			belt_storage = equipping
			update_worn_belt()
		if(ITEM_SLOT_BACK)
			back_storage = equipping
			update_worn_back()
		else
			to_chat(src, span_danger("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))
			return

	//Call back for item being equipped to drone
	equipping.on_equipped(src, slot)

/mob/living/basic/redtechdread/update_clothing(slot_flags)
	if(slot_flags & ITEM_SLOT_HEAD)
		update_worn_head()
	if(slot_flags & ITEM_SLOT_MASK)
		update_worn_mask()
	if(slot_flags & ITEM_SLOT_NECK)
		update_worn_neck()
	if(slot_flags & ITEM_SLOT_BELT)
		update_worn_belt()
	if(slot_flags & ITEM_SLOT_HANDS)
		update_held_items()
	if(slot_flags & (ITEM_SLOT_HANDS|ITEM_SLOT_BACKPACK|ITEM_SLOT_BACK))
		update_worn_back()

/mob/living/basic/redtechdread/update_held_items()
	SHOULD_CALL_PARENT(FALSE) // Get overridden nerd.
	if(isnull(client) || isnull(hud_used) || hud_used.hud_version == HUD_STYLE_NOHUD)
		return
	var/turf/our_turf = get_turf(src)
	for(var/obj/item/held in held_items)
		var/index = get_held_index_of_item(held)
		SET_PLANE(held, ABOVE_HUD_PLANE, our_turf)
		held.screen_loc = ui_hand_position(index)
		client.screen |= held

/mob/living/basic/redtechdread/proc/apply_overlay(cache_index)
	if((. = dread_overlays[cache_index]))
		add_overlay(.)

/mob/living/basic/redtechdread/proc/remove_overlay(cache_index)
	var/overlay = dread_overlays[cache_index]
	if(overlay)
		cut_overlay(overlay)
		dread_overlays[cache_index] = null

/mob/living/basic/redtechdread/update_worn_head()
	remove_overlay(DREAD_HEAD_LAYER)

	if(head)
		if(client && hud_used?.hud_shown)
			head.screen_loc = ui_sstore1
			client.screen += head
		var/used_head_icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreadclothing.dmi'
		//if(istype(head, /obj/item/clothing/mask))
			//used_head_icon = 'icons/mob/clothing/mask.dmi'
		var/obj/item/force_mask = new /obj/item/clothing/mask/collector/pattern
		var/mutable_appearance/head_overlay = force_mask.build_worn_icon(default_layer = DREAD_HEAD_LAYER, default_icon_file = used_head_icon)
		// head_overlay.pixel_y -= 15

		dread_overlays[DREAD_HEAD_LAYER] = head_overlay

	apply_overlay(DREAD_HEAD_LAYER)
	update_naming_status()

/mob/living/basic/redtechdread/update_worn_mask()
	update_worn_head()

/mob/living/basic/redtechdread/update_worn_neck()
	remove_overlay(DREAD_NECK_LAYER)

	if(neck)
		if(client && hud_used?.hud_shown)
			neck.screen_loc = ui_id
			client.screen += neck
		var/used_neck_icon = 'maplestation_modules/story_content/deepred_warfare/icons/dreadclothing.dmi'
		var/obj/item/force_cloak = new /obj/item/clothing/neck/cloak/redtech_dread/pattern
		var/mutable_appearance/neck_overlay = force_cloak.build_worn_icon(default_layer = DREAD_NECK_LAYER, default_icon_file = used_neck_icon)
		// head_overlay.pixel_y -= 15

		dread_overlays[DREAD_NECK_LAYER] = neck_overlay

	apply_overlay(DREAD_NECK_LAYER)
	update_naming_status()

/mob/living/basic/redtechdread/update_worn_back()
	if(back_storage && client && hud_used?.hud_shown)
		back_storage.screen_loc = ui_back
		client.screen += back_storage

/mob/living/basic/redtechdread/update_worn_belt()
	if(belt_storage && client && hud_used?.hud_shown)
		belt_storage.screen_loc = ui_belt
		client.screen += belt_storage

/mob/living/basic/redtechdread/regenerate_icons()
	// FUCK.
	update_held_items()
	update_worn_head()
	update_worn_neck()
	update_worn_belt()
	update_worn_back()

/mob/living/basic/redtechdread/proc/update_naming_status()
	if(neck)
		if(head)
			name = "The Collector"
			desc = "An enigmatic and imposing mechanical figure. They are wearing an oriental fox mask, with only one eye hole on the light side of their face."
			return
		name = "The Collector"
		desc = "An enigmatic and imposing mechanical figure. Their face can only be described as half sensor array, half volley gun."
		return
	name = "Redtech Dreadnought Pattern"
	desc = "A terrifying robotic multi-limbed monstrosity, covered in armour plating. By looking at their face, you are staring down almost a dozen barrels."

/mob/living/basic/redtechdread/emp_reaction(severity)
	if(EMP_PROTECT_SELF && shielding_level > 0)
		playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 120)
		src.visible_message(span_warning("[src]'s shield absorbs the EMP!"))
		new /obj/effect/temp_visual/faraday/emp(get_turf(src))
		return

	if(health <= 0)
		return

	visible_message(span_danger("[src] shudders for a moment."))
	Shake(duration = 1 SECONDS)
	switch(severity)
		if(EMP_LIGHT)
			apply_damage(light_emp_damage)
			to_chat(src, span_danger("EMP DETECTED: DAMAGE TO HARDWARE"))
			adjust_RL_energy_or_damage(-(light_emp_damage / 4))
		if(EMP_HEAVY)
			apply_damage(heavy_emp_damage)
			to_chat(src, span_userdanger("WARNING: HEAVY DAMAGE TO HARDWARE"))
			adjust_RL_energy_or_damage(-(heavy_emp_damage / 4))

/mob/living/basic/redtechdread/electrocute_act(shock_damage, source, siemens_coeff, flags = NONE)
	return FALSE

/mob/living/basic/redtechdread/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash, length = 25)
	if(affect_silicon)
		return ..()

/mob/living/basic/redtechdread/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] \a <b>[src]</b>!")

	//desc
	. += "[src.desc]"

	//Hands
	for(var/obj/item/held_thing in held_items)
		if(held_thing.item_flags & (ABSTRACT|EXAMINE_SKIP|HAND_ITEM))
			continue
		. += "They have [held_thing.examine_title(user)] in their [get_held_index_name(get_held_index_of_item(held_thing))]."

	if(!neck) // If the cloak is not worn, show the internal storage.
		//Back storage
		if(back_storage && !(back_storage.item_flags & ABSTRACT))
			. += "They are holding [back_storage.examine_title(user)] in their reactor port."

		//Belt storage
		if(belt_storage && !(belt_storage.item_flags & ABSTRACT))
			. += "They are holding [belt_storage.examine_title(user)] in their storage compartment."

	//Neckwear
	if(neck && !(neck.item_flags & ABSTRACT))
		. += "They are wearing [neck.examine_title(user)]."

	//Cosmetic hat - provides no function other than looks
	if(head && !(head.item_flags & ABSTRACT))
		. += "They are wearing [head.examine_title(user)] on their head."

	//Braindead
	if(!client && stat != DEAD)
		. += "They appear to be currently disconnected."

	//Damaged
	if(health != maxHealth) // Note to self, change description if it is wearing a cloak.
		if(health > maxHealth * 0.5)
			if(neck)
				. += span_warning("They make a metallic grinding noise when they move.")
			else
				. += span_warning("Their armour plates are slightly damaged.")
		else //otherwise, below about 50%
			if(neck)
				. += span_warning("Occasional sparks fly from out under their cloak.")
			else
				. += span_boldwarning("Their armour plates are heavily damaged!")

	//Dead
	if(stat == DEAD)
		if(client)
			. += span_deadsay("Their systems have been shut down.")
		else
			. += span_deadsay("They are about as useful as a heap of scrap metal now.")
	. += "</span>"

/mob/living/basic/redtechdread/get_status_tab_items()
	. = ..()
	switch(energy_level)
		if(0)
			. += "In low energy mode."
		if(1)
			. += "In high energy mode."
		if(2)
			. += "In red lightning mode."

	. += "Red lightning reserves: [RLEnergy]"

/datum/movespeed_modifier/high_energy
	multiplicative_slowdown = -3

/datum/movespeed_modifier/RL_energy
	multiplicative_slowdown = -3.5

/mob/living/basic/redtechdread/proc/update_base_stats()
	switch(energy_level)
		if(0)
			remove_movespeed_modifier(/datum/movespeed_modifier/high_energy)
			remove_movespeed_modifier(/datum/movespeed_modifier/RL_energy)

			RemoveElement(/datum/element/wall_tearer, tear_time = 2 SECONDS, reinforced_multiplier = 3, do_after_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			RemoveElement(/datum/element/door_pryer, pry_time = 2 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			RemoveElement(/datum/element/wall_tearer, tear_time = 4 SECONDS, reinforced_multiplier = 3, do_after_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			RemoveElement(/datum/element/door_pryer, pry_time = 4 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)

			AddElement(/datum/element/door_pryer, pry_time = 8 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)

			RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY, 1, sound_vary = TRUE)
			AddElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW, sound_vary = TRUE)

			RL_energy_regen = 2

			pixel_x = -16
			base_pixel_x = -16

			move_force = MOVE_FORCE_NORMAL
			move_resist = MOVE_FORCE_STRONG
			pull_force = MOVE_FORCE_NORMAL

			attack_verb_continuous = "crushes"
			attack_verb_simple = "crush"

			attack_sound = 'sound/effects/tableslam.ogg'
			attack_vis_effect = ATTACK_EFFECT_PUNCH

			melee_damage_upper = 15
			melee_damage_lower = 10
			obj_damage = 20
			armour_penetration = 0

			RemoveElement(/datum/element/shockattack, stun_on_hit = FALSE, shock_damage = 15)

			RemoveElement(/datum/element/effect_trail, /obj/effect/temp_visual/red_lightning_trail)

			if(shielding_level > 0)
				updating_shield(1)
			else
				updating_shield(0)

			if(dynamicSlot1)
				dynamicSlot1.Remove(src)
			dynamicSlot1 = new /datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet(src)
			dynamicSlot1.Grant(src)

			if(dynamicSlot2)
				dynamicSlot2.Remove(src)
			dynamicSlot2 = new /datum/action/cooldown/mob_cooldown/charge/basic_charge/dread(src)
			dynamicSlot2.Grant(src)

			if(dynamicSlot3)
				dynamicSlot3.Remove(src)
			dynamicSlot3 = new /datum/action/cooldown/mob_cooldown/dreadrepair(src)
			dynamicSlot3.Grant(src)

			if(dynamicSlot4)
				dynamicSlot4.Remove(src)
			dynamicSlot4 = new /datum/action/cooldown/mob_cooldown/heatburst(src)
			dynamicSlot4.Grant(src)

		if(1)
			remove_movespeed_modifier(/datum/movespeed_modifier/RL_energy)
			add_movespeed_modifier(/datum/movespeed_modifier/high_energy)

			RemoveElement(/datum/element/wall_tearer, tear_time = 2 SECONDS, reinforced_multiplier = 3, do_after_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			RemoveElement(/datum/element/door_pryer, pry_time = 2 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			RemoveElement(/datum/element/door_pryer, pry_time = 8 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)

			AddElement(/datum/element/wall_tearer, tear_time = 4 SECONDS, reinforced_multiplier = 3, do_after_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			AddElement(/datum/element/door_pryer, pry_time = 4 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)

			RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY, 1, sound_vary = TRUE)
			RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW, sound_vary = TRUE)
			AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY, 1, sound_vary = TRUE)

			RL_energy_regen = 1

			pixel_x = -16
			base_pixel_x = -16

			move_force = MOVE_FORCE_STRONG
			move_resist = MOVE_FORCE_STRONG
			pull_force = MOVE_FORCE_STRONG

			attack_verb_continuous = "pulverizes"
			attack_verb_simple = "pulverize"

			attack_sound = 'sound/effects/meteorimpact.ogg'
			attack_vis_effect = ATTACK_EFFECT_SMASH

			melee_damage_upper = 30
			melee_damage_lower = 25
			obj_damage = 40
			armour_penetration = 20

			RemoveElement(/datum/element/shockattack, stun_on_hit = FALSE, shock_damage = 15)

			RemoveElement(/datum/element/effect_trail, /obj/effect/temp_visual/red_lightning_trail)

			if(shielding_level > 0)
				updating_shield(2)
			else
				updating_shield(0)

			if(dynamicSlot1)
				dynamicSlot1.Remove(src)
			dynamicSlot1 = new /datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet/high(src)
			dynamicSlot1.Grant(src)

			if(dynamicSlot2)
				dynamicSlot2.Remove(src)
			dynamicSlot2 = new /datum/action/cooldown/mob_cooldown/charge/basic_charge/dread/high(src)
			dynamicSlot2.Grant(src)

			if(dynamicSlot3)
				dynamicSlot3.Remove(src)
			dynamicSlot3 = new /datum/action/cooldown/mob_cooldown/dreadrepair/high(src)
			dynamicSlot3.Grant(src)

			if(dynamicSlot4)
				dynamicSlot4.Remove(src)
			dynamicSlot4 = new /datum/action/cooldown/mob_cooldown/heatburst/high(src)
			dynamicSlot4.Grant(src)

		if(2)
			remove_movespeed_modifier(/datum/movespeed_modifier/high_energy)
			add_movespeed_modifier(/datum/movespeed_modifier/RL_energy)

			RemoveElement(/datum/element/wall_tearer, tear_time = 4 SECONDS, reinforced_multiplier = 3, do_after_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			RemoveElement(/datum/element/door_pryer, pry_time = 4 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			RemoveElement(/datum/element/door_pryer, pry_time = 8 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)

			AddElement(/datum/element/wall_tearer, tear_time = 2 SECONDS, reinforced_multiplier = 3, do_after_key = DOAFTER_SOURCE_DREAD_INTERACTION)
			AddElement(/datum/element/door_pryer, pry_time = 2 SECONDS, interaction_key = DOAFTER_SOURCE_DREAD_INTERACTION)

			RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY, 1, sound_vary = TRUE)
			RemoveElement(/datum/element/footstep, FOOTSTEP_MOB_CLAW, sound_vary = TRUE)
			AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY, 1, sound_vary = TRUE)

			RL_energy_regen = -0.5

			pixel_x = -16
			base_pixel_x = -16

			move_force = MOVE_FORCE_VERY_STRONG
			move_resist = MOVE_FORCE_VERY_STRONG
			pull_force = MOVE_FORCE_VERY_STRONG

			attack_verb_continuous = "annihilates"
			attack_verb_simple = "annihilate"

			attack_sound = 'sound/effects/meteorimpact.ogg'
			attack_vis_effect = ATTACK_EFFECT_SMASH

			melee_damage_upper = 35 // Plus shock damage.
			melee_damage_lower = 30 // Plus shock damage.
			obj_damage = 60
			armour_penetration = 40

			AddElement(/datum/element/shockattack, stun_on_hit = FALSE, shock_damage = 15)

			AddElement(/datum/element/effect_trail, /obj/effect/temp_visual/red_lightning_trail)

			if(shielding_level > 0)
				updating_shield(3)
			else
				updating_shield(0)

			if(dynamicSlot1)
				dynamicSlot1.Remove(src)
			dynamicSlot1 = new /datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet/lightning(src)
			dynamicSlot1.Grant(src)

			if(dynamicSlot2)
				dynamicSlot2.Remove(src)
			dynamicSlot2 = new /datum/action/cooldown/mob_cooldown/charge/basic_charge/dread/lightning(src)
			dynamicSlot2.Grant(src)

			if(dynamicSlot3)
				dynamicSlot3.Remove(src)
			dynamicSlot3 = new /datum/action/cooldown/mob_cooldown/dreadrepair/lightning(src)
			dynamicSlot3.Grant(src)

			if(dynamicSlot4)
				dynamicSlot4.Remove(src)

	update_naming_status()

/mob/living/basic/redtechdread/proc/pre_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER
	if (target == src)
		return COMPONENT_HOSTILE_NO_ATTACK // Easy to misclick yourself, let's not.
	if (DOING_INTERACTION(source, DOAFTER_SOURCE_DREAD_INTERACTION))
		balloon_alert(source, "busy!")
		return COMPONENT_HOSTILE_NO_ATTACK
	return

/mob/living/basic/redtechdread/proc/adjust_RL_energy(amount)
	RLEnergy += amount
	if(RLEnergy < -100)
		RLEnergy = clamp(RLEnergy, -100, 100)
		kick_out_of_RL()
		return
	RLEnergy = clamp(RLEnergy, -100, 100)

/mob/living/basic/redtechdread/proc/adjust_RL_energy_or_damage(amount)
	if(RLEnergy < 0)
		apply_damage(-amount)
		return
	adjust_RL_energy(amount)

/mob/living/basic/redtechdread/proc/on_life(seconds_per_tick, times_fired)
	adjust_RL_energy(RL_energy_regen)

/mob/living/basic/redtechdread/proc/kick_out_of_RL()
	if(energy_level == 2)
		src.balloon_alert(src, "you run out of RL energy!")
		energy_level = 0
		playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 120)
		update_base_stats()

/mob/living/basic/redtechdread/proc/updating_shield(newlevel)
	shielding_level = newlevel

	switch(shielding_level)
		if(0)
			src.remove_filter(SHIELDING_FILTER)
			damage_coeff = list(BRUTE = 1.2, BURN = 0.8, TOX = 0, STAMINA = 0, OXY = 0) // 1250 EHP vs BURN (800 EHP vs BRUTE)

			RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)
		if(1)
			src.remove_filter(SHIELDING_FILTER)
			src.add_filter(SHIELDING_FILTER, 2, list("type" = "outline", "color" = COLOR_RED, "alpha" = 160, "size" = 1))
			damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0) // 2000 EHP vs BURN

			RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)
			AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)
		if(2)
			src.remove_filter(SHIELDING_FILTER)
			src.add_filter(SHIELDING_FILTER, 2, list("type" = "outline", "color" = COLOR_RED, "alpha" = 255, "size" = 1))
			damage_coeff = list(BRUTE = 1, BURN = 0.25, TOX = 0, STAMINA = 0, OXY = 0) // 4000 EHP vs BURN

			RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)
			AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)
		if(3)
			src.remove_filter(SHIELDING_FILTER)
			src.add_filter(SHIELDING_FILTER, 2, list("type" = "outline", "color" = COLOR_RED, "alpha" = 255, "size" = 2))
			damage_coeff = list(BRUTE = 1, BURN = 0.1, TOX = 0, STAMINA = 0, OXY = 0) // 10000 EHP vs BURN (could theoretically tank the KAJARI if it wasn't for the explosive damage)

			RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)
			AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

	internalshield.update_shield_stats()

/mob/living/basic/redtechdread/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(shielding_level > 0) // If the shielding is even on.
		if(amount >= 12) // If the brute damage is 12 or more, shield takes damage but deflects the attack.
			internalshield.take_hit()
			new /obj/effect/temp_visual/faraday/shatter(get_turf(src))
			return 0
		else // Not enough damage to damage the shield, damage is deflected.
			playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 120)
			src.visible_message(span_warning("[src]'s shield struggles to deflect the impact!"))
			new /obj/effect/temp_visual/faraday(get_turf(src))
			return 0
	. = ..()

/mob/living/basic/redtechdread/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	. = ..()
	if(shielding_level > 0) // Shielding is on.
		playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 120)
		src.visible_message(span_warning("[src]'s shield dampens the thermal energy!")) // This is basically handled by the EHP system but I added this for flavour anyways.
		new /obj/effect/temp_visual/faraday/energy(get_turf(src))

/mob/living/basic/redtechdread/death(gibbed)
	..(gibbed)
	if(back_storage)
		dropItemToGround(back_storage)
	if(belt_storage)
		dropItemToGround(belt_storage)
	if(neck)
		dropItemToGround(neck)
	if(head)
		dropItemToGround(head)

/mob/living/basic/redtechdread/ex_act(severity, target)
	if(shielding_level > 0)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 120)
				src.visible_message(span_warning("[src]'s shield shatters as it tries deflect the explosion!"))
				internalshield.break_shield()
				severity = EXPLODE_HEAVY
			if(EXPLODE_HEAVY)
				playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 120)
				src.visible_message(span_warning("[src]'s shield shatters as it tries deflect the explosion!"))
				internalshield.break_shield()
				severity = EXPLODE_LIGHT
			if(EXPLODE_LIGHT)
				playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 120)
				src.visible_message(span_warning("[src]'s shield struggles to deflect the explosion!"))
				internalshield.take_hit()
				severity = EXPLODE_NONE
		new /obj/effect/temp_visual/faraday/shatter(get_turf(src))
	return ..()

#undef DOAFTER_SOURCE_DREAD_INTERACTION
