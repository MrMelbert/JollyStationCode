// Root of all drones. Is abstract and should not be spawned.
/mob/living/basic/reddrone
	name = "drone error"
	desc = "You should not be seeing this error."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/reddrone.dmi'
	icon_state = "rapid_light_flying"
	icon_living = "rapid_light_flying"
	icon_dead = "rapid_light_flying_dead"
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC

	// Armour is optimized for thermal and energy damage.
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, STAMINA = 0, OXY = 0)

	// Most drones are ranged attackers so they don't deal much melee damage.
	melee_damage_lower = 5
	melee_damage_upper = 5

	attack_verb_continuous = "rams"
	attack_verb_simple = "ram"
	attack_sound = 'sound/weapons/genhit1.ogg'
	attack_vis_effect = ATTACK_EFFECT_PUNCH
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	bubble_icon = "machine"

	faction = list(FACTION_DEEPRED)
	combat_mode = TRUE
	speech_span = SPAN_ROBOT
	death_sound = 'sound/voice/borg_deathsound.ogg'
	death_message = "shudders, then falls to the ground, inoperable."

	unsuitable_atmos_damage = 0

	unsuitable_cold_damage = 0
	bodytemp_heat_damage_limit = 800

	var/ranged = TRUE

	var/ranged_cooldown = 6 SECONDS
	var/projectile_type = /obj/projectile/bullet/coil
	var/shoot_sound = 'sound/weapons/gun/smg/shot.ogg'
	var/burst_amount = 4
	var/burst_cooldown = 0.125 SECONDS

	var/flying = TRUE
	// var/list/death_loot

/mob/living/basic/reddrone/Initialize(mapload)
	. = ..()

	if(flying)
		AddElement(/datum/element/simple_flying)

	// AddComponent(/datum/component/basic_mob_attack_telegraph, \telegraph_time = 0.5 SECONDS, \sound_path = 'sound/weapons/laser_crank.ogg')

	if(ranged)
		AddComponent(\
			/datum/component/ranged_attacks,\
			cooldown_time = ranged_cooldown,\
			projectile_type = projectile_type,\
			projectile_sound = shoot_sound,\
			burst_shots = burst_amount,\
			burst_intervals = burst_cooldown,\
		)

	// AddElement(/datum/element/death_drops, death_loot)

/mob/living/basic/reddrone/rapid_flying
	name = "light airborne drone"
	desc = "A small, flying drone. It's equipped with a rapid-fire machinecoil."
	icon_state = "rapid_light_flying"
	icon_living = "rapid_light_flying"
	icon_dead = "rapid_light_flying_dead"

	// Relatively weak armour.
	health = 40
	maxHealth = 40

	//Fast as fuck.
	speed = 0.5

	ai_controller = /datum/ai_controller/basic_controller/rapidlightflying

	// death_loot = list(/obj/item/stock_parts/capacitor/redtech = 1, /obj/item/stock_parts/servo/redtech = 1)
