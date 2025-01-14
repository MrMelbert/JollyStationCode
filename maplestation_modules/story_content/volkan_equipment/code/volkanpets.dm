//HOLY MOLY WHAT DID I GET MYSELF INTO??
/*
 * # Volkan's companion.
 * A cool pet for volkan! Basically a better poly. Quiet, efficient, and will sit on his shoulder all the time.
 */
/mob/living/basic/volkan/shoulder_pet
	name = "Companion"
	desc = "An intricate, flying robot. It looks at you inquisitively."

	icon = 'maplestation_modules/story_content/volkan_equipment/icons/companions.dmi'
	held_rh = 'maplestation_modules/story_content/volkan_equipment/icons/companions_inhand_rh.dmi'
	held_lh = 'maplestation_modules/story_content/volkan_equipment/icons/companions_inhand_lh.dmi'
	icon_state = "drone_fly"
	icon_living = "drone_fly"
	icon_dead = "drone_dead"
	held_state = "shoulder_pet"
	bubble_icon = "machine"

	has_unlimited_silicon_privilege = TRUE
	sentience_type = SENTIENCE_ARTIFICIAL
	mob_biotypes = MOB_ROBOTIC
	speech_span = SPAN_ROBOT
	gender = NEUTER
	density = FALSE
	health = 80
	maxHealth = 80
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_be_held = TRUE
	held_w_class = WEIGHT_CLASS_SMALL

	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
	bodytemp_cold_damage_limit = -1
	unsuitable_atmos_damage = 0 //temperature robust

	melee_damage_upper = 5 //It is weak sauce.
	melee_damage_lower = 1

	response_help_continuous = "pets"
	response_help_simple = "pet"
	attack_verb_continuous = "slams into"
	attack_verb_simple = "slam into"
	attack_sound = 'sound/weapons/etherealhit.ogg'

	ai_controller = /datum/ai_controller/basic_controller/volkan/shoulder_pet

	//The drone shall be able to perch on things.
	var/icon_sit = "drone_perch"
	/// Contains all of the perches that the drone will sit on.
	var/static/list/desired_perches = typecacheof(list(
		/obj/machinery/dna_scannernew,
		/obj/machinery/nuclearbomb,
		/obj/machinery/recharge_station,
		/obj/machinery/suit_storage_unit,
		/obj/structure/displaycase,
		/obj/structure/filingcabinet,
		/obj/structure/rack,
	))
	//The command list
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/perch,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/fetch,
	)


/mob/living/basic/volkan/shoulder_pet/Initialize(mapload)
	. = ..()
	ai_controller.set_blackboard_key(BB_PARROT_PERCH_TYPES, desired_perches)// uses parrot code to perch

	AddElement(/datum/element/simple_flying) //The thing flys.
	AddComponent(/datum/component/tameable, \
		food_types = list(/obj/item/circuitboard/volkan/imprint_key,), \
		tame_chance = 100, \
		bonus_tame_chance = 15, \
		after_tame = CALLBACK(src, PROC_REF(tamed)), \
		unique = FALSE)
	AddComponent(/datum/component/obeys_commands, pet_commands) // follows pet command



///Proc to run once imprinted
/mob/living/basic/volkan/shoulder_pet/proc/tamed(mob/living/tamer)
	visible_message(span_notice("[src] beeps and turns its head toward [tamer] with its head tilted."))

/*
 * # The Vroomba!
 * A roomba, that has combat functionality! It will have two modes, cleaner mode, which is similar to a cleanbot, and combat mode, where it will float and have various attacks, and have telekinesis!
 */

//lines it can say
#define VROOMBA_LAUGH "makes a robotic laughing sound!*"
#define VROOMBA_ACCEPT "Accepted."
#define VROOMBA_DECLINE "Declined."
#define VROOMBA_STOP "makes an annoyed sounding whine.*"
#define VROOMBA_CHATTER "makes a happy chattering noise!*"

/mob/living/basic/bot/cleanbot/vroomba
	name = "\improper Strange Roomba"
	desc = "A little cleaning robot, So circular! It looks like it is out of plasteel."
	icon = 'maplestation_modules/story_content/volkan_equipment/icons/companions.dmi'
	base_icon_state = "vroomba2_drive"
	icon_state = "vroomba2_drive"
	icon_living = "vroomba2_drive"
	base_icon = "vroomba2_drive"
	pass_flags = PASSMOB | PASSFLAPS | PASSTABLE
	density = FALSE
	anchored = FALSE
	layer = ABOVE_NORMAL_TURF_LAYER

	health = 100
	maxHealth = 100
	damage_coeff = list(BRUTE = 0.7, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0) //It's secretly a combat drone. This thing is tanky.

	melee_damage_upper = 5
	melee_damage_lower = 1

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_JANITOR, ACCESS_ENGINEERING)
	radio_key = /obj/item/encryptionkey/ai
	radio_channel = RADIO_CHANNEL_SERVICE
	bot_type = CLEAN_BOT
	hackables = " software"
	additional_access = /datum/id_trim/job/janitor
	possessed_message = "You are a roomba! Clean the station to the best of your ability! Protect your master! Don't let anybody boss YOU around!"
	ai_controller = /datum/ai_controller/basic_controller/bot/cleanbot
	path_image_color = "#ddda2a"

	hud_type = /datum/hud/vroomba

	melee_damage_lower = 10
	melee_damage_upper = 20
	///basic hat offset
	var/static/list/hat_offsets = list(0,-9)

	///the icon state for when it is flying
	var/flying_icon = "vroomba2_float"

	///speed it goes in combat mode. lower is faster.
	var/combat_speed = 0.5

	///50 percent chance to drop a special item...
	var/tractor_field = /obj/item/organ/internal/cyberimp/chest/tractorfield

	///the sound the vroomba makes when entering combat mode.
	var/combat_sound = 'maplestation_modules/story_content/volkan_equipment/audio/vroomba_combat_mode.ogg'

	///player chosen sounds the Vroomba can make.
	var/static/list/announcements = list(
		VROOMBA_LAUGH = 'maplestation_modules/story_content/volkan_equipment/audio/vroomba_laugh.ogg',
		VROOMBA_ACCEPT = 'maplestation_modules/story_content/volkan_equipment/audio/vroomba_accept.ogg',
		VROOMBA_DECLINE = 'maplestation_modules/story_content/volkan_equipment/audio/vroomba_decline.ogg',
		VROOMBA_STOP = 'maplestation_modules/story_content/volkan_equipment/audio/vroomba_stop.ogg',
		VROOMBA_CHATTER = 'maplestation_modules/story_content/volkan_equipment/audio/vroomba_chatter.ogg',
	)

/mob/living/basic/bot/cleanbot/vroomba/Initialize(mapload)
	. = ..()
	qdel(GetComponent(/datum/component/cleaner)) //we don't want the default cleaner because it doesn't have the stuff we want (doesnt remove itself when in combat mode)

	AddElement(/datum/element/dextrous)
	AddComponent(/datum/component/basic_inhands)

	change_number_of_hands(0) //it only has hands when it is in combat mode, so start with no usable hands while still having the components

	AddElement(/datum/element/hat_wearer,\
		offsets = hat_offsets,)

	AddComponent(/datum/component/cleaner/vroomba, \
		base_cleaning_duration = 2 SECONDS, \
		pre_clean_callback = CALLBACK(src, PROC_REF(update_bot_mode), BOT_CLEANING), \
		on_cleaned_callback = CALLBACK(src, PROC_REF(update_bot_mode), BOT_IDLE), \
		)
	prepare_huds()

//it will not get job titles like cleanbots.
/mob/living/basic/bot/cleanbot/vroomba/update_title(new_job_title)
	return

//boom boom
/mob/living/basic/bot/cleanbot/vroomba/explode()
	visible_message(span_boldnotice("[src] blows apart!"))
	do_sparks(3, TRUE, src)
	explosion(src, heavy_impact_range = 0, light_impact_range = 4)

	var/atom/location_destroyed = drop_location()
	if(prob(50))
		drop_part(tractor_field, location_destroyed)

//the sprite doesn't show up unless I do this
/mob/living/basic/bot/cleanbot/vroomba/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)

/mob/living/basic/bot/cleanbot/vroomba/set_combat_mode(new_mode, silent)
	. = ..()
	SEND_SIGNAL(src, COMSIG_COMBAT_MODE)
	if(combat_mode)
		go_angry()
	else
		calm_down()

	prepare_huds()

///The vroomba activating its hidden combat capabilities!
/mob/living/basic/bot/cleanbot/vroomba/proc/go_angry()
	icon_state = flying_icon
	set_varspeed(combat_speed)
	layer = MOB_LAYER

	ADD_TRAIT(src, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))

	AddComponent(/datum/component/tractorfield/vroomba) //this one removes itself when it is not in combat mode to avoid bugs. :)

	change_number_of_hands(2)

	balloon_alert_to_viewers("gravity shifts!", vision_distance = 4) //When it turns on, it will make gravity feel funny.
	playsound(src, combat_sound, 70, ignore_walls = FALSE)


///the vroomba hiding its combat capabilities!
/mob/living/basic/bot/cleanbot/vroomba/proc/calm_down()
	icon_state = base_icon_state
	set_varspeed(3)
	layer = ABOVE_NORMAL_TURF_LAYER

	AddComponent(/datum/component/cleaner/vroomba, \
		base_cleaning_duration = 2 SECONDS, \
		pre_clean_callback = CALLBACK(src, PROC_REF(update_bot_mode), BOT_CLEANING), \
		on_cleaned_callback = CALLBACK(src, PROC_REF(update_bot_mode), BOT_IDLE), \
	)
	REMOVE_TRAIT(src, TRAIT_MOVE_FLYING, ELEMENT_TRAIT(type))

	change_number_of_hands(0)

///The vroomba is not killed by EMPs but it does stun it for a short moment.
/mob/living/basic/bot/cleanbot/vroomba/emp_act(severity)
	. = ..()
	switch(severity)
		if(EMP_LIGHT)
			visible_message(span_danger("[src] jitters, but is unharmed!"))
			Stun(0.5 SECONDS)
			Shake(duration = 0.5 SECONDS)
		if(EMP_HEAVY)
			visible_message(span_danger("[src] readjusts some servos!"))
			Stun(3 SECONDS)
			Shake(duration = 3 SECONDS)
	to_chat(src, span_danger("WARN: EMP DETECTED."))

/mob/living/basic/bot/cleanbot/vroomba/generate_speak_list()
	var/static/list/finalized_speak_list = (announcements)
	return finalized_speak_list

//default one doesn't work as intended.
/mob/living/basic/bot/cleanbot/vroomba/change_number_of_hands(amt)
	if(amt < held_items.len)
		if(amt == 0)
			for(var/i in held_items.len to amt+1 step -1)
				dropItemToGround(held_items[i])
		else
			for(var/i in held_items.len to amt step -1)
				dropItemToGround(held_items[i])
	held_items.len = amt
	if(hud_used)
		hud_used.build_hand_slots()

//default one sprays acid on people, this removes it.
/mob/living/basic/bot/cleanbot/vroomba/pre_attack(mob/living/source, atom/target, proximity, modifiers)
	if(!proximity || !can_unarmed_attack())
		return NONE

	if(is_type_in_typecache(target, huntable_pests) && !isnull(our_mop))
		INVOKE_ASYNC(our_mop, TYPE_PROC_REF(/obj/item, melee_attack_chain), src, target)
		target.acid_act(75, 10)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!iscarbon(target) && !is_type_in_typecache(target, huntable_trash))
		return NONE

	if(combat_mode)
		melee_attack(target)

	return NONE

/mob/living/basic/bot/cleanbot/vroomba/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
		. = ..()
		visible_message(span_danger("[src] flies into [target]!"))
