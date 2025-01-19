// vvvvv ABILITIES THAT CAN BE USED IN ANY MODE vvvvv
/datum/action/cooldown/mob_cooldown/high_energy
	name = "Activate High Energy Mode"
	desc = "Activate High Energy Mode. Your cloak will need to be off to use this."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_power"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 10 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/high_energy/Activate(atom/target)
	var/mob/living/basic/redtechdread/ownercast = owner

	if(ownercast.neck) // Cloak on.
		owner.balloon_alert(owner, "you cannot enter high energy mode while your cloak is on")
		return FALSE

	if(ownercast.energy_level == 2) // In RL energy mode.
		owner.balloon_alert(owner, "you cannot enter low energy mode while in RL energy mode")
		return FALSE

	if(ownercast.energy_level == 1) // In high energy mode.
		owner.balloon_alert(owner, "you slow and and enter low energy mode")
		ownercast.energy_level = 0
		ownercast.update_base_stats()
		StartCooldown()
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(1, holder = owner, location = owner.loc)
		smoke.start()
		playsound(ownercast, 'sound/machines/clockcult/steam_whoosh.ogg', 120)
		ownercast.visible_message(span_warning("[ownercast] slows down to a crawl..."))
		return TRUE

	if(ownercast.RLEnergy < 0) // Negative RL energy.
		owner.balloon_alert(owner, "you need to wait for your red lightning energy to recharge")
		return FALSE

	owner.balloon_alert(owner, "you speed up and enter high energy mode")
	ownercast.energy_level = 1
	ownercast.update_base_stats()
	StartCooldown()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(1, holder = owner, location = owner.loc)
	smoke.start()
	playsound(ownercast, 'sound/mecha/hydraulic.ogg', 120)
	ownercast.visible_message(span_boldwarning("[ownercast] unfolds their form and speeds up!"))
	ownercast.apply_damage(-200) // Second phase moment.
	return TRUE

/datum/action/cooldown/mob_cooldown/lightning_energy
	name = "Activate Red Lightning Energy Mode"
	desc = "Activate Red Lightning Energy Mode. Needs to be at high energy to use this."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_radioactive"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 10 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/lightning_energy/Activate(atom/target)
	var/mob/living/basic/redtechdread/ownercast = owner

	if(ownercast.neck) // Cloak on.
		owner.balloon_alert(owner, "you cannot enter red lightning energy mode while your cloak is on")
		return FALSE

	if(!ownercast.back_storage)
		owner.balloon_alert(owner, "you need to have a red lightning canister to enter red lightning energy mode")
		return FALSE

	if(ownercast.energy_level == 0) // In low energy mode.
		owner.balloon_alert(owner, "you need to be in high energy mode to enter red lightning energy mode")
		return FALSE

	if(ownercast.RLEnergy < 0) // Negative RL energy.
		if(ownercast.energy_level == 2) // But already in RL energy mode.
			owner.balloon_alert(owner, "you slow and and enter low energy mode due to lack of red lightning energy")
			ownercast.energy_level = 0
			ownercast.update_base_stats()
			StartCooldown()
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(1, holder = owner, location = owner.loc)
			smoke.start()
			playsound(ownercast, 'sound/machines/clockcult/steam_whoosh.ogg', 120)
			ownercast.visible_message(span_warning("[ownercast] slows down to a crawl..."))
			return TRUE

		owner.balloon_alert(owner, "you need to wait for your red lightning energy to recharge")
		return FALSE

	if(ownercast.energy_level == 2) // In RL energy mode.
		owner.balloon_alert(owner, "you cool down and enter high energy mode")
		ownercast.energy_level = 1
		ownercast.update_base_stats()
		StartCooldown()
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(1, holder = owner, location = owner.loc)
		smoke.start()
		playsound(ownercast, 'sound/mecha/hydraulic.ogg', 120)
		ownercast.visible_message(span_warning("[ownercast] cools down..."))
		return TRUE

	owner.balloon_alert(owner, "you heat up and enter red lightning energy mode!")
	ownercast.energy_level = 2
	ownercast.update_base_stats()
	StartCooldown()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(1, holder = owner, location = owner.loc)
	smoke.start()
	playsound(ownercast, 'sound/mecha/skyfall_power_up.ogg', 120)
	ownercast.visible_message(span_alertwarning("[ownercast] heats up and crackles with red lightning!"))
	ownercast.apply_damage(-200) // Third phase moment.
	return TRUE

/datum/action/access_printer
	name = "Access Redtech Printer"
	desc = "Access the Redtech Printer to print out items."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_info"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"

/datum/action/access_printer/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/mob/living/basic/redtechdread/ownercast = owner

	if(!ownercast.back_storage)
		owner.balloon_alert(owner, "you need to have a red lightning canister to print items")
		return FALSE

	var/item_to_spawn = input("Item to fabricate (+ number to fabricate)?", "Item:", null) as text|null

	if(!item_to_spawn)
		return FALSE

	if(!ownercast.belt_storage)
		return FALSE

	var/list/preparsed = splittext(item_to_spawn,":")
	var/path = preparsed[1]
	var/amount = 1
	if(preparsed.len > 1)
		amount = clamp(text2num(preparsed[2]),1,ADMIN_SPAWN_CAP)

	var/chosen = pick_closest_path(path)
	if(!chosen)
		return

	var/turf/T = get_turf(usr)

	if(ispath(chosen, /turf))
		T.ChangeTurf(chosen)
	else
		if(ispath(chosen, /obj))
			var/storage = ownercast.belt_storage
			for(var/i in 1 to amount)
				new chosen(storage)
		else
			for(var/i in 1 to amount)
				new chosen(T)

/datum/action/cooldown/mob_cooldown/dreadscan
	name = "Ranged Scan"
	desc = "Scan a target from a distance."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_scan"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 10 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/dreadscan/Activate(atom/target_atom)
	var/mob/living/basic/redtechdread/ownercast = owner
	playsound(ownercast, 'sound/machines/clockcult/stargazer_activate.ogg', 120)

	var/mutable_appearance/scan_effect = mutable_appearance('maplestation_modules/story_content/deepred_warfare/icons/dreadscan.dmi', "scan")
	ownercast.add_overlay(scan_effect)
	ownercast.visible_message(span_warning("[ownercast] scans [target_atom]..."))

	StartCooldown()
	if(!do_after(ownercast, 5 SECONDS))
		ownercast.balloon_alert(ownercast, "cancelled")
		StartCooldown(cooldown_time * 0.2)
		ownercast.cut_overlay(scan_effect)
		playsound(ownercast, 'sound/machines/scanbuzz.ogg', 40)
		return TRUE

	if(istype(target_atom, /mob/living))
		healthscan(ownercast, target_atom, advanced = TRUE)
	ownercast.cut_overlay(scan_effect)
	playsound(ownercast, 'sound/machines/ping.ogg', 40)
	return TRUE

/datum/action/cooldown/mob_cooldown/faraday_shield
	name = "Activate Faraday Shield"
	desc = "Activate a Faraday Shield to protect yourself from electromagnetic and thermal damage."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_shield"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 10 SECONDS // Cooldown time jumps if the shield is destroyed.
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE

	var/maxhits = 1
	var/hits = 0

/datum/action/cooldown/mob_cooldown/faraday_shield/Activate(atom/target)
	var/mob/living/basic/redtechdread/ownercast = owner

	if(ownercast.RLEnergy < 0) // Negative RL energy.
		if(ownercast.shielding_level == 0) // Shield not on.
			owner.balloon_alert(owner, "you need to wait for your red lightning energy to recharge")
			return FALSE

	if(ownercast.shielding_level > 0) // Shield on.
		owner.balloon_alert(owner, "you turn off your Faraday Shield")
		ownercast.updating_shield(0) // Turn off shield.
		playsound(ownercast, 'sound/mecha/mech_shield_drop.ogg', 120)
		ownercast.visible_message(span_warning("[ownercast] turns off their shield."))
		StartCooldown()
		return TRUE

	ownercast.updating_shield(ownercast.energy_level + 1) // Turn on shield to correct level based on energy level.
	playsound(ownercast, 'sound/mecha/mech_shield_raise.ogg', 120)
	ownercast.visible_message(span_boldwarning("[ownercast] activates their shield!"))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/faraday_shield/proc/update_shield_stats()
	var/mob/living/basic/redtechdread/ownercast = owner
	switch(ownercast.shielding_level)
		if(0)
			maxhits = 1
			hits = 0
		if(1)
			maxhits = 1
			hits = 0
		if(2)
			maxhits = 2
			hits = 0
		if(3)
			maxhits = 3
			hits = 0

/datum/action/cooldown/mob_cooldown/faraday_shield/proc/take_hit()
	var/mob/living/basic/redtechdread/ownercast = owner
	hits += 1

	if(hits < maxhits)
		playsound(ownercast, 'sound/effects/glass_step.ogg', 240)
		ownercast.visible_message(span_boldwarning("[ownercast]'s shielding cracks!"))
		return

	break_shield()

/datum/action/cooldown/mob_cooldown/faraday_shield/proc/break_shield()
	var/mob/living/basic/redtechdread/ownercast = owner

	playsound(ownercast, 'sound/effects/glassbr3.ogg', 240)
	playsound(ownercast, 'sound/mecha/mech_shield_drop.ogg', 120)

	StartCooldown((2 * maxhits) MINUTES)

	ownercast.balloon_alert(ownercast, "your Faraday Shield has been destroyed!")
	ownercast.visible_message(span_boldwarning("[ownercast]'s shielding shatters like glass!"))

	hits = 0
	ownercast.adjust_RL_energy_or_damage(-20)
	ownercast.updating_shield(0)

// vvvvv ABILITIES THAT CAN BE USED IN LOW ENERGY MODE ONLY vvvvv
/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet
	name = "Fire Volleycoil - Low Power"
	desc = "Fire your head mounted coilgun. Your mask needs to be off for this to work."
	cooldown_time = 10 SECONDS // Prone to change.
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_network" // Looks kinda like a revolver chamber.
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	shared_cooldown = NONE

	projectile_type = /obj/projectile/bullet/coil
	projectile_sound = 'sound/weapons/gun/revolver/shot.ogg'
	default_projectile_spread = 0
	shot_count = 7 // 7 barrels total.
	shot_delay = 0.1 SECONDS // Prone to change.

	var/chargeup_time = 3 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet/Activate(atom/target_atom)
	var/mob/living/basic/redtechdread/ownercast = owner

	if(ownercast.head) // Wearing mask, abort.
		ownercast.balloon_alert(ownercast, "your mask needs to be off to do this!")
		return FALSE

	playsound(ownercast, 'sound/mecha/skyfall_power_up.ogg', 120)
	ownercast.visible_message(span_boldwarning("[ownercast] charges up their head mounted coilgun..."))

	if(!do_after(ownercast, chargeup_time))
		ownercast.balloon_alert(ownercast, "cancelled")
		StartCooldown(cooldown_time * 0.2)
		playsound(ownercast, 'sound/machines/scanbuzz.ogg', 120)
		return TRUE

	. = ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet/attack_sequence(mob/living/firer, atom/target)
	for(var/i in 1 to shot_count)
		playsound(get_turf(firer), projectile_sound, 30, TRUE)
		shoot_projectile(firer, target, null, firer, rand(-default_projectile_spread, default_projectile_spread), null)
		SLEEP_CHECK_DEATH(shot_delay, src)

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dread
	name = "Charge - Low Power"
	desc = "Charge at your target. Will not destroy objects."
	cooldown_time = 30 SECONDS
	charge_delay = 2.5 SECONDS
	charge_distance = 4
	melee_cooldown_time = 0
	shake_duration = 2 SECONDS
	shake_pixel_shift = 1
	recoil_duration = 0.5 SECONDS
	knockdown_duration = 1 SECONDS
	charge_damage = 20
	destroy_objects = FALSE
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_exclamation"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dread/Activate(atom/target_atom)
	var/mob/living/basic/redtechdread/ownercast = owner
	playsound(ownercast, 'sound/machines/clockcult/steam_whoosh.ogg', 120)
	ownercast.visible_message(span_boldwarning("[ownercast] builds up energy, ready to charge..."))
	. = ..()

/datum/action/cooldown/mob_cooldown/dreadrepair
	name = "Self Repair - Efficient"
	desc = "Conduct a self repair. More efficient but slower."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_repair"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 2 SECONDS
	var/doafter_time = 10 SECONDS
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE
	var/heal_amount = 100
	var/energy_cost = 50

/datum/action/cooldown/mob_cooldown/dreadrepair/Activate(atom/target_atom)
	var/mob/living/basic/redtechdread/ownercast = owner
	playsound(ownercast, 'sound/mecha/hydraulic.ogg', 120)
	ownercast.visible_message(span_warning("[ownercast] conducts a self repair..."))

	if(!do_after(ownercast, doafter_time))
		ownercast.balloon_alert(ownercast, "cancelled")
		StartCooldown(cooldown_time * 0.2)
		playsound(ownercast, 'sound/machines/scanbuzz.ogg', 120)
		return TRUE

	ownercast.adjustBruteLoss(-heal_amount)
	ownercast.adjust_RL_energy_or_damage(-energy_cost)
	playsound(ownercast, 'sound/machines/ping.ogg', 120)
	StartCooldown(cooldown_time)
	return TRUE

/datum/action/cooldown/mob_cooldown/heatburst
	name = "Purge Heat"
	desc = "Purposefully vent heat from your heatsinks to deal damage to nearby enemies."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_bomb"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 3 MINUTES
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE
	var/firesize = 2
	var/doafter_time = 2 SECONDS

/datum/action/cooldown/mob_cooldown/heatburst/Activate(atom/target_atom)
	var/mob/living/basic/redtechdread/ownercast = owner
	playsound(ownercast, 'sound/machines/clockcult/stargazer_activate.ogg', 120)
	ownercast.visible_message(span_alertwarning("[ownercast]'s heatsink vents blaze with to life..."))

	if(!do_after(ownercast, doafter_time))
		ownercast.balloon_alert(ownercast, "cancelled")
		StartCooldown(cooldown_time * 0.2)
		playsound(ownercast, 'sound/machines/scanbuzz.ogg', 120)
		return TRUE

	playsound(ownercast, 'sound/machines/clockcult/ark_damage.ogg', 120)
	StartCooldown(cooldown_time)
	ownercast.adjust_RL_energy(50) // Return some energy.
	INVOKE_ASYNC(src, PROC_REF(complete_burnoff), get_turf(owner), firesize)

/datum/action/cooldown/mob_cooldown/heatburst/proc/complete_burnoff(atom/centre, firesize = 1)
	for(var/i in 0 to firesize)
		for(var/turf/nearby_turf as anything in spiral_range_turfs(i + 1, centre))
			new /obj/effect/hotspot(nearby_turf)
			nearby_turf.hotspot_expose(750, 50, 1)
			for(var/mob/living/fried_living in nearby_turf.contents - owner)
				fried_living.apply_damage(5, BURN)

		stoplag(0.3 SECONDS)

// vvvvv ABILITIES THAT CAN BE USED IN HIGH ENERGY MODE ONLY vvvvv
/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet/high
	name = "Fire Volleycoil - High Power"
	cooldown_time = 20 SECONDS // Prone to change.

	projectile_type = /obj/projectile/bullet/coil/highvelo
	projectile_sound = 'sound/weapons/gun/sniper/shot.ogg'
	default_projectile_spread = 5

	chargeup_time = 4 SECONDS

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dread/high
	name = "Charge - High Power"
	desc = "Charge at your target. Will destroy objects."
	charge_delay = 3 SECONDS
	charge_distance = 6
	shake_duration = 2.5 SECONDS
	shake_pixel_shift = 1
	recoil_duration = 1 SECONDS
	knockdown_duration = 1.5 SECONDS
	charge_damage = 30
	destroy_objects = TRUE
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_exclamation"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/dreadrepair/high
	name = "Self Repair - Normal"
	desc = "Conduct a self repair. Normal efficiency."
	cooldown_time = 10 SECONDS
	doafter_time = 5 SECONDS
	heal_amount = 100
	energy_cost = 50

/datum/action/cooldown/mob_cooldown/heatburst/high
	name = "Purge Heat - Overcharge"
	desc = "Purposefully overcharge your heatsinks to deal damage to nearby enemies."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_bomb"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	cooldown_time = 3 MINUTES
	melee_cooldown_time = 0 SECONDS
	click_to_activate = FALSE
	shared_cooldown = NONE
	firesize = 4
	doafter_time = 5 SECONDS

// vvvvv ABILITIES THAT CAN ONLY BE USED IN RL MODE ONLY vvvvv
/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet/lightning
	name = "Fire Volleycoil - Overcharge"
	cooldown_time = 30 SECONDS // Prone to change.

	projectile_type = /obj/projectile/bullet/coil/red_lightning
	projectile_sound = 'sound/weapons/gun/hmg/hmg.ogg'
	default_projectile_spread = 15

	chargeup_time = 5 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/rapid_fire/dreadBullet/lightning/attack_sequence(mob/living/firer, atom/target)
	var/mob/living/basic/redtechdread/ownercast = firer
	ownercast.adjust_RL_energy_or_damage(-20) // Yummy energy.
	. = ..()

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dread/lightning
	name = "Charge - Overcharge"
	desc = "Charge at your target with the power of red lightning. Will destroy objects and deal more damage."
	charge_delay = 4 SECONDS
	charge_distance = 8
	shake_duration = 3 SECONDS
	shake_pixel_shift = 2
	recoil_duration = 1.5 SECONDS
	knockdown_duration = 2 SECONDS
	charge_damage = 40
	destroy_objects = TRUE
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "bci_exclamation"
	background_icon_state = "bg_tech"
	overlay_icon_state = "bg_tech_border"
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/charge/basic_charge/dread/lightning/Activate(atom/target_atom)
	var/mob/living/basic/redtechdread/ownercast = owner
	ownercast.adjust_RL_energy_or_damage(-30)
	. = ..()

/datum/action/cooldown/mob_cooldown/dreadrepair/lightning
	name = "Self Repair - Overcharge"
	desc = "Conduct a self repair. Less efficient but faster."
	cooldown_time = 30 SECONDS
	doafter_time = 2 SECONDS
	heal_amount = 100
	energy_cost = 25

// Godslayer fabrication and fire replacement here.
