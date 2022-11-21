/datum/surgery/advanced/bioware/ligament_reinforcement
	name = "Ligament Reinforcement"
	desc = "A surgical procedure which adds a protective tissue and bone cage around the connections between the torso and limbs, preventing dismemberment. \
	However, the nerve connections as a result are more easily interrupted, making it easier to disable limbs with damage."
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/reinforce_ligaments,
		/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_LIGAMENTS

/datum/surgery_step/reinforce_ligaments
	name = "reinforce ligaments"
	accept_hand = TRUE
	time = 125
	surgery_moodlet = /datum/mood_event/surgery/major
	pain_overlay_severity = 2
	pain_amount = 10
	pain_type = BURN

/datum/surgery_step/reinforce_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You start reinforcing [target]'s ligaments."),
		span_notice("[user] starts reinforce [target]'s ligaments."),
		span_notice("[user] starts manipulating [target]'s ligaments."))
	give_surgery_pain(target, "Your limbs burn with severe pain!", target_zone = target_zone)
	target.cause_typed_pain(BODY_ZONES_LIMBS, 20, BURN)

/datum/surgery_step/reinforce_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, span_notice("You reinforce [target]'s ligaments!"),
		span_notice("[user] reinforces [target]'s ligaments!"),
		span_notice("[user] finishes manipulating [target]'s ligaments."))
	give_surgery_pain(target, "Your limbs feel more secure, but also more frail.", target_zone = target_zone)
	new /datum/bioware/reinforced_ligaments(target)
	return ..()

/datum/bioware/reinforced_ligaments
	name = "Reinforced Ligaments"
	desc = "The ligaments and nerve endings that connect the torso to the limbs are protected by a mix of bone and tissues, and are much harder to separate from the body, but are also easier to wound."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/reinforced_ligaments/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, EXPERIMENTAL_SURGERY_TRAIT)
	ADD_TRAIT(owner, TRAIT_EASILY_WOUNDED, EXPERIMENTAL_SURGERY_TRAIT)

/datum/bioware/reinforced_ligaments/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, EXPERIMENTAL_SURGERY_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_EASILY_WOUNDED, EXPERIMENTAL_SURGERY_TRAIT)
