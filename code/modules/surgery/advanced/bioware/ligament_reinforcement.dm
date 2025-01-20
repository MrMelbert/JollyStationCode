/datum/surgery/advanced/bioware/ligament_reinforcement
	name = "Ligament Reinforcement"
	desc = "A surgical procedure which adds a protective tissue and bone cage around the connections between the torso and limbs, preventing dismemberment. \
		However, the nerve connections as a result are more easily interrupted, making it easier to disable limbs with damage."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/reinforce_ligaments,
		/datum/surgery_step/close,
	)

	bioware_target = BIOWARE_LIGAMENTS

/datum/surgery_step/reinforce_ligaments
	name = "reinforce ligaments (hand)"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/reinforce_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start reinforcing [target]'s ligaments."),
		span_notice("[user] starts reinforce [target]'s ligaments."),
		span_notice("[user] starts manipulating [target]'s ligaments."),
	)
	display_pain(
		target = target,
		target_zone = BODY_ZONES_LIMBS,
		pain_message = "Your limbs burn with severe pain!",
		pain_amount = SURGERY_PAIN_LOW,
		pain_type = BURN,
		pain_overlay_severity = 2,
		surgery_moodlet = /datum/mood_event/surgery/major,
	)

/datum/surgery_step/reinforce_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("You reinforce [target]'s ligaments!"),
		span_notice("[user] reinforces [target]'s ligaments!"),
		span_notice("[user] finishes manipulating [target]'s ligaments."),
	)
	display_pain(
		target = target,
		target_zone = BODY_ZONES_LIMBS,
		pain_message = "Your limbs feel more secure, but also more frail.",
		surgery_moodlet = /datum/mood_event/surgery/major,
	)
	new /datum/bioware/reinforced_ligaments(target)
	return ..()

/datum/bioware/reinforced_ligaments
	name = "Reinforced Ligaments"
	desc = "The ligaments and nerve endings that connect the torso to the limbs are protected by a mix of bone and tissues, and are much harder to separate from the body, but are also easier to wound."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/reinforced_ligaments/on_gain()
	..()
	owner.add_traits(list(TRAIT_NODISMEMBER, TRAIT_EASILY_WOUNDED), EXPERIMENTAL_SURGERY_TRAIT)

/datum/bioware/reinforced_ligaments/on_lose()
	..()
	owner.remove_traits(list(TRAIT_NODISMEMBER, TRAIT_EASILY_WOUNDED), EXPERIMENTAL_SURGERY_TRAIT)
