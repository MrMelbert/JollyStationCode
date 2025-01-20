/mob/living/carbon/throw_mode_off(method)
	. = ..()
	if(throw_mode)
		return
	SEND_SIGNAL(src, COMSIG_CARBON_THROW_OFF)

/mob/living/carbon/throw_mode_on(mode = THROW_MODE_TOGGLE)
	. = ..()
	if(!throw_mode)
		return
	SEND_SIGNAL(src, COMSIG_CARBON_THROW_ON)

/obj/item/restraints/legcuffs/bola
	throw_speed = 1
	throw_range = 1
	/// Number of spins before we reach max power
	var/max_spins = 4
	/// Throw range of bola after max spins
	var/max_range = 7
	/// Throw speed of bola after max spins
	var/max_speed = 3
	/// Base time it takes per spin. Decreases per spin to model momentum.
	var/spin_time = 0.75 SECONDS
	/// Tracks if the bola is actively spinning
	VAR_PRIVATE/is_spinning = FALSE
	/// Trakcs if a throw has been queued with the bola, to prevent resetting stats mid throw
	VAR_PRIVATE/being_thrown = FALSE

/obj/item/restraints/legcuffs/bola/examine(mob/user)
	. = ..()
	. += span_notice("It takes [max_spins] spins to reach its maximum speed and range.")

/obj/item/restraints/legcuffs/bola/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & ITEM_SLOT_HANDS))
		return

	RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(swapped_hands), override = TRUE)
	swapped_hands(user)

/obj/item/restraints/legcuffs/bola/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_CARBON_THROW_ON)
	UnregisterSignal(user, COMSIG_MOB_SWAP_HANDS)
	if(!being_thrown)
		stop_spinning()

/obj/item/restraints/legcuffs/bola/on_thrown(mob/living/carbon/user, atom/target)
	being_thrown = TRUE
	return ..()

/obj/item/restraints/legcuffs/bola/proc/swapped_hands(mob/living/carbon/source)
	SIGNAL_HANDLER

	if(source.get_active_held_item() == src)
		RegisterSignal(source, COMSIG_CARBON_THROW_ON, PROC_REF(throw_enabled), override = TRUE)
	else
		UnregisterSignal(source, COMSIG_CARBON_THROW_ON)
		stop_spinning()

/obj/item/restraints/legcuffs/bola/proc/throw_enabled(mob/living/carbon/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(begin_spinning), source)

/obj/item/restraints/legcuffs/bola/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return .
	if(!iscarbon(user))
		return .
	var/mob/living/carbon/thrower = user
	thrower.throw_mode_off(THROW_MODE_TOGGLE)
	return TRUE

/obj/item/restraints/legcuffs/bola/proc/begin_spinning(mob/living/carbon/spinner)
	if(is_spinning)
		return

	is_spinning = TRUE

	var/range_increment = round((max_range - throw_range) / max_spins, 0.5)
	var/speed_increment = round((max_speed - throw_speed) / max_spins, 0.5)
	var/spin_time_with_momentum = spin_time
	for(var/current_spin in 1 to max_spins)
		spin_time_with_momentum = round(spin_time - (spin_time * 0.33 * (current_spin / max_spins)), 0.5)
		spin_sound(spin_time_with_momentum)
		animate(src, spin_time_with_momentum, transform = transform.Turn(90), easing = (current_spin == 1 ? CUBIC_EASING : NONE)/*, flags = ANIMATION_CONTINUE*/)
		if(!do_after(spinner, spin_time_with_momentum, spinner, timed_action_flags = IGNORE_USER_LOC_CHANGE|IGNORE_SLOWDOWNS, extra_checks = CALLBACK(src, PROC_REF(can_keep_spinning), spinner)))
			stop_spinning()
			return

		throw_range += range_increment
		throw_speed += speed_increment

	var/infi_loop_time = spin_time * 0.8
	while(can_keep_spinning(spinner))
		spin_sound(infi_loop_time)
		animate(src, infi_loop_time, transform = transform.Turn(90)/*, flags = ANIMATION_CONTINUE*/)
		sleep(infi_loop_time)

/obj/item/restraints/legcuffs/bola/proc/can_keep_spinning(mob/living/carbon/spinner)
	return !QDELETED(src) && !QDELETED(spinner) && is_spinning && spinner.throw_mode && spinner.get_active_held_item() == src

/obj/item/restraints/legcuffs/bola/proc/spin_sound(spin_time)
	playsound(src, 'sound/weapons/punchmiss.ogg', 40, vary = TRUE, extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE, frequency = 0.33 SECONDS / spin_time)

/obj/item/restraints/legcuffs/bola/proc/stop_spinning()
	if(!is_spinning)
		return

	is_spinning = FALSE
	throw_range = initial(throw_range)
	throw_speed = initial(throw_speed)
	animate(src)
	transform = null
	being_thrown = FALSE

/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	stop_spinning()
	return ..()
