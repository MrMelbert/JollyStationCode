// Liver stuff

// werewolf liver, used for various funny traits, like handling their silver weakness chemically
/obj/item/organ/internal/liver/werewolf

	name = "Beastly liver"
	desc = "A large monstrous liver."
	icon_state = "liver"
	organ_flags = ORGAN_UNREMOVABLE
	organ_traits = list(TRAIT_STABLELIVER)
	// TODO: implement these
	var/blood_brute_healing = 2.5
	///Var for burn healing via blood
	var/blood_burn_healing = 2.5

/obj/item/organ/internal/liver/werewolf/handle_chemical(mob/living/carbon/organ_owner, datum/reagent/chem, seconds_per_tick, times_fired)
	. = ..()
	// parent returned COMSIG_MOB_STOP_REAGENT_CHECK or we are failing
	if((. & COMSIG_MOB_STOP_REAGENT_CHECK) || (organ_flags & ORGAN_FAILING))
		return
	if(istype(chem, /datum/reagent/silver))
		organ_owner.adjustStaminaLoss(4 * REM * seconds_per_tick, updating_stamina = TRUE)
		organ_owner.adjustFireLoss(2 * REM * seconds_per_tick, updating_health = TRUE)
