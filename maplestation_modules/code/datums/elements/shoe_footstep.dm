/// Basically the squeak component but stripped down for only shoes
/datum/component/shoe_footstep
	dupe_mode = COMPONENT_DUPE_ALLOWED

	/// Tracks how many steps have been taken since the last sound was played
	VAR_PRIVATE/steps = 0

	/// The sounds that can be played
	var/list/sounds
	/// Whether the shoes can be taped, self-deleting the component / making the shoes silent
	var/can_tape
	/// The volume of the sound
	var/volume
	/// The chance that a sound will be played
	var/chance_per_play
	/// The number of steps that must be taken before a sound can be played
	var/steps_per_play
	/// Extrarange modifier on the played footstep sound
	var/extrarange
	/// Falloff exponent for the played footstep sound
	var/falloff_exponent
	/// Falloff distance for the played footstep sound
	var/falloff_distance

/datum/component/shoe_footstep/Initialize(
	list/sounds,
	can_tape = FALSE,
	volume = 50,
	chance_per_play = 100,
	steps_per_play = 1,
	extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE,
	falloff_exponent = SOUND_FALLOFF_EXPONENT,
	falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE,
)
	if(!istype(parent, /obj/item/clothing/shoes))
		return COMPONENT_INCOMPATIBLE
	if(!length(sounds) || volume <= 0 || chance_per_play <= 0 || steps_per_play < 0)
		return COMPONENT_INCOMPATIBLE
	src.sounds = sounds
	src.can_tape = can_tape
	src.volume = volume
	src.chance_per_play = chance_per_play
	src.steps_per_play = steps_per_play
	src.extrarange = extrarange
	src.falloff_exponent = falloff_exponent
	src.falloff_distance = falloff_distance

/datum/component/shoe_footstep/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, PROC_REF(stepped))
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(taped))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine_shoes))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))

	var/atom/parent_atom = parent
	parent_atom.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(parent_atom, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/component/shoe_footstep/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_SHOES_STEP_ACTION,
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
	))
	var/atom/parent_atom = parent
	if(ismob(parent_atom.loc))
		REMOVE_TRAIT(parent_atom.loc, TRAIT_SILENT_FOOTSTEPS, REF(src))

/datum/component/shoe_footstep/proc/stepped(obj/item/clothing/shoes/source)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/owner = source.loc
	if(CHECK_MOVE_LOOP_FLAGS(owner, MOVEMENT_LOOP_OUTSIDE_CONTROL))
		return
	if(owner.move_intent == MOVE_INTENT_SNEAK || (owner.movement_type & (VENTCRAWLING|FLYING|FLOATING)))
		return
	if(owner.buckled || owner.throwing || HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return
	if(steps < steps_per_play)
		steps++
		return

	if(prob(chance_per_play))
		playsound(
			source = source,
			soundin = pick(sounds),
			vol = volume,
			vary = TRUE,
			extrarange = extrarange,
			falloff_exponent = falloff_exponent,
			falloff_distance = falloff_distance,
		)
	steps = 0

/datum/component/shoe_footstep/proc/taped(obj/item/clothing/shoes/source, mob/living/user, obj/item/tape, ...)
	SIGNAL_HANDLER

	if(tape_check(tape))
		playsound(source, 'sound/items/duct_tape_snap.ogg', 50, TRUE)
		user.visible_message(
			span_notice("[user] tapes the bottom of [source]'s soles."),
			span_notice("You tape the bottom of [source]'s soles, muffling [source.p_their()] footsteps."),
		)
		source.desc += " [source.p_Their()] soles have been taped."
		qdel(src)
		return ITEM_INTERACT_SUCCESS

	return NONE

/datum/component/shoe_footstep/proc/tape_check(obj/item/tape)
	if(!can_tape)
		return FALSE

	if(istype(tape, /obj/item/clothing/mask/muzzle/tape))
		qdel(tape)
		return TRUE

	if(istype(tape, /obj/item/stack/sticky_tape))
		return tape.use(1)

	return FALSE

/datum/component/shoe_footstep/proc/examine_shoes(obj/item/clothing/shoes/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(can_tape)
		examine_list += span_notice("You could silence the footsteps of [source.p_them()] by <i>taping [source.p_their()] soles</i>.")

/datum/component/shoe_footstep/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if(istype(held_item, /obj/item/clothing/mask/muzzle/tape) || istype(held_item, /obj/item/stack/sticky_tape))
		context[SCREENTIP_CONTEXT_LMB] = "Tape soles"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/datum/component/shoe_footstep/proc/equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot & source.slot_flags)
		ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))

/datum/component/shoe_footstep/proc/dropped(obj/item/source, mob/user, silent)
	SIGNAL_HANDLER
	REMOVE_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, REF(src))
