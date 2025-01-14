// The Judicial Visor.
// Cause burn damage to people you examine,
// but they are told what direction you are afterwards.
/obj/item/clothing/glasses/judicial_visor
	name = "judicial visor"
	desc = "A Rat'varian brass visor with a purple eye guard that occasionally flares brightly."
	icon = 'maplestation_modules/icons/obj/clockwork_objects.dmi'
	base_icon_state = "judicial_visor"
	icon_state = "judicial_visor_1"
	inhand_icon_state = "trayson-meson"
	flags_cover = GLASSESCOVERSEYES
	flags_inv = HIDEEYES
	glass_colour_type = /datum/client_colour/glass_colour/purple
	COOLDOWN_DECLARE(examine_damage_cooldown)

/obj/item/clothing/glasses/judicial_visor/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || isobserver(user))
		. += span_brass("Examining non-cultists with the visor equipped will sear them for burn damage on a short cooldown.")
		. += span_brasstalics("Those who fall victim to the gaze will be hinted toward your direction afterwards.")

/obj/item/clothing/glasses/judicial_visor/equipped(mob/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_EYES)
		return
	if(ishuman(user) && IS_CULTIST(user))
		RegisterSignal(user, COMSIG_MOB_EXAMINATE, PROC_REF(on_user_examinate))

/obj/item/clothing/glasses/judicial_visor/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_EXAMINATE)

/**
 * Signal proc for [COMSIG_MOB_EXAMINATE].
 */
/obj/item/clothing/glasses/judicial_visor/proc/on_user_examinate(mob/living/carbon/human/source, atom/examined)
	SIGNAL_HANDLER

	if(examined == source || !isliving(examined))
		return

	if(!COOLDOWN_FINISHED(src, examine_damage_cooldown))
		to_chat(source, span_warning("You must wait [DisplayTimeText(COOLDOWN_TIMELEFT(src, examine_damage_cooldown))] before searing someone with your gaze again!"))
		return

	var/mob/living/target = examined
	if(source.stat != CONSCIOUS || source.is_blind())
		return
	if(target.stat != CONSCIOUS)
		return
	if(IS_CULTIST(target))
		to_chat(source, span_warning("[examined] is another cultist, and resists our gaze."))
		return
	if(target.is_blind()) // powergaming?!
		to_chat(source, span_warning("[examined] is blind, and cannot witness our gaze."))
		return
	if(source.z != examined.z || get_dist(source, examined) > 16) // We'll go off ~TK range, so no camera memes
		to_chat(source, span_warning("[examined] is too far to feel our gaze."))
		return

	// This point on, our attack was successful
	COOLDOWN_START(src, examine_damage_cooldown, 10 SECONDS)
	playsound(source, 'sound/weapons/marauder.ogg', 50, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	playsound(examined, 'sound/weapons/sear.ogg', 30, TRUE, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE)
	new /obj/effect/temp_visual/clock/marker(get_turf(examined))

	// Sets our icon to the "off" state.
	icon_state = "[base_icon_state]_0"
	source.update_worn_glasses()
	addtimer(CALLBACK(src, PROC_REF(reset_icon), source), 10 SECONDS)

	if(target.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY) & ANTIMAGIC_TIER_IMMUNE)
		return

	// And THIS point on, is where attack effects are done to the target
	target.apply_damage(15, BURN)
	target.adjust_jitter_up_to(12 SECONDS, 60 SECONDS)
	to_chat(target, span_userdanger("You feel a searing gaze bear down onto you from the [dir2text(get_dir(examined, source))]!"))
	to_chat(source, span_warning("You gaze harshly upon [examined], searing them!"))

/// Resets the icon to the "on" state.
/obj/item/clothing/glasses/judicial_visor/proc/reset_icon(mob/living/carbon/human/source)
	icon_state = "[base_icon_state]_1"
	source.update_worn_glasses()

// Visual effect for the visor.
/obj/effect/temp_visual/clock/marker
	icon_state = "judicial_marker"
	layer = ABOVE_MOB_LAYER
