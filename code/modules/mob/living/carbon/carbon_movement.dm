/mob/living/carbon/slip(knockdown_amount, obj/slipped_on, lube_flags, paralyze, force_drop = FALSE)
	if(movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return FALSE
	if(!(lube_flags & SLIDE_ICE))
		log_combat(src, (slipped_on || get_turf(src)), "slipped on the", null, ((lube_flags & SLIDE) ? "(SLIDING)" : null))
	..()
	return loc.handle_slip(src, knockdown_amount, slipped_on, lube_flags, paralyze, force_drop)

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(!. || (movement_type & FLOATING)) //floating is easy
		return
	if(stat == DEAD)
		return

	if(nutrition > 0)
		var/hunger_loss = HUNGER_FACTOR * MOVEMENT_HUNGER_MULTIPLIER
		if(move_intent == MOVE_INTENT_RUN)
			hunger_loss *= 2
		adjust_nutrition(-1 * hunger_loss)

	// NON-MODULE CHANGE START
	if(!moving_diagonally)
		SEND_SIGNAL(src, COMSIG_CARBON_STEP, NewLoc, direct)

	if(move_intent == MOVE_INTENT_RUN && !(movement_type & FLYING) && (mobility_flags & (MOBILITY_MOVE|MOBILITY_STAND)) && !pulledby)
		drain_sprint()
	if(momentum_dir & direct)
		momentum_distance++
		if(!has_momentum && momentum_distance >= 4 && add_movespeed_modifier(/datum/movespeed_modifier/momentum))
			has_momentum = TRUE
	else
		momentum_dir = direct
		momentum_distance = 0
		if(has_momentum && remove_movespeed_modifier(/datum/movespeed_modifier/momentum))
			has_momentum = FALSE
	// NON-MODULE CHANGE END

// NON-MODULE CHANGE START
/mob/living/carbon/set_usable_hands(new_value)
	. = ..()
	if(isnull(.))
		return
	if(. == 0)
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
	else if(usable_hands == 0 && default_num_hands > 0) //From having usable hands to no longer having them.
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)

/mob/living/carbon/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	. = ..()
	if(movement_type & (FLYING | FLOATING) && !(old_movement_type & (FLYING | FLOATING)))
		update_limbless_locomotion()
		update_limbless_movespeed_mod()

/mob/living/carbon/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	. = ..()
	if(old_movement_type & (FLYING | FLOATING) && !(movement_type & (FLYING | FLOATING)))
		update_limbless_locomotion()
		update_limbless_movespeed_mod()
// NON-MODULE CHANGE END
