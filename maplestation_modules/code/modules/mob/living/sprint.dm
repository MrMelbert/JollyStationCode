/atom/movable/screen/mov_intent
	name = "run/walk/sneak cycle"
	desc = "Cycles between move intents. Right click to cycle backwards."
	maptext_width = 64
	maptext_x = 3
	maptext_y = 20
	/// Style applied to the maptext used on the selector
	var/maptext_style = "text-align:center; -dm-text-outline: 1px black"
	/// The sprint bar that appears over the bottom of our move selector
	var/mutable_appearance/sprint_bar

/atom/movable/screen/mov_intent/Click(location, control, params)
	var/list/modifiers = params2list(params)
	cycle_intent(usr, backwards = LAZYACCESS(modifiers, RIGHT_CLICK))

/atom/movable/screen/mov_intent/update_overlays()
	. = ..()
	if(!ishuman(hud?.mymob))
		return

	if(isnull(sprint_bar))
		sprint_bar = mutable_appearance('icons/effects/progressbar.dmi')
		sprint_bar.pixel_y -= 2

	var/mob/living/carbon/human/runner = hud.mymob
	sprint_bar.icon_state = "prog_bar_[round(((runner.sprint_length / runner.sprint_length_max) * 100), 5)]"
	. += sprint_bar

/atom/movable/screen/mov_intent/proc/cycle_intent(mob/living/cycler, backwards = FALSE)
	if(!istype(cycler))
		return

	cycler.toggle_move_intent(cycler, backwards)

/datum/movespeed_modifier/momentum
	movetypes = GROUND
	flags = IGNORE_NOSLOW
	multiplicative_slowdown = -0.1

/mob/living/carbon
	/// If TRUE, we are being affected by run momentum
	var/has_momentum = FALSE
	/// Our last move direction, used for tracking momentum
	var/momentum_dir = NONE
	/// How many tiles we've moved in the momentum direction
	var/momentum_distance = 0

/mob/living/carbon/human
	move_intent = MOVE_INTENT_WALK
	/// How many tiles left in your sprint
	var/sprint_length = 100
	/// How many tiles you can sprint before spending stamina
	var/sprint_length_max = 100
	/// How many tiles you get back per second
	var/sprint_regen_per_second = 0.75

/mob/living/carbon/human/toggle_move_intent()
	. = ..()
	if(!client?.prefs.read_preference(/datum/preference/toggle/sound_combatmode))
		return
	if(move_intent == MOVE_INTENT_RUN)
		playsound_local(get_turf(src), 'maplestation_modules/sound/sprintactivate.ogg', 75, vary = FALSE, pressure_affected = FALSE)
	else
		playsound_local(get_turf(src), 'maplestation_modules/sound/sprintdeactivate.ogg', 75, vary = FALSE, pressure_affected = FALSE)

/mob/living/carbon/human/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return
	if(move_intent == MOVE_INTENT_RUN || sprint_length >= sprint_length_max)
		return

	adjust_sprint_left(sprint_regen_per_second * seconds_per_tick * (body_position == LYING_DOWN ? 2 : 1))

/mob/living/carbon/proc/adjust_sprint_left(amount)
	return

/mob/living/carbon/human/adjust_sprint_left(amount)
	sprint_length = clamp(sprint_length + amount, 0, sprint_length_max)
	for(var/atom/movable/screen/mov_intent/selector in hud_used?.static_inventory)
		selector.update_appearance(UPDATE_OVERLAYS)

/mob/living/carbon/proc/drain_sprint()
	return

/mob/living/carbon/human/drain_sprint()
	adjust_sprint_left(-1)
	// Sprinting when out of sprint will cost stamina
	if(sprint_length > 0)
		return

	// Okay you're gonna stamcrit yourself, slow your roll
	if(getStaminaLoss() >= maxHealth * 0.9)
		set_move_intent(MOVE_INTENT_WALK)
		return

	adjustStaminaLoss(1)

/mob/living/carbon/human/fully_heal(heal_flags)
	. = ..()
	if(heal_flags & (HEAL_ADMIN|HEAL_STAM|HEAL_CC_STATUS))
		adjust_sprint_left(INFINITY)

// Minor stamina regeneration effects, such as stimulants, will replenish sprint capacity
/mob/living/carbon/human/adjustStaminaLoss(amount, updating_stamina, forced, required_biotype)
	. = ..()
	if(amount < 0 && amount >= -20)
		adjust_sprint_left(amount * 0.25)

// Entering stamina critical will drain your sprint capacity entirely
/mob/living/carbon/human/enter_stamcrit()
	. = ..()
	if(HAS_TRAIT_FROM(src, TRAIT_FLOORED, STAMINA))
		adjust_sprint_left(-INFINITY)
