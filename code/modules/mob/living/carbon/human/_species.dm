GLOBAL_LIST_EMPTY(roundstart_races)
///List of all roundstart languages by path except common
GLOBAL_LIST_EMPTY(uncommon_roundstart_languages)

/// An assoc list of species types to their features (from get_features())
GLOBAL_LIST_EMPTY(features_by_species)

/**
 * # species datum
 *
 * Datum that handles different species in the game.
 *
 * This datum handles species in the game, such as lizardpeople, mothmen, zombies, skeletons, etc.
 * It is used in [carbon humans][mob/living/carbon/human] to determine various things about them, like their food preferences, if they have biological genders, their damage resistances, and more.
 *
 */
/datum/species
	///If the game needs to manually check your race to do something not included in a proc here, it will use this.
	var/id
	///This is used for children, it will determine their default limb ID for use of examine. See [/mob/living/carbon/human/proc/examine].
	var/examine_limb_id
	///This is the fluff name. They are displayed on health analyzers and in the character setup menu. Leave them generic for other servers to customize.
	var/name
	/**
	 * The formatting of the name of the species in plural context. Defaults to "[name]\s" if unset.
	 *  Ex "[Plasmamen] are weak", "[Mothmen] are strong", "[Lizardpeople] don't like", "[Golems] hate"
	 */
	var/plural_form

	///Whether or not the race has sexual characteristics (biological genders). At the moment this is only FALSE for skeletons and shadows
	var/sexes = TRUE

	///The maximum number of bodyparts this species can have.
	var/max_bodypart_count = 6
	/// This allows races to have specific hair colors.
	/// If null, it uses the mob's hair/facial hair colors.
	/// If USE_MUTANT_COLOR, it uses the mob's mutant_color.
	/// If USE_FIXED_MUTANT_COLOR, it uses fixedmutcolor
	var/hair_color_mode
	///The alpha used by the hair. 255 is completely solid, 0 is invisible.
	var/hair_alpha = 255
	///The alpha used by the facial hair. 255 is completely solid, 0 is invisible.
	var/facial_hair_alpha = 255

	///Never, Optional, or Forced digi legs?
	var/digitigrade_customization = DIGITIGRADE_NEVER
	/// If your race uses a non standard bloodtype (/datum/blood_type typepath OR /datum/reagent typepath)
	var/exotic_bloodtype
	///The rate at which blood is passively drained by having the blood deficiency quirk. Some races such as slimepeople can regen their blood at different rates so this is to account for that
	var/blood_deficiency_drain_rate = BLOOD_REGEN_FACTOR + BLOOD_DEFICIENCY_MODIFIER // slightly above the regen rate so it slowly drains instead of regenerates.
	///What the species drops when gibbed by a gibber machine.
	var/meat = /obj/item/food/meat/slab/human
	///What skin the species drops when gibbed by a gibber machine.
	var/skinned_type
	///flags for inventory slots the race can't equip stuff to. Golems cannot wear jumpsuits, for example.
	var/no_equip_flags
	/// What languages this species can understand and say.
	/// Use a [language holder datum][/datum/language_holder] typepath in this var.
	/// Should never be null.
	var/datum/language_holder/species_language_holder = /datum/language_holder/human_basic
	/**
	  * Visible CURRENT bodyparts that are unique to a species.
	  * DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK
	  * SHIT UP! Changes to this list for non-species specific bodyparts (ie
	  * cat ears and tails) should be assigned at organ level if possible.
	  * Assoc values are defaults for given bodyparts, also modified by aforementioned organs.
	  * They also allow for faster '[]' list access versus 'in'. Other than that, they are useless right now.
	  * Layer hiding is handled by [/datum/species/proc/handle_mutant_bodyparts] below.
	  */
	var/list/mutant_bodyparts = list()
	///The bodyparts this species uses. assoc of bodypart string - bodypart type. Make sure all the fucking entries are in or I'll skin you alive.
	var/list/bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right,
		BODY_ZONE_HEAD = /obj/item/bodypart/head,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest,
	)
	///Internal organs that are unique to this race, like a tail. list(typepath of organ 1, typepath of organ 2)
	var/list/mutant_organs = list()
	///List of external organs to generate like horns, frills, wings, etc. list(typepath of organ = "Round Beautiful BDSM Snout"). Still WIP
	var/list/external_organs = list()
	///Replaces default brain with a different organ
	var/obj/item/organ/internal/brain/mutantbrain = /obj/item/organ/internal/brain
	///Replaces default heart with a different organ
	var/obj/item/organ/internal/heart/mutantheart = /obj/item/organ/internal/heart
	///Replaces default lungs with a different organ
	var/obj/item/organ/internal/lungs/mutantlungs = /obj/item/organ/internal/lungs
	///Replaces default eyes with a different organ
	var/obj/item/organ/internal/eyes/mutanteyes = /obj/item/organ/internal/eyes
	///Replaces default ears with a different organ
	var/obj/item/organ/internal/ears/mutantears = /obj/item/organ/internal/ears
	///Replaces default tongue with a different organ
	var/obj/item/organ/internal/tongue/mutanttongue = /obj/item/organ/internal/tongue
	///Replaces default liver with a different organ
	var/obj/item/organ/internal/liver/mutantliver = /obj/item/organ/internal/liver
	///Replaces default stomach with a different organ
	var/obj/item/organ/internal/stomach/mutantstomach = /obj/item/organ/internal/stomach
	///Replaces default appendix with a different organ.
	var/obj/item/organ/internal/appendix/mutantappendix = /obj/item/organ/internal/appendix

	/// Flat modifier on all damage taken via [apply_damage][/mob/living/proc/apply_damage] (so being punched, shot, etc.)
	/// IE: 10 = 10% less damage taken.
	var/damage_modifier = 0
	///multiplier for damage from cold temperature
	var/coldmod = 1
	///multiplier for damage from hot temperature
	var/heatmod = 1
	///multiplier for stun durations
	var/stunmod = 1
	///multiplier for money paid at payday
	var/payday_modifier = 1.0
	///Base electrocution coefficient.  Basically a multiplier for damage from electrocutions.
	var/siemens_coeff = 1
	///To use MUTCOLOR with a fixed color that's independent of the mcolor feature in DNA.
	var/fixed_mut_color = ""
	///Special mutation that can be found in the genepool exclusively in this species. Dont leave empty or changing species will be a headache
	var/inert_mutation = /datum/mutation/human/dwarfism
	///Used to set the mob's death_sound upon species change
	var/death_sound
	/// A path to an outfit that is important for species life e.g. plasmaman outfit
	var/datum/outfit/outfit_important_for_life

	// Do not READ these temperature related properties, use the living level ones instead
	// These are deprecated and only exist to set in [/proc/on_species_gain]
	/// The natural temperature for a body
	VAR_PROTECTED/bodytemp_normal = /mob/living/carbon/human::standard_body_temperature
	/// Modifier to how fast/slow the body normalizes its temperature to the environment.
	VAR_PROTECTED/temperature_normalization_speed = /mob/living/carbon/human::temperature_normalization_speed
	/// Modifier to how fast/slow the body normalizes its temperature to standard temp
	/// Note this affects how much nutrition is consumed to maintain body temperature (more homeostais = more nutrition) so be careful
	VAR_PROTECTED/temperature_homeostasis_speed = /mob/living/carbon/human::temperature_homeostasis_speed
	/// The body temperature limit the body can take before it starts taking damage from heat.
	VAR_PROTECTED/bodytemp_heat_damage_limit = /mob/living/carbon/human::bodytemp_heat_damage_limit
	/// The body temperature limit the body can take before it starts taking damage from cold.
	VAR_PROTECTED/bodytemp_cold_damage_limit = /mob/living/carbon/human::bodytemp_cold_damage_limit

	/// The icon_state of the fire overlay added when sufficently ablaze and standing. see onfire.dmi
	var/fire_overlay
	/// The icon of the fire overlay added when sufficently ablaze
	var/fire_dmi

	/// Generic traits tied to having the species.
	var/list/inherent_traits = list()
	/// List of biotypes the mob belongs to. Used by diseases.
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	/// The type of respiration the mob is capable of doing. Used by adjustOxyLoss.
	var/inherent_respiration_type = RESPIRATION_OXYGEN
	///List of factions the mob gain upon gaining this species.
	var/list/inherent_factions

	///What gas does this species breathe? Used by suffocation screen alerts, most of actual gas breathing is handled by mutantlungs. See [life.dm][code/modules/mob/living/carbon/human/life.dm]
	var/breathid = GAS_O2

	///What anim to use for gibbing
	var/gib_anim = "gibbed-h"

	///Bitflag that controls what in game ways something can select this species as a spawnable source, such as magic mirrors. See [mob defines][code/__DEFINES/mobs.dm] for possible sources.
	var/changesource_flags = NONE

	///Unique cookie given by admins through prayers
	var/species_cookie = /obj/item/food/cookie

	///For custom overrides for species ass images
	var/icon/ass_image

	/// List of family heirlooms this species can get with the family heirloom quirk. List of types.
	var/list/family_heirlooms

	///List of results you get from knife-butchering. null means you cant butcher it. Associated by resulting type - value of amount
	var/list/knife_butcher_results

	/// Should we preload this species's organs?
	var/preload = TRUE

	/// Do we try to prevent reset_perspective() from working? Useful for Dullahans to stop perspective changes when they're looking through their head.
	var/prevent_perspective_change = FALSE

	///Was the species changed from its original type at the start of the round?
	var/roundstart_changed = FALSE

	/// This supresses the "dosen't appear to be himself" examine text for if the mob is run by an AI controller. Should be used on any NPC human subtypes. Monkeys are the prime example.
	var/ai_controlled_species = FALSE

	/**
	 * Was on_species_gain ever actually called?
	 * Species code is really odd...
	 **/
	var/properly_gained = FALSE

	///A list containing outfits that will be overridden in the species_equip_outfit proc. [Key = Typepath passed in] [Value = Typepath of outfit you want to equip for this specific species instead].
	var/list/outfit_override_registry = list()

	/// What species is our monkey form
	var/datum/species/monkey_type = /datum/species/monkey

///////////
// PROCS //
///////////


/datum/species/New()
	if(!plural_form)
		plural_form = "[name]\s"
	if(!examine_limb_id)
		examine_limb_id = id

	return ..()

/// Gets a list of all species available to choose in roundstart.
/proc/get_selectable_species()
	RETURN_TYPE(/list)

	if (!GLOB.roundstart_races.len)
		GLOB.roundstart_races = generate_selectable_species_and_languages()

	return GLOB.roundstart_races

/**
 * Generates species available to choose in character setup at roundstart
 *
 * This proc generates which species are available to pick from in character setup.
 * If there are no available roundstart species, defaults to human.
 */
/proc/generate_selectable_species_and_languages()
	var/list/selectable_species = list()

	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = GLOB.species_prototypes[species_type]
		if(species.check_roundstart_eligible())
			selectable_species += species.id
			var/datum/language_holder/temp_holder = GLOB.prototype_language_holders[species.species_language_holder]
			for(var/datum/language/spoken_language as anything in temp_holder.understood_languages)
				GLOB.uncommon_roundstart_languages |= spoken_language

	GLOB.uncommon_roundstart_languages -= /datum/language/common
	if(!selectable_species.len)
		selectable_species += SPECIES_HUMAN

	return selectable_species

/**
 * Checks if a species is eligible to be picked at roundstart.
 *
 * Checks the config to see if this species is allowed to be picked in the character setup menu.
 * Used by [/proc/generate_selectable_species_and_languages].
 */
/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/**
 * Copies some vars and properties over that should be kept when creating a copy of this species.
 *
 * Used by slimepeople to copy themselves, and by the DNA datum to hardset DNA to a species
 * Arguments:
 * * old_species - The species that the carbon used to be before copying
 */
/datum/species/proc/copy_properties_from(datum/species/old_species)
	return

/**
 * Gets the default mutant organ for the species based on the provided slot.
 */
/datum/species/proc/get_mutant_organ_type_for_slot(slot)
	switch(slot)
		if(ORGAN_SLOT_BRAIN)
			return mutantbrain
		if(ORGAN_SLOT_HEART)
			return mutantheart
		if(ORGAN_SLOT_LUNGS)
			return mutantlungs
		if(ORGAN_SLOT_APPENDIX)
			return mutantappendix
		if(ORGAN_SLOT_EYES)
			return mutanteyes
		if(ORGAN_SLOT_EARS)
			return mutantears
		if(ORGAN_SLOT_TONGUE)
			return mutanttongue
		if(ORGAN_SLOT_LIVER)
			return mutantliver
		if(ORGAN_SLOT_STOMACH)
			return mutantstomach
		else
			CRASH("Invalid organ slot [slot]")

/**
 * Corrects organs in a carbon, removing ones it doesn't need and adding ones it does.
 *
 * Takes all organ slots, removes organs a species should not have, adds organs a species should have.
 * can use replace_current to refresh all organs, creating an entirely new set.
 *
 * Arguments:
 * * organ_holder - carbon, the owner of the species datum AKA whoever we're regenerating organs in
 * * old_species - datum, used when regenerate organs is called in a switching species to remove old mutant organs.
 * * replace_current - boolean, forces all old organs to get deleted whether or not they pass the species' ability to keep that organ
 * * excluded_zones - list, add zone defines to block organs inside of the zones from getting handled. see headless mutation for an example
 * * visual_only - boolean, only load organs that change how the species looks. Do not use for normal gameplay stuff
 */
/datum/species/proc/regenerate_organs(mob/living/carbon/organ_holder, datum/species/old_species, replace_current = TRUE, list/excluded_zones, visual_only = FALSE)
	//what should be put in if there is no mutantorgan (brains handled separately)
	var/list/organ_slots = list(
		ORGAN_SLOT_BRAIN,
		ORGAN_SLOT_HEART,
		ORGAN_SLOT_LUNGS,
		ORGAN_SLOT_APPENDIX,
		ORGAN_SLOT_EYES,
		ORGAN_SLOT_EARS,
		ORGAN_SLOT_TONGUE,
		ORGAN_SLOT_LIVER,
		ORGAN_SLOT_STOMACH,
	)

	for(var/slot in organ_slots)
		var/obj/item/organ/existing_organ = organ_holder.get_organ_slot(slot)
		var/obj/item/organ/new_organ = get_mutant_organ_type_for_slot(slot)

		if(isnull(new_organ)) // if they aren't suppose to have an organ here, remove it
			if(existing_organ)
				existing_organ.Remove(organ_holder, special = TRUE)
				qdel(existing_organ)
			continue

		if(!isnull(old_species) && !isnull(existing_organ))
			if(existing_organ.type != old_species.get_mutant_organ_type_for_slot(slot))
				continue // we don't want to remove organs that are not the default for this species

		// at this point we already know new_organ is not null
		if(existing_organ?.type == new_organ)
			continue // we don't want to remove organs that are the same as the new one

		if(visual_only && !initial(new_organ.visual))
			continue

		var/used_neworgan = FALSE
		new_organ = SSwardrobe.provide_type(new_organ)
		var/should_have = new_organ.get_availability(src, organ_holder)

		// Check for an existing organ, and if there is one check to see if we should remove it
		var/health_pct = 1
		var/remove_existing = !isnull(existing_organ) && !(existing_organ.zone in excluded_zones) && !(existing_organ.organ_flags & ORGAN_UNREMOVABLE)
		if(remove_existing)
			health_pct = (existing_organ.maxHealth - existing_organ.damage) / existing_organ.maxHealth
			if(slot == ORGAN_SLOT_BRAIN)
				var/obj/item/organ/internal/brain/existing_brain = existing_organ
				existing_brain.before_organ_replacement(new_organ)
				existing_brain.Remove(organ_holder, special = TRUE, movement_flags = NO_ID_TRANSFER)
			else
				existing_organ.before_organ_replacement(new_organ)
				existing_organ.Remove(organ_holder, special = TRUE)

			QDEL_NULL(existing_organ)
		if(isnull(existing_organ) && should_have && !(new_organ.zone in excluded_zones) && organ_holder.get_bodypart(deprecise_zone(new_organ.zone)))
			used_neworgan = TRUE
			new_organ.set_organ_damage(new_organ.maxHealth * (1 - health_pct))
			new_organ.Insert(organ_holder, special = TRUE, movement_flags = DELETE_IF_REPLACED)

		if(!used_neworgan)
			QDEL_NULL(new_organ)

	if(!isnull(old_species))
		for(var/mutant_organ in old_species.mutant_organs)
			if(mutant_organ in mutant_organs)
				continue // need this mutant organ, but we already have it!

			var/obj/item/organ/current_organ = organ_holder.get_organ_by_type(mutant_organ)
			if(current_organ)
				current_organ.Remove(organ_holder)
				QDEL_NULL(current_organ)

	for(var/obj/item/organ/external/external_organ in organ_holder.organs)
		// External organ checking. We need to check the external organs owned by the carbon itself,
		// because we want to also remove ones not shared by its species.
		// This should be done even if species was not changed.
		if(external_organ in external_organs)
			continue // Don't remove external organs this species is supposed to have.

		external_organ.Remove(organ_holder)
		QDEL_NULL(external_organ)

	var/list/species_organs = mutant_organs + external_organs
	for(var/organ_path in species_organs)
		var/obj/item/organ/current_organ = organ_holder.get_organ_by_type(organ_path)
		if(ispath(organ_path, /obj/item/organ/external) && !should_external_organ_apply_to(organ_path, organ_holder))
			if(!isnull(current_organ) && replace_current)
				// if we have an organ here and we're replacing organs, remove it
				current_organ.Remove(organ_holder)
				QDEL_NULL(current_organ)
			continue

		if(!current_organ || replace_current)
			var/obj/item/organ/replacement = SSwardrobe.provide_type(organ_path)
			// If there's an existing mutant organ, we're technically replacing it.
			// Let's abuse the snowflake proc that skillchips added. Basically retains
			// feature parity with every other organ too.
			if(current_organ)
				current_organ.before_organ_replacement(replacement)
			// organ.Insert will qdel any current organs in that slot, so we don't need to.
			replacement.Insert(organ_holder, special=TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/species/proc/worn_items_fit_body_check(mob/living/carbon/wearer)
	for(var/obj/item/equipped_item in wearer.get_all_worn_items())
		var/equipped_item_slot = wearer.get_slot_by_item(equipped_item)
		if(!equipped_item.mob_can_equip(wearer, equipped_item_slot, bypass_equip_delay_self = TRUE, ignore_equipped = TRUE))
			wearer.dropItemToGround(equipped_item, force = TRUE)

/datum/species/proc/update_no_equip_flags(mob/living/carbon/wearer, new_flags)
	no_equip_flags = new_flags
	wearer.hud_used?.update_locked_slots()
	worn_items_fit_body_check(wearer)

/**
 * Normalizes blood in a human if it is excessive. If it is above BLOOD_VOLUME_NORMAL, this will clamp it to that value. It will not give the human more blodo than they have less than this value.
 */
/datum/species/proc/normalize_blood(mob/living/carbon/human/blood_possessing_human)
	var/normalized_blood_values = max(blood_possessing_human.blood_volume, 0, BLOOD_VOLUME_NORMAL)
	blood_possessing_human.blood_volume = normalized_blood_values

/**
 * Proc called when a carbon becomes this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_GAIN] signal.
 * Arguments:
 * * C - Carbon, this is whoever became the new species.
 * * old_species - The species that the carbon used to be before becoming this race, used for regenerating organs.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)
	// Drop the items the new species can't wear
	if(human_who_gained_species.hud_used)
		human_who_gained_species.hud_used.update_locked_slots()

	human_who_gained_species.mob_biotypes = inherent_biotypes
	human_who_gained_species.mob_respiration_type = inherent_respiration_type
	human_who_gained_species.butcher_results = knife_butcher_results?.Copy()

	human_who_gained_species.standard_body_temperature = src.bodytemp_normal
	human_who_gained_species.body_temperature = src.bodytemp_normal
	human_who_gained_species.bodytemp_heat_damage_limit = src.bodytemp_heat_damage_limit
	human_who_gained_species.bodytemp_cold_damage_limit = src.bodytemp_cold_damage_limit
	human_who_gained_species.temperature_normalization_speed = src.temperature_normalization_speed
	human_who_gained_species.temperature_homeostasis_speed = src.temperature_homeostasis_speed

	human_who_gained_species.physiology.cold_mod *= coldmod
	human_who_gained_species.physiology.heat_mod *= heatmod

	if(old_species.type != type)
		replace_body(human_who_gained_species, src)

	regenerate_organs(human_who_gained_species, old_species, visual_only = human_who_gained_species.visual_only_organs)

	// Drop the items the new species can't wear
	INVOKE_ASYNC(src, PROC_REF(worn_items_fit_body_check), human_who_gained_species, TRUE)

	// NON-MODULE CHANGE
	// //Assigns exotic blood type if the species has one
	// if(exotic_bloodtype && human_who_gained_species.dna.blood_type != exotic_bloodtype)
	// 	human_who_gained_species.dna.blood_type = exotic_bloodtype
	// //Otherwise, check if the previous species had an exotic bloodtype and we do not have one and assign a random blood type
	// //(why the fuck is blood type not tied to a fucking DNA block?)
	// else if(old_species.exotic_bloodtype && !exotic_bloodtype)
	// 	human_who_gained_species.dna.blood_type = random_blood_type()

	if(isnum(species_pain_mod) && species_pain_mod != 1)
		human_who_gained_species.set_pain_mod(PAIN_MOD_SPECIES, species_pain_mod)

	//Resets blood if it is excessively high so they don't gib
	normalize_blood(human_who_gained_species)

	if(ishuman(human_who_gained_species))
		var/mob/living/carbon/human/human = human_who_gained_species
		for(var/obj/item/organ/external/organ_path as anything in external_organs)
			if(!should_external_organ_apply_to(organ_path, human))
				continue

			//Load a persons preferences from DNA
			var/obj/item/organ/external/new_organ = SSwardrobe.provide_type(organ_path)
			new_organ.Insert(human, special=TRUE, movement_flags = DELETE_IF_REPLACED)

	if(length(inherent_traits))
		human_who_gained_species.add_traits(inherent_traits, SPECIES_TRAIT)

	if(inherent_factions)
		for(var/i in inherent_factions)
			human_who_gained_species.faction += i //Using +=/-= for this in case you also gain the faction from a different source.

	// All languages associated with this language holder are added with source [LANGUAGE_SPECIES]
	// rather than source [LANGUAGE_ATOM], so we can track what to remove if our species changes again
	var/datum/language_holder/gaining_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in gaining_holder.understood_languages)
		human_who_gained_species.grant_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.spoken_languages)
		human_who_gained_species.grant_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in gaining_holder.blocked_languages)
		human_who_gained_species.add_blocked_language(language, LANGUAGE_SPECIES)
	human_who_gained_species.regenerate_icons()

	SEND_SIGNAL(human_who_gained_species, COMSIG_SPECIES_GAIN, src, old_species)

	properly_gained = TRUE

/**
 * Proc called when a carbon is no longer this species.
 *
 * This sets up and adds/changes/removes things, qualities, abilities, and traits so that the transformation is as smooth and bugfree as possible.
 * Produces a [COMSIG_SPECIES_LOSS] signal.
 * Arguments:
 * * C - Carbon, this is whoever lost this species.
 * * new_species - The new species that the carbon became, used for genetics mutations.
 * * pref_load - Preferences to be loaded from character setup, loads in preferred mutant things like bodyparts, digilegs, skin color, etc.
 */
/datum/species/proc/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	SHOULD_CALL_PARENT(TRUE)
	C.butcher_results = null
	for(var/X in inherent_traits)
		REMOVE_TRAIT(C, X, SPECIES_TRAIT)

	for(var/obj/item/organ/external/organ in C.organs)
		organ.Remove(C)
		qdel(organ)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(C.dna.mutation_index) && (inert_mutation in C.dna.mutation_index))
		C.dna.remove_mutation(inert_mutation)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = C.dna.mutation_index.Find(inert_mutation)
		C.dna.mutation_index[location] = new_species.inert_mutation
		C.dna.default_mutation_genes[location] = C.dna.mutation_index[location]
		C.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)
		C.dna.default_mutation_genes[new_species.inert_mutation] = C.dna.mutation_index[new_species.inert_mutation]

	if(inherent_factions)
		for(var/i in inherent_factions)
			C.faction -= i

	clear_tail_moodlets(C)

	C.unset_pain_mod(PAIN_MOD_SPECIES)

	C.physiology?.cold_mod /= coldmod
	C.physiology?.heat_mod /= heatmod

	// Removes all languages previously associated with [LANGUAGE_SPECIES], gaining our new species will add new ones back
	var/datum/language_holder/losing_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/language in losing_holder.understood_languages)
		C.remove_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.spoken_languages)
		C.remove_language(language, SPOKEN_LANGUAGE, LANGUAGE_SPECIES)
	for(var/language in losing_holder.blocked_languages)
		C.remove_blocked_language(language, LANGUAGE_SPECIES)

	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

// NON-MODULE CHANGE
// /**
//  * Proc called when mail goodies need to be updated for this species.
//  *
//  * Updates the mail goodies if that is required. e.g. for the blood deficiency quirk, which sends bloodbags to quirk holders, update the sent bloodpack to match the species' exotic blood.
//  * This is currently only used for the blood deficiency quirk but more can be added as needed.
//  * Arguments:
//  * * mob/living/carbon/human/recipient - the mob receiving the mail goodies
//  */
// /datum/species/proc/update_mail_goodies(mob/living/carbon/human/recipient)
// 	update_quirk_mail_goodies(recipient, recipient.get_quirk(/datum/quirk/blooddeficiency))

// NON-MODULE CHANGE
// /**
//  * Updates the mail goodies of a specific quirk.
//  *
//  * Updates the mail goodies belonging to a specific quirk.
//  * Add implementation as needed for each individual species. The base species proc should give the species the 'default' version of whatever mail goodies are required.
//  * Arguments:
//  * * mob/living/carbon/human/recipient - the mob receiving the mail goodies
//  * * datum/quirk/quirk - the quirk to update the mail goodies of. Use get_quirk(datum/quirk/some_quirk) to get the actual mob's quirk to pass.
//  * * list/mail_goodies - a list of mail goodies. Generally speaking you should not be using this argument on the initial function call. You should instead add to the species' implementation of this proc.
//  */
// /datum/species/proc/update_quirk_mail_goodies(mob/living/carbon/human/recipient, datum/quirk/quirk, list/mail_goodies)
// 	if(isnull(quirk))
// 		return
// 	if(length(mail_goodies))
// 		quirk.mail_goodies = mail_goodies
// 		return
// 	// NON-MODULE CHANGE
// 	if(istype(quirk, /datum/quirk/blooddeficiency) && HAS_TRAIT(recipient, TRAIT_NOBLOOD))  // TRAIT_NOBLOOD and no exotic blood (yes we have to check for both, jellypeople exist)
// 		quirk.mail_goodies = list() // means no blood pack gets sent to them.
// 		return


// 	// The default case if no species implementation exists. Set quirk's mail_goodies to initial.
// 	var/datum/quirk/readable_quirk = new quirk.type
// 	quirk.mail_goodies = readable_quirk.mail_goodies
// 	qdel(readable_quirk) // We have to do it this way because initial will not work on lists in this version of DM
// 	return

/**
 * Handles the body of a human
 *
 * Handles lipstick, having no eyes, eye color, undergarnments like underwear, undershirts, and socks, and body layers.
 * Calls [handle_mutant_bodyparts][/datum/species/proc/handle_mutant_bodyparts]
 * Arguments:
 * * species_human - Human, whoever we're handling the body for
 */
/datum/species/proc/handle_body(mob/living/carbon/human/species_human)
	species_human.remove_overlay(BODY_LAYER)
	if(HAS_TRAIT(species_human, TRAIT_INVISIBLE_MAN))
		return handle_mutant_bodyparts(species_human)
	var/list/standing = list()

	if(!HAS_TRAIT(species_human, TRAIT_HUSK))
		var/obj/item/bodypart/head/noggin = species_human.get_bodypart(BODY_ZONE_HEAD)
		if(noggin?.head_flags & HEAD_EYESPRITES)
			// eyes (missing eye sprites get handled by the head itself, but sadly we have to do this stupid shit here, for now)
			var/obj/item/organ/internal/eyes/eye_organ = species_human.get_organ_slot(ORGAN_SLOT_EYES)
			if(eye_organ)
				eye_organ.refresh(call_update = FALSE)
				standing += eye_organ.generate_body_overlay(species_human)

		// organic body markings (oh my god this is terrible please rework this to be done on the limbs themselves i beg you)
		if(HAS_TRAIT(species_human, TRAIT_HAS_MARKINGS))
			var/obj/item/bodypart/chest/chest = species_human.get_bodypart(BODY_ZONE_CHEST)
			var/obj/item/bodypart/arm/right/right_arm = species_human.get_bodypart(BODY_ZONE_R_ARM)
			var/obj/item/bodypart/arm/left/left_arm = species_human.get_bodypart(BODY_ZONE_L_ARM)
			var/obj/item/bodypart/leg/right/right_leg = species_human.get_bodypart(BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg/left/left_leg = species_human.get_bodypart(BODY_ZONE_L_LEG)
			var/datum/sprite_accessory/markings = GLOB.moth_markings_list[species_human.dna.features["moth_markings"]]
			var/mutable_appearance/marking = mutable_appearance(layer = -BODY_LAYER, appearance_flags = KEEP_TOGETHER)
			if(noggin && IS_ORGANIC_LIMB(noggin))
				marking.overlays += mutable_appearance(markings.icon, "[markings.icon_state]_head")

			if(chest && IS_ORGANIC_LIMB(chest))
				marking.overlays += mutable_appearance(markings.icon, "[markings.icon_state]_chest")

			if(right_arm && IS_ORGANIC_LIMB(right_arm))
				marking.overlays += mutable_appearance(markings.icon, "[markings.icon_state]_r_arm")

			if(left_arm && IS_ORGANIC_LIMB(left_arm))
				marking.overlays += mutable_appearance(markings.icon, "[markings.icon_state]_l_arm")

			if(right_leg && IS_ORGANIC_LIMB(right_leg))
				marking.overlays += mutable_appearance(markings.icon, "[markings.icon_state]_r_leg")

			if(left_leg && IS_ORGANIC_LIMB(left_leg))
				marking.overlays += mutable_appearance(markings.icon, "[markings.icon_state]_l_leg")

			standing += marking

	//Underwear, Undershirts & Socks
	if(!HAS_TRAIT(species_human, TRAIT_NO_UNDERWEAR))
		if(species_human.underwear)
			var/datum/sprite_accessory/underwear/underwear = GLOB.underwear_list[species_human.underwear]
			var/mutable_appearance/underwear_overlay
			if(underwear)
				if(species_human.dna.species.sexes && species_human.physique == FEMALE && (underwear.gender == MALE))
					underwear_overlay = mutable_appearance(wear_female_version(underwear.icon_state, underwear.icon, FEMALE_UNIFORM_FULL), layer = -BODY_LAYER)
				else
					underwear_overlay = mutable_appearance(underwear.icon, underwear.icon_state, -BODY_LAYER)
				if(!underwear.use_static)
					underwear_overlay.color = species_human.underwear_color
				standing += underwear_overlay

		if(species_human.undershirt)
			var/datum/sprite_accessory/undershirt/undershirt = GLOB.undershirt_list[species_human.undershirt]
			if(undershirt)
				var/mutable_appearance/working_shirt
				if(species_human.dna.species.sexes && species_human.physique == FEMALE)
					working_shirt = mutable_appearance(wear_female_version(undershirt.icon_state, undershirt.icon), layer = -BODY_LAYER)
				else
					working_shirt = mutable_appearance(undershirt.icon, undershirt.icon_state, layer = -BODY_LAYER)
				standing += working_shirt

		if(species_human.socks && species_human.num_legs >= 2 && !(species_human.bodytype & BODYTYPE_DIGITIGRADE))
			var/datum/sprite_accessory/socks/socks = GLOB.socks_list[species_human.socks]
			if(socks)
				standing += mutable_appearance(socks.icon, socks.icon_state, -BODY_LAYER)

	if(standing.len)
		species_human.overlays_standing[BODY_LAYER] = standing

	species_human.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(species_human)

/**
 * Handles the mutant bodyparts of a human
 *
 * Handles the adding and displaying of, layers, colors, and overlays of mutant bodyparts and accessories.
 * Handles digitigrade leg displaying and squishing.
 * Arguments:
 * * H - Human, whoever we're handling the body for
 * * forced_colour - The forced color of an accessory. Leave null to use mutant color.
 */
/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/source, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()
	var/list/relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	var/list/standing = list()

	source.remove_overlay(BODY_BEHIND_LAYER)
	source.remove_overlay(BODY_ADJ_LAYER)
	source.remove_overlay(BODY_FRONT_LAYER)

	if(!mutant_bodyparts || HAS_TRAIT(source, TRAIT_INVISIBLE_MAN))
		return

	var/obj/item/bodypart/head/noggin = source.get_bodypart(BODY_ZONE_HEAD)


	if(mutant_bodyparts["ears"])
		if(!source.dna.features["ears"] || source.dna.features["ears"] == "None" || source.head && (source.head.flags_inv & HIDEHAIR) || (source.wear_mask && (source.wear_mask.flags_inv & HIDEHAIR)) || !noggin || IS_ROBOTIC_LIMB(noggin))
			bodyparts_to_add -= "ears"

	if(!bodyparts_to_add)
		return

	var/g = (source.physique == FEMALE) ? "f" : "m"

	for(var/layer in relevent_layers)
		var/layertext = mutant_bodyparts_layertext(layer)

		for(var/bodypart in bodyparts_to_add)
			var/datum/sprite_accessory/accessory
			switch(bodypart)
				if("ears")
					accessory = GLOB.ears_list[source.dna.features["ears"]]
				if("body_markings")
					accessory = GLOB.body_markings_list[source.dna.features["body_markings"]]
				if("legs")
					accessory = GLOB.legs_list[source.dna.features["legs"]]

			if(!accessory || accessory.icon_state == "none")
				continue

			var/mutable_appearance/accessory_overlay = mutable_appearance(accessory.icon, layer = -layer)

			if(accessory.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[accessory.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[accessory.icon_state]_[layertext]"

			if(accessory.em_block)
				accessory_overlay.overlays += emissive_blocker(accessory_overlay.icon, accessory_overlay.icon_state, source, accessory_overlay.alpha)

			if(accessory.center)
				accessory_overlay = center_image(accessory_overlay, accessory.dimension_x, accessory.dimension_y)

			if(!(HAS_TRAIT(source, TRAIT_HUSK)))
				if(!forced_colour)
					switch(accessory.color_src)
						if(MUTANT_COLOR)
							accessory_overlay.color = fixed_mut_color || source.dna.features["mcolor"]
						if(HAIR_COLOR)
							accessory_overlay.color = get_fixed_hair_color(source) || source.hair_color
						if(FACIAL_HAIR_COLOR)
							accessory_overlay.color = get_fixed_hair_color(source) || source.facial_hair_color
						if(EYE_COLOR)
							accessory_overlay.color = source.eye_color_left
				else
					accessory_overlay.color = forced_colour
			standing += accessory_overlay

			if(accessory.hasinner)
				var/mutable_appearance/inner_accessory_overlay = mutable_appearance(accessory.icon, layer = -layer)
				if(accessory.gender_specific)
					inner_accessory_overlay.icon_state = "[g]_[bodypart]inner_[accessory.icon_state]_[layertext]"
				else
					inner_accessory_overlay.icon_state = "m_[bodypart]inner_[accessory.icon_state]_[layertext]"

				if(accessory.center)
					inner_accessory_overlay = center_image(inner_accessory_overlay, accessory.dimension_x, accessory.dimension_y)

				standing += inner_accessory_overlay

		source.overlays_standing[layer] = standing.Copy()
		standing = list()

	source.apply_overlay(BODY_BEHIND_LAYER)
	source.apply_overlay(BODY_ADJ_LAYER)
	source.apply_overlay(BODY_FRONT_LAYER)

//This exists so sprite accessories can still be per-layer without having to include that layer's
//number in their sprite name, which causes issues when those numbers change.
/datum/species/proc/mutant_bodyparts_layertext(layer)
	switch(layer)
		if(BODY_BEHIND_LAYER)
			return "BEHIND"
		if(BODY_ADJ_LAYER)
			return "ADJ"
		if(BODY_FRONT_LAYER)
			return "FRONT"

///Proc that will randomise the hair, or primary appearance element (i.e. for moths wings) of a species' associated mob
/datum/species/proc/randomize_main_appearance_element(mob/living/carbon/human/human_mob)
	human_mob.set_hairstyle(random_hairstyle(human_mob.gender), update = FALSE)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob,
/// but will not update the body right away.
/datum/species/proc/randomize_active_underwear_only(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)

///Proc that will randomise the underwear (i.e. top, pants and socks) of a species' associated mob
/datum/species/proc/randomize_active_underwear(mob/living/carbon/human/human_mob)
	randomize_active_underwear_only(human_mob)
	human_mob.update_body()

/datum/species/proc/randomize_active_features(mob/living/carbon/human/human_mob)
	var/list/new_features = randomize_features()
	for(var/feature_key in new_features)
		human_mob.dna.features[feature_key] = new_features[feature_key]
	human_mob.updateappearance(mutcolor_update = TRUE)

/**
 * Returns a list of features, randomized, to be used by DNA
 */
/datum/species/proc/randomize_features()
	SHOULD_CALL_PARENT(TRUE)

	var/list/new_features = list()
	var/static/list/organs_to_randomize = list()
	for(var/obj/item/organ/external/organ_path as anything in external_organs)
		var/overlay_path = initial(organ_path.bodypart_overlay)
		var/datum/bodypart_overlay/mutant/sample_overlay = organs_to_randomize[overlay_path]
		if(isnull(sample_overlay))
			sample_overlay = new overlay_path()
			organs_to_randomize[overlay_path] = sample_overlay

		new_features["[sample_overlay.feature_key]"] = pick(sample_overlay.get_global_feature_list())

	return new_features

/datum/species/proc/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	if(H.stat == DEAD)
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH) && H.stat >= UNCONSCIOUS && !HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
		H.adjustBruteLoss(0.5 * seconds_per_tick)

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE, ignore_equipped = FALSE, indirect_action = FALSE)
	if(no_equip_flags & slot)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	// if there's an item in the slot we want, fail
	if(!ignore_equipped)
		if(H.get_item_by_slot(slot))
			return FALSE

	// this check prevents us from equipping something to a slot it doesn't support, WITH the exceptions of storage slots (pockets, suit storage, and backpacks)
	// we don't require having those slots defined in the item's slot_flags, so we'll rely on their own checks further down
	if(!(I.slot_flags & slot))
		var/excused = FALSE
		// Anything that's small or smaller can fit into a pocket by default
		if((slot & (ITEM_SLOT_RPOCKET|ITEM_SLOT_LPOCKET)) && I.w_class <= POCKET_WEIGHT_CLASS)
			excused = TRUE
		else if(slot & (ITEM_SLOT_SUITSTORE|ITEM_SLOT_BACKPACK|ITEM_SLOT_HANDS))
			excused = TRUE
		if(!excused)
			return FALSE

	switch(slot)
		if(ITEM_SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(ITEM_SLOT_MASK)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_NECK)
			return TRUE
		if(ITEM_SLOT_BACK)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_OCLOTHING)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_GLOVES)
			if(H.num_hands < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_FEET)
			if(H.num_legs < 2)
				return FALSE
			if((H.bodytype & BODYTYPE_DIGITIGRADE) && !(I.supports_variations_flags & (DIGITIGRADE_VARIATIONS)))
				if(!disable_warning)
					to_chat(H, span_warning("The footwear around here isn't compatible with your feet!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_BELT)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EYES)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			var/obj/item/organ/internal/eyes/eyes = H.get_organ_slot(ORGAN_SLOT_EYES)
			if(eyes?.no_glasses)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_HEAD)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_EARS)
			if(!H.get_bodypart(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ICLOTHING)
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_ID)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(ITEM_SLOT_LPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(!isnull(H.l_store) && H.l_store != I) // no pocket swaps at all
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_RPOCKET)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!isnull(H.r_store) && H.r_store != I)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !HAS_TRAIT(H, TRAIT_NO_JUMPSUIT) && (!O || IS_ORGANIC_LIMB(O)))
				if(!disable_warning)
					to_chat(H, span_warning("You need a jumpsuit before you can attach this [I.name]!"))
				return FALSE
			return TRUE
		if(ITEM_SLOT_SUITSTORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(!H.wear_suit)
				if(!disable_warning)
					to_chat(H, span_warning("You need a suit before you can attach this [I.name]!"))
				return FALSE
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, span_warning("You somehow have a suit with no defined allowed items for suit storage, stop that."))
				return FALSE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, span_warning("The [I.name] is too big to attach!")) //should be src?
				return FALSE
			if( istype(I, /obj/item/modular_computer/pda) || istype(I, /obj/item/pen) || is_type_in_list(I, H.wear_suit.allowed) )
				return TRUE
			return FALSE
		if(ITEM_SLOT_HANDCUFFED)
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(H.num_hands < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_LEGCUFFED)
			if(!istype(I, /obj/item/restraints/legcuffs))
				return FALSE
			if(H.num_legs < 2)
				return FALSE
			return TRUE
		if(ITEM_SLOT_BACKPACK)
			if(H.back && H.back.atom_storage?.can_insert(I, H, messages = TRUE, force = indirect_action ? STORAGE_SOFT_LOCKED : STORAGE_NOT_LOCKED))
				return TRUE
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message(span_notice("[H] start putting on [I]..."), span_notice("You start putting on [I]..."))
	return do_after(H, I.equip_delay_self, target = H)


/// Equips the necessary species-relevant gear before putting on the rest of the uniform.
/datum/species/proc/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	return

/**
 * Handling special reagent interactions.
 *
 * Return null continue running the normal on_mob_life() for that reagent.
 * Return COMSIG_MOB_STOP_REAGENT_CHECK to not run the normal metabolism effects.
 *
 * NOTE: If you return COMSIG_MOB_STOP_REAGENT_CHECK, that reagent will not be removed liike normal! You must handle it manually.
 **/
/datum/species/proc/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	SHOULD_CALL_PARENT(TRUE)
	// NON-MODULE CHANGE
	// Cringe but blood handles this on its own
	// This also has problems of its own but that's better fixed later I think
	if(!istype(chem, /datum/reagent/blood))
		var/datum/blood_type/blood = affected.get_blood_type()
		if(chem.type == blood?.reagent_type)
			affected.blood_volume = min(affected.blood_volume + round(chem.volume, 0.1), BLOOD_VOLUME_MAXIMUM)
			affected.reagents.del_reagent(chem.type)
			return COMSIG_MOB_STOP_REAGENT_CHECK
		if(chem.type == blood?.restoration_chem && affected.blood_volume < BLOOD_VOLUME_NORMAL)
			affected.blood_volume += 0.25 * seconds_per_tick
			affected.reagents.remove_reagent(chem.type, chem.metabolization_rate * seconds_per_tick)
			return COMSIG_MOB_STOP_REAGENT_CHECK
	// NON-MODULE CHANGE END
	if(!chem.overdosed && chem.overdose_threshold && chem.volume >= chem.overdose_threshold && !HAS_TRAIT(affected, TRAIT_OVERDOSEIMMUNE))
		chem.overdosed = TRUE
		chem.overdose_start(affected)
		affected.log_message("has started overdosing on [chem.name] at [chem.volume] units.", LOG_GAME)
	return SEND_SIGNAL(affected, COMSIG_SPECIES_HANDLE_CHEMICAL, chem, seconds_per_tick, times_fired)

/**
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return

	human_to_equip.equipOutfit(outfit_important_for_life)

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(SEND_SIGNAL(target, COMSIG_CARBON_PRE_HELP, user, attacker_style) & COMPONENT_BLOCK_HELP_ACT)
		return TRUE

	if(attacker_style?.help_act(user, target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE

	if(target == user)
		user.check_self_for_injuries()
		return TRUE

	if(target.on_fire)
		user.do_pat_fire(target)
		return TRUE

	if(!target.appears_alive())
		to_chat(user, span_warning("[target] has no pulse!"))
		return TRUE

	if(target.stat == HARD_CRIT && target.body_position == LYING_DOWN) // having a heart attack coincidentally also puts you in hard crit
		user.do_cpr(target)
		return TRUE

	target.help_shake_act(user)
	log_combat(user, target, "shaken")
	return TRUE

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(attacker_style?.grab_act(user, target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	target.grabbedby(user)
	return TRUE

///This proc handles punching damage. IMPORTANT: Our owner is the TARGET and not the USER in this proc. For whatever reason...
/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && !attacker_style?.pacifist_style)
		to_chat(user, span_warning("You don't want to harm [target]!"))
		return FALSE
	if(attacker_style?.harm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	else

		var/obj/item/organ/internal/brain/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
		var/obj/item/bodypart/attacking_bodypart = brain?.get_attacking_limb(target) || user.get_active_hand()
		var/atk_verb = attacking_bodypart.unarmed_attack_verb
		var/atk_effect = attacking_bodypart.unarmed_attack_effect

		if(atk_effect == ATTACK_EFFECT_BITE)
			if(user.is_mouth_covered(ITEM_SLOT_MASK))
				to_chat(user, span_warning("You can't [atk_verb] with your mouth covered!"))
				return FALSE
		user.do_attack_animation(target, atk_effect)

		//has our target been shoved recently? If so, they're staggered and we get an easy hit.
		var/staggered = FALSE

		//Someone in a grapple is much more vulnerable to being harmed by punches.
		var/grappled = FALSE

		if(target.get_timed_status_effect_duration(/datum/status_effect/staggered))
			staggered = TRUE

		if(target.pulledby && target.pulledby.grab_state >= GRAB_AGGRESSIVE)
			grappled = TRUE

		var/damage = rand(attacking_bodypart.unarmed_damage_low, attacking_bodypart.unarmed_damage_high) * user.outgoing_damage_mod
		var/limb_accuracy = attacking_bodypart.unarmed_effectiveness

		var/obj/item/bodypart/affecting = target.get_bodypart(target.get_random_valid_zone(user.zone_selected))

		var/miss_chance = 100//calculate the odds that a punch misses entirely. considers stamina and brute damage of the puncher. punches miss by default to prevent weird cases
		if(attacking_bodypart.unarmed_damage_low)
			if((target.body_position == LYING_DOWN) || HAS_TRAIT(user, TRAIT_PERFECT_ATTACKER) || staggered || user == target) //kicks and attacks against staggered targets never miss (provided your species deals more than 0 damage)
				miss_chance = 0
			else
				miss_chance = clamp(UNARMED_MISS_CHANCE_BASE - limb_accuracy + user.getStaminaLoss() + ((100 - user.consciousness) * 0.5), 0, UNARMED_MISS_CHANCE_MAX) //Limb miss chance + various damage. capped at 80 so there is at least a chance to land a hit.

		if(!damage || !affecting || prob(miss_chance))//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, attacking_bodypart.unarmed_miss_sound, 25, TRUE, -1)
			target.visible_message(span_danger("[user]'s [atk_verb] misses [target]!"), \
							span_danger("You avoid [user]'s [atk_verb]!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, span_warning("Your [atk_verb] misses [target]!"))
			log_combat(user, target, "attempted to punch")
			return FALSE

		var/armor_block = target.run_armor_check(affecting, MELEE)

		playsound(target.loc, attacking_bodypart.unarmed_attack_sound, 25, TRUE, -1)

		if(grappled && attacking_bodypart.grappled_attack_verb)
			atk_verb = attacking_bodypart.grappled_attack_verb
		target.visible_message(span_danger("[user] [atk_verb]ed [target]!"), \
						span_userdanger("You're [atk_verb]ed by [user]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [atk_verb] [target]!"))

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		var/attack_direction = get_dir(user, target)
		var/attack_type = attacking_bodypart.attack_type
		var/attack_sharp = NONE
		if(atk_effect == ATTACK_EFFECT_CLAW || atk_effect == ATTACK_EFFECT_BITE)
			attack_sharp = SHARP_EDGED
		else if(atk_effect == ATTACK_EFFECT_BITE)
			attack_type = SHARP_POINTY

		if(atk_effect == ATTACK_EFFECT_KICK || grappled) //kicks and punches when grappling bypass armor slightly.
			if(damage >= 9)
				target.force_say()
			log_combat(user, target, grappled ? "grapple punched" : "kicked")
			target.apply_damage(damage, attack_type, affecting, armor_block - limb_accuracy, sharpness = attack_sharp, attack_direction = attack_direction)
			target.apply_damage(damage * 1.5, STAMINA, affecting, armor_block - limb_accuracy)

		else // Normal attacks do not gain the benefit of armor penetration.
			target.apply_damage(damage, attack_type, affecting, armor_block, sharpness = attack_sharp, attack_direction = attack_direction)
			target.apply_damage(damage * 1.5, STAMINA, affecting, armor_block)
			if(damage >= 9)
				target.force_say()
			log_combat(user, target, "punched")

		//If we rolled a punch high enough to hit our stun threshold, or our target is staggered and they have at least 40 damage+stamina loss, we knock them down
		if(prob(limb_accuracy) && target.stat != DEAD && armor_block < 100 && staggered && (target.getStaminaLoss() + user.getBruteLoss()) >= 40)
			var/was_standing = target.body_position == STANDING_UP
			var/knockdown_duration = 4 SECONDS + (target.getStaminaLoss() + (target.getBruteLoss() * 0.5)) * 0.8 //50 total damage = 4 second base stun + 4 second stun modifier = 8 second knockdown duration
			target.apply_effect(knockdown_duration, EFFECT_KNOCKDOWN, armor_block)
			log_combat(user, target, "got a stun punch with their previous punch")
			// only shows the message if we changed states
			if(was_standing && target.body_position != STANDING_UP)
				target.visible_message(
					span_danger("[user] knocks [target] down!"),
					span_userdanger("You're knocked down by [user]!"),
					span_hear("You hear aggressive shuffling followed by a loud thud!"),
					COMBAT_MESSAGE_RANGE,
				)

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(attacker_style?.disarm_act(user,target) == MARTIAL_ATTACK_SUCCESS)
		return TRUE
	if(user.body_position != STANDING_UP)
		return FALSE
	if(user == target)
		return FALSE
	if(user.loc == target.loc)
		return FALSE
	user.disarm(target)

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/owner, mob/living/carbon/human/target, datum/martial_art/attacker_style, modifiers)
	if(!istype(owner))
		return
	CHECK_DNA_AND_SPECIES(owner)
	CHECK_DNA_AND_SPECIES(target)

	if(!istype(owner)) //sanity check for drones.
		return
	if(owner.mind)
		attacker_style = owner.mind.martial_art
	if((owner != target) && target.check_block(owner, 0, owner.name, attack_type = UNARMED_ATTACK))
		log_combat(owner, target, "attempted to touch")
		target.visible_message(span_warning("[owner] attempts to touch [target]!"), \
						span_danger("[owner] attempts to touch you!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, owner)
		to_chat(owner, span_warning("You attempt to touch [target]!"))
		return

	SEND_SIGNAL(owner, COMSIG_MOB_ATTACK_HAND, owner, target, attacker_style)

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		disarm(owner, target, attacker_style)
		return // dont attack after
	if(owner.combat_mode)
		harm(owner, target, attacker_style)
	else
		help(owner, target, attacker_style)

////////////
//  Stun  //
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	if(H.movement_type & FLYING)
		var/obj/item/organ/external/wings/functional/wings = H.get_organ_slot(ORGAN_SLOT_EXTERNAL_WINGS)
		if(wings)
			wings.toggle_flight(H)
			wings.fly_slip(H)
	. = stunmod * H.physiology.stun_mod * amount

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	if(H.movement_type & FLYING)
		return TRUE
	return FALSE

////////////////
//Tail Wagging//
////////////////

/*
 * Clears all tail related moodlets when they lose their species.
 *
 * former_tail_owner - the mob that was once a species with a tail and now is a different species
 */
/datum/species/proc/clear_tail_moodlets(mob/living/carbon/human/former_tail_owner)
	former_tail_owner.clear_mood_event("tail_lost")
	former_tail_owner.clear_mood_event("tail_balance_lost")
	former_tail_owner.clear_mood_event("tail_regained")

/// Returns a list of strings representing features this species has.
/// Used by the preferences UI to know what buttons to show.
/datum/species/proc/get_features()
	var/cached_features = GLOB.features_by_species[type]
	if (!isnull(cached_features))
		return cached_features

	var/list/features = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]

		if ( \
			(preference.relevant_mutant_bodypart in mutant_bodyparts) \
			|| (preference.relevant_inherent_trait in inherent_traits) \
			|| (preference.relevant_external_organ in external_organs) \
			|| (preference.relevant_head_flag && check_head_flags(preference.relevant_head_flag)) \
		)
			features += preference.savefile_key

	for (var/obj/item/organ/external/organ_type as anything in external_organs)
		var/preference = initial(organ_type.preference)
		if (!isnull(preference))
			features += preference

	GLOB.features_by_species[type] = features

	return features

/// Given a human, will adjust it before taking a picture for the preferences UI.
/// This should create a CONSISTENT result, so the icons don't randomly change.
/datum/species/proc/prepare_human_for_preview(mob/living/carbon/human/human)
	return

/// Returns the species' scream sound.
/datum/species/proc/get_scream_sound(mob/living/carbon/human/human)
	return

/// Returns the species' cry sound.
/datum/species/proc/get_cry_sound(mob/living/carbon/human/human)
	return

/// Returns the species' cough sound.
/datum/species/proc/get_cough_sound(mob/living/carbon/human/human)
	return

/// Returns the species' laugh sound
/datum/species/proc/get_laugh_sound(mob/living/carbon/human/human)
	return

/// Returns the species' sneeze sound.
/datum/species/proc/get_sneeze_sound(mob/living/carbon/human/human)
	return

/datum/species/proc/get_types_to_preload()
	var/list/to_store = list()
	to_store += mutant_organs
	for(var/obj/item/organ/external/horny as anything in external_organs)
		to_store += horny //Haha get it?

	//Don't preload brains, cause reuse becomes a horrible headache
	to_store += mutantheart
	to_store += mutantlungs
	to_store += mutanteyes
	to_store += mutantears
	to_store += mutanttongue
	to_store += mutantliver
	to_store += mutantstomach
	to_store += mutantappendix
	//We don't cache mutant hands because it's not constrained enough, too high a potential for failure
	return to_store


/**
 * Owner login
 */

/**
 * A simple proc to be overwritten if something needs to be done when a mob logs in. Does nothing by default.
 *
 * Arguments:
 * * owner - The owner of our species.
 */
/datum/species/proc/on_owner_login(mob/living/carbon/human/owner)
	return

/**
 * Gets a description of the species' *physical* attributes. What makes playing as one different. Used in magic mirrors.
 *
 * Returns a string.
 */

/datum/species/proc/get_physical_attributes()
	return "An unremarkable species."
/**
 * Gets a short description for the specices. Should be relatively succinct.
 * Used in the preference menu.
 *
 * Returns a string.
 */

/datum/species/proc/get_species_description()
	SHOULD_CALL_PARENT(FALSE)

	stack_trace("Species [name] ([type]) did not have a description set, and is a selectable roundstart race! Override get_species_description.")
	return "No species description set, file a bug report!"

/**
 * Gets the lore behind the type of species. Can be long.
 * Used in the preference menu.
 *
 * Returns a list of strings.
 * Between each entry in the list, a newline will be inserted, for formatting.
 */
/datum/species/proc/get_species_lore()
	SHOULD_CALL_PARENT(FALSE)
	RETURN_TYPE(/list)

	stack_trace("Species [name] ([type]) did not have lore set, and is a selectable roundstart race! Override get_species_lore.")
	return list("No species lore set, file a bug report!")

/**
 * Translate the species liked foods from bitfields into strings
 * and returns it in the form of an associated list.
 *
 * Returns a list, or null if they have no diet.
 */
/datum/species/proc/get_species_diet()
	if((TRAIT_NOHUNGER in inherent_traits) || !mutanttongue)
		return null

	var/static/list/food_flags = FOOD_FLAGS
	var/obj/item/organ/internal/tongue/fake_tongue = mutanttongue

	return list(
		"liked_food" = bitfield_to_list(initial(fake_tongue.liked_foodtypes), food_flags),
		"disliked_food" = bitfield_to_list(initial(fake_tongue.disliked_foodtypes), food_flags),
		"toxic_food" = bitfield_to_list(initial(fake_tongue.toxic_foodtypes), food_flags),
	)

/**
 * Generates a list of "perks" related to this species
 * (Postives, neutrals, and negatives)
 * in the format of a list of lists.
 * Used in the preference menu.
 *
 * "Perk" format is as followed:
 * list(
 *   SPECIES_PERK_TYPE = type of perk (postiive, negative, neutral - use the defines)
 *   SPECIES_PERK_ICON = icon shown within the UI
 *   SPECIES_PERK_NAME = name of the perk on hover
 *   SPECIES_PERK_DESC = description of the perk on hover
 * )
 *
 * Returns a list of lists.
 * The outer list is an assoc list of [perk type]s to a list of perks.
 * The innter list is a list of perks. Can be empty, but won't be null.
 */
/datum/species/proc/get_species_perks()
	var/list/species_perks = list()

	// Let us get every perk we can concieve of in one big list.
	// The order these are called (kind of) matters.
	// Species unique perks first, as they're more important than genetic perks,
	// and language perk last, as it comes at the end of the perks list
	species_perks += create_pref_unique_perks()
	species_perks += create_pref_blood_perks()
	species_perks += create_pref_damage_perks()
	species_perks += create_pref_temperature_perks()
	species_perks += create_pref_traits_perks()
	species_perks += create_pref_biotypes_perks()
	species_perks += create_pref_organs_perks()
	species_perks += create_pref_language_perk()

	// Some overrides may return `null`, prevent those from jamming up the list.
	list_clear_nulls(species_perks)

	// Now let's sort them out for cleanliness and sanity
	var/list/perks_to_return = list(
		SPECIES_POSITIVE_PERK = list(),
		SPECIES_NEUTRAL_PERK = list(),
		SPECIES_NEGATIVE_PERK =  list(),
	)

	for(var/list/perk as anything in species_perks)
		var/perk_type = perk[SPECIES_PERK_TYPE]
		// If we find a perk that isn't postiive, negative, or neutral,
		// it's a bad entry - don't add it to our list. Throw a stack trace and skip it instead.
		if(isnull(perks_to_return[perk_type]))
			stack_trace("Invalid species perk ([perk[SPECIES_PERK_NAME]]) found for species [name]. \
				The type should be positive, negative, or neutral. (Got: [perk_type])")
			continue

		perks_to_return[perk_type] += list(perk)

	return perks_to_return

/**
 * Used to add any species specific perks to the perk list.
 *
 * Returns null by default. When overriding, return a list of perks.
 */
/datum/species/proc/create_pref_unique_perks()
	return null

/**
 * Adds adds any perks related to sustaining damage.
 * For example, brute damage vulnerability, or fire damage resistance.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_damage_perks()
	// We use the chest to figure out brute and burn mod perks
	var/obj/item/bodypart/chest/fake_chest = bodypart_overrides[BODY_ZONE_CHEST]

	var/list/to_add = list()

	// Brute related
	if(initial(fake_chest.brute_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "band-aid",
			SPECIES_PERK_NAME = "Brutal Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to brute damage.",
		))

	if(initial(fake_chest.brute_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Brutal Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to brute damage.",
		))

	// Burn related
	if(initial(fake_chest.burn_modifier) > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "burn",
			SPECIES_PERK_NAME = "Burn Weakness",
			SPECIES_PERK_DESC = "[plural_form] are weak to burn damage.",
		))

	if(initial(fake_chest.burn_modifier) < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Burn Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to burn damage.",
		))

	// Shock damage
	if(siemens_coeff > 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Shock Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to being shocked.",
		))

	if(siemens_coeff < 1)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Shock Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to being shocked.",
		))

	return to_add

/**
 * Adds adds any perks related to how the species deals with temperature.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_temperature_perks()
	var/list/to_add = list()

	// Hot temperature tolerance
	if(heatmod > 1 || bodytemp_heat_damage_limit < BODYTEMP_HEAT_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-high",
			SPECIES_PERK_NAME = "Heat Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to high temperatures.",
		))

	if(heatmod < 1 || bodytemp_heat_damage_limit > BODYTEMP_HEAT_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Heat Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to hotter environments.",
		))

	// Cold temperature tolerance
	if(coldmod > 1 || bodytemp_cold_damage_limit > BODYTEMP_COLD_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Cold Vulnerability",
			SPECIES_PERK_DESC = "[plural_form] are vulnerable to cold temperatures.",
		))

	if(coldmod < 1 || bodytemp_cold_damage_limit < BODYTEMP_COLD_DAMAGE_LIMIT)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-empty",
			SPECIES_PERK_NAME = "Cold Resilience",
			SPECIES_PERK_DESC = "[plural_form] are resilient to colder environments.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' blood (or lack thereof).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_blood_perks()
	var/list/to_add = list()

	// TRAIT_NOBLOOD takes priority by default
	if(TRAIT_NOBLOOD in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tint-slash",
			SPECIES_PERK_NAME = "Bloodletted",
			SPECIES_PERK_DESC = "[plural_form] do not have blood.",
		))

	// NON-MODULE CHANGE for blood
	// Otherwise, check for exotic blood types
	else if(exotic_bloodtype)
		var/blood_name = ""
		if(ispath(exotic_bloodtype, /datum/blood_type))
			var/datum/blood_type/exotic_typed = exotic_bloodtype
			blood_name = initial(exotic_typed.name)
		if(ispath(exotic_bloodtype, /datum/reagent))
			var/datum/reagent/exotic_typed = exotic_bloodtype
			blood_name = initial(exotic_typed.name)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = blood_name,
			SPECIES_PERK_DESC = "[name] blood is [blood_name], which can make recieving medical treatment harder.",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_traits list.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_traits_perks()
	var/list/to_add = list()

	if(TRAIT_LIMBATTACHMENT in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-plus",
			SPECIES_PERK_NAME = "Limbs Easily Reattached",
			SPECIES_PERK_DESC = "[plural_form] limbs are easily readded, and as such do not \
				require surgery to restore. Simply pick it up and pop it back in, champ!",
		))

	if(TRAIT_EASYDISMEMBER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "user-times",
			SPECIES_PERK_NAME = "Limbs Easily Dismembered",
			SPECIES_PERK_DESC = "[plural_form] limbs are not secured well, and as such they are easily dismembered.",
		))

	if(TRAIT_EASILY_WOUNDED in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "user-times",
			SPECIES_PERK_NAME = "Easily Wounded",
			SPECIES_PERK_DESC = "[plural_form] skin is very weak and fragile. They are much easier to apply serious wounds to.",
		))

	if(TRAIT_TOXINLOVER in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "syringe",
			SPECIES_PERK_NAME = "Toxins Lover",
			SPECIES_PERK_DESC = "Toxins damage dealt to [plural_form] are reversed - healing toxins will instead cause harm, and \
				causing toxins will instead cause healing. Be careful around purging chemicals!",
		))

	if (TRAIT_GENELESS in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "dna",
			SPECIES_PERK_NAME = "No Genes",
			SPECIES_PERK_DESC = "[plural_form] have no genes, making genetic scrambling a useless weapon, but also locking them out from getting genetic powers.",
		))

	if (TRAIT_NOBREATH in inherent_traits)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "No Respiration",
			SPECIES_PERK_DESC = "[plural_form] have no need to breathe!",
		))

	return to_add

/**
 * Adds adds any perks related to the species' inherent_biotypes flags.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_biotypes_perks()
	var/list/to_add = list()

	if(inherent_biotypes & MOB_UNDEAD)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Undead",
			SPECIES_PERK_DESC = "[plural_form] are of the undead! The undead do not have the need to eat or breathe, and \
				most viruses will not be able to infect a walking corpse. Their worries mostly stop at remaining in one piece, really.",
		))

	return to_add

/**
 * Adds any perks relating to inherent differences to this species' organs.
 * This proc is only suitable for generic differences, like alcohol tolerance, or heat threshold for breathing.
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_organs_perks()
	RETURN_TYPE(/list)

	var/list/to_add = list()

	to_add += create_pref_liver_perks()
	to_add += create_pref_lung_perks()

	return to_add

/datum/species/proc/create_pref_liver_perks()
	RETURN_TYPE(/list)

	var/list/to_add = list()

	var/alcohol_tolerance = initial(mutantliver.alcohol_tolerance)
	var/obj/item/organ/internal/liver/base_liver = /obj/item/organ/internal/liver
	var/tolerance_difference = alcohol_tolerance - initial(base_liver.alcohol_tolerance)

	if (tolerance_difference != 0)
		var/difference_positive = (tolerance_difference > 0)
		var/more_or_less = (difference_positive) ? "more" : "less"
		var/perk_type = (difference_positive) ? SPECIES_NEGATIVE_PERK : SPECIES_POSITIVE_PERK
		var/perk_name = "Alcohol " + ((difference_positive) ? "Weakness" : "Tolerance")
		var/percent_difference = (alcohol_tolerance / initial(base_liver.alcohol_tolerance)) * 100

		to_add += list(list(
			SPECIES_PERK_TYPE = perk_type,
			SPECIES_PERK_ICON = "wine-glass",
			SPECIES_PERK_NAME = perk_name,
			SPECIES_PERK_DESC = "[name] livers are [more_or_less] susceptable to alcohol than human livers, by about [percent_difference]%."
		))

	var/tox_shrugging = initial(mutantliver.toxTolerance)
	var/shrugging_difference = tox_shrugging - initial(base_liver.toxTolerance)
	if (shrugging_difference != 0)
		var/difference_positive = (shrugging_difference > 0)
		var/more_or_less = (difference_positive) ? "more" : "less"
		var/perk_type = (difference_positive) ? SPECIES_POSITIVE_PERK : SPECIES_NEGATIVE_PERK
		var/perk_name = ("Toxin " + ((difference_positive) ? "Resistant" : "Vulnerable")) + " Liver"

		to_add += list(list(
			SPECIES_PERK_TYPE = perk_type,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = perk_name,
			SPECIES_PERK_DESC = "[name] livers are capable of rapidly shrugging off [tox_shrugging]u of toxins, which is [more_or_less] than humans."
		))

	return to_add

/datum/species/proc/create_pref_lung_perks()
	RETURN_TYPE(/list)

	var/list/to_add = list()

	if (breathid != GAS_O2)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "[capitalize(breathid)] Breathing",
			SPECIES_PERK_DESC = "[plural_form] must breathe [breathid] to survive. You receive a tank when you arrive.",
		))

	return to_add

/**
 * Adds in a language perk based on all the languages the species
 * can speak by default (according to their language holder).
 *
 * Returns a list containing perks, or an empty list.
 */
/datum/species/proc/create_pref_language_perk()

	// Grab galactic common as a path, for comparisons
	var/datum/language/common_language = /datum/language/common

	// Now let's find all the languages they can speak that aren't common
	var/list/bonus_languages = list()
	var/datum/language_holder/basic_holder = GLOB.prototype_language_holders[species_language_holder]
	for(var/datum/language/language_type as anything in basic_holder.spoken_languages)
		if(ispath(language_type, common_language))
			continue
		bonus_languages += initial(language_type.name)

	if(!length(bonus_languages))
		return // You're boring

	var/list/to_add = list()
	if(common_language in basic_holder.spoken_languages)
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Native Speaker",
			SPECIES_PERK_DESC = "Alongside [initial(common_language.name)], [plural_form] gain the ability to speak [english_list(bonus_languages)].",
		))

	else
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "comment",
			SPECIES_PERK_NAME = "Foreign Speaker",
			SPECIES_PERK_DESC = "[plural_form] may not speak [initial(common_language.name)], but they can speak [english_list(bonus_languages)].",
		))

	return to_add

///Handles replacing all of the bodyparts with their species version during set_species()
/datum/species/proc/replace_body(mob/living/carbon/target, datum/species/new_species)
	new_species ||= target.dna.species //If no new species is provided, assume its src.
	//Note for future: Potentionally add a new C.dna.species() to build a template species for more accurate limb replacement

	var/list/final_bodypart_overrides = new_species.bodypart_overrides.Copy()
	if((new_species.digitigrade_customization == DIGITIGRADE_OPTIONAL && target.dna.features["legs"] == DIGITIGRADE_LEGS) || new_species.digitigrade_customization == DIGITIGRADE_FORCED)
		final_bodypart_overrides[BODY_ZONE_R_LEG] = /obj/item/bodypart/leg/right/digitigrade
		final_bodypart_overrides[BODY_ZONE_L_LEG] = /obj/item/bodypart/leg/left/digitigrade

	for(var/obj/item/bodypart/old_part as anything in target.bodyparts)
		if((old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES) || (old_part.bodypart_flags & BODYPART_IMPLANTED))
			continue

		var/path = final_bodypart_overrides?[old_part.body_zone]
		var/obj/item/bodypart/new_part
		if(path)
			new_part = new path()
			new_part.replace_limb(target, TRUE)
			new_part.update_limb(is_creating = TRUE)
			new_part.set_initial_damage(old_part.brute_dam, old_part.burn_dam)
		qdel(old_part)

/// Creates body parts for the target completely from scratch based on the species
/datum/species/proc/create_fresh_body(mob/living/carbon/target)
	target.create_bodyparts(bodypart_overrides)

/**
 * Checks if the species has a head with these head flags, by default.
 * Admittedly, this is a very weird and seemingly redundant proc, but it
 * gets used by some preferences (such as hair style) to determine whether
 * or not they are accessible.
 **/
/datum/species/proc/check_head_flags(check_flags = NONE)
	var/obj/item/bodypart/head/fake_head = bodypart_overrides[BODY_ZONE_HEAD]
	return (initial(fake_head.head_flags) & check_flags)

/datum/species/dump_harddel_info()
	if(harddel_deets_dumped)
		return
	harddel_deets_dumped = TRUE
	return "Gained / Owned: [properly_gained ? "Yes" : "No"]"

/**
 * Get what hair color is used by this species for a mob.
 *
 * Arguments
 * * for_mob - The mob to get the hair color for. Required.
 *
 * Returns a color string or null.
 */
/datum/species/proc/get_fixed_hair_color(mob/living/carbon/human/for_mob)
	ASSERT(!isnull(for_mob))
	switch(hair_color_mode)
		if(USE_MUTANT_COLOR)
			return for_mob.dna.features["mcolor"]
		if(USE_FIXED_MUTANT_COLOR)
			return fixed_mut_color

	return null
