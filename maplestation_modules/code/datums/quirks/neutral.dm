// --Adds the neutral quirk to start with TDATET cards and a binder to quickly play a game and store said cards.
/datum/quirk/item_quirk/cardcollector
	name = "Card Collector"
	desc = "You carry your personal card binder and fresh packs of unopened cards, it's time to duel!"
	icon = FA_ICON_DIAMOND
	value = 0
	mob_trait = TRAIT_CARDCOLLECTOR //The only instance of this being used is for an examine more of the TdateT packs for a single line of text, I may use this to show rarity rates or other silly things someone that likes cards would notice.
	gain_text = "<span class='notice'>You trust in the heart of the cards.</span>"
	lose_text = "<span class='danger'>You forget what these funny bookmarks used to be.</span>"
	medical_record_text = "Patient mentions their card collection as a stress-relieving hobby."
	//A chance to get a cardpack for tdatet in the mail.
	mail_goodies = list(
		/obj/item/cardpack/tdatet,
		/obj/item/cardpack/tdatet/green,
		/obj/item/cardpack/tdatet/blue,
		/obj/item/cardpack/tdatet/mixed,
		/obj/item/cardpack/tdatet_box,
	)

/datum/quirk/item_quirk/cardcollector/add_unique()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/storage/card_binder/personal/card_binder = new(get_turf(human_holder))
	/*Will be commented out until someone figures out persistence, which is unlikely but this will stay here just incase!
	card_binder.persistence_id = "personal_[human_holder.last_mind?.key]" // this is a persistent binder, the ID is tied to the account's key to avoid tampering, just like the Photo album.
	card_binder.persistence_load() */
	card_binder.name = "[human_holder.real_name]'s card binder"
	//Will add named cardbinder, starting base 2 cards, packbox of 28 Red cards, 4 counters, and a paper with rules. Now in a handy box!
	give_item_to_holder(card_binder, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(/obj/item/storage/box/tdatet_starter, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))

/datum/quirk/cpr_certified
	name = "CPR Certified"
	desc = "You are certified to perform CPR on others independent of your job."
	medical_record_text = "Patient has completed CPR certification."
	icon = FA_ICON_HEARTBEAT
	value = 0
	mob_trait = TRAIT_CPR_CERTIFIED

/datum/quirk/caffeinated
	name = "Caffeinated"
	desc = "You just can't imagine a day without some sort of caffeinated beverage. You're slightly weaker without caffeine, but slightly boosted with it."
	icon = FA_ICON_COFFEE
	value = 0
	mob_trait = TRAIT_CAFFEINE_LOVER //Might aswell love the drinks while we're at it
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	gain_text = span_notice("You can't wait to start your day with a nice energizing drink!")
	lose_text = span_danger("You realize excessive amounts of caffeine likely has detrimental effects on your cardiovascular system.")
	medical_record_text = "Patient snatched the observation officer's coffee, drank it and then asked for seconds."
	/// Did we drink literally anything caffeinated in the round?
	var/caffeine_drank = FALSE
	/// Are we going to fucking die?
	var/caffeine_overdosed = FALSE
	/// The current sprint length multiplier
	var/sprint_length_multiplier = 1
	/// The current sprint regen multiplier
	var/sprint_regen_multiplier = 1
	/// How much caffeine is currently in our system
	var/caffeine_content = 0
	/// Decay rate on caffeine content, pretty much for varedits
	var/caffeine_decay_rate = 0.05

/datum/quirk/caffeinated/add(client/client_source)
	adjust_sprint_multipliers(0.33, 0.2)
	RegisterSignal(quirk_holder, COMSIG_CARBON_DRINK_CAFFEINE, PROC_REF(drank_caffeine))
	quirk_holder.add_mood_event("caffeine", /datum/mood_event/no_coffee)

/datum/quirk/caffeinated/process(seconds_per_tick)
	if(HAS_TRAIT(quirk_holder, TRAIT_LIVERLESS_METABOLISM))
		return
	if(!caffeine_drank)
		return

	if(caffeine_content > 0)
		caffeine_content = max(caffeine_content - caffeine_decay_rate * seconds_per_tick, 0)

	if(caffeine_content >= 400 || caffeine_overdosed) //we're becoming downright godly at this point, also you have to either slam down >100 units of energy drinks back-to-back or >400 units of coffee.
		adjust_sprint_multipliers(2, 4)
		if(!caffeine_overdosed)
			quirk_holder.add_mood_event("caffeine", /datum/mood_event/way_too_high_caffeine)
			caffeine_overdosed = TRUE
			addtimer(src, CALLBACK(PROC_REF(caffeine_overdose)), 4 MINUTES) //wuh oh
		return

	if(caffeine_content > 4)
		quirk_holder.add_mood_event("caffeine", /datum/mood_event/high_caffeine)
		adjust_sprint_multipliers(1.25, 1.5)
		return

	if(caffeine_content <= 4)
		quirk_holder.add_mood_event("caffeine", /datum/mood_event/low_caffeine)
		adjust_sprint_multipliers(0.75, 0.5)
		return

	//We should've returned by now, if we didn't, that means caffeine_content is somehow not a number
	CRASH("Someone has transcended spacetime and become so caffeinated that it's not even a number anymore.")

/datum/quirk/caffeinated/proc/drank_caffeine(mob/living/carbon/source, beverage_caffeine_content)
	SIGNAL_HANDLER

	if(!caffeine_drank)
		caffeine_drank = TRUE
	caffeine_content += beverage_caffeine_content

/datum/quirk/caffeinated/proc/caffeine_overdose()
	if(caffeine_overdosed)
		quirk_holder.add_mood_event("caffeine", /datum/mood_event/caffeine_death)
		var/mob/living/carbon/quirk_carbon = quirk_holder
		if(quirk_carbon.can_heartattack() && !quirk_carbon.undergoing_cardiac_arrest())
			to_chat(quirk_carbon, span_userdanger("Your heart stops!"))
			quirk_carbon.visible_message(span_danger("[quirk_carbon] grabs at their chest and collapses!"), ignored_mobs = quirk_carbon)
			quirk_carbon.set_heartattack(TRUE)
		caffeine_overdosed = FALSE

/datum/quirk/caffeinated/proc/adjust_sprint_multipliers(new_sprint_length, new_sprint_regen)
	if((new_sprint_length == sprint_length_multiplier) && (new_sprint_regen == sprint_regen_multiplier))
		return
	var/mob/living/carbon/human/quirk_human = quirk_holder
	//Reset to 1.
	quirk_human.sprint_length_max /= sprint_length_multiplier
	quirk_human.sprint_regen_per_second /= sprint_regen_multiplier
	sprint_length_multiplier = new_sprint_length
	sprint_regen_multiplier = new_sprint_regen
	quirk_human.sprint_length_max *= new_sprint_length
	quirk_human.sprint_regen_per_second *= new_sprint_regen

#define RANDOM_INNATE_MUTATION "Random"

/datum/quirk/innate_neutral_mutation
	name = "Minorly Mutated"
	desc = "You have some kind of minor mutation which is unaffected by Mutadone. \
		Species without DNA are unaffected by this quirk."
	icon = FA_ICON_DNA
	value = 0
	quirk_flags = QUIRK_HUMAN_ONLY
	medical_record_text = "Patient has some kind of mutation untreatable by Mutadone."

/datum/quirk/innate_neutral_mutation/add_unique(client/client_source)
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	if(!human_holder.can_mutate())
		return

	var/datum/preference/choiced/innate_neutral_mutation/mut_pref = GLOB.preference_entries[/datum/preference/choiced/innate_neutral_mutation]
	var/mut_name = client_source?.prefs.read_preference(/datum/preference/choiced/innate_neutral_mutation) || RANDOM_INNATE_MUTATION
	var/mut_type = mut_pref.mut_options[mut_name] || mut_pref.mut_options[pick(mut_pref.mut_options)]

	var/datum/mutation/human/mut = new mut_type()
	mut.mutadone_proof = TRUE
	mut.instability = 0
	mut.remove_on_aheal = FALSE
	human_holder.dna.force_give(mut)

	pass(mut_pref) // necessary for linters for some reason?

/datum/quirk/innate_neutral_mutation/remove()
	. = ..()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/datum/preference/choiced/innate_neutral_mutation/mut_pref = GLOB.preference_entries[/datum/preference/choiced/innate_neutral_mutation]

	for(var/datum/mutation/human/mut as anything in human_holder.dna?.mutations)
		if(!mut.mutadone_proof || !mut_pref.mut_options[initial(mut.name)])
			continue
		human_holder.dna.force_lose(mut)

	pass(mut_pref) // same

/datum/quirk_constant_data/mutations
	associated_typepath = /datum/quirk/innate_neutral_mutation
	customization_options = list(/datum/preference/choiced/innate_neutral_mutation)

/datum/preference/choiced/innate_neutral_mutation
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "innate_neutral_mutation"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE
	/// Options for mutations to pick from.
	var/static/list/mut_options

/datum/preference/choiced/innate_neutral_mutation/New()
	. = ..()
	if(!length(mut_options))
		var/list/mutypes = list(
			/datum/mutation/human/chav,
			/datum/mutation/human/medieval,
			/datum/mutation/human/nervousness,
			/datum/mutation/human/swedish,
			/datum/mutation/human/unintelligible,
			/datum/mutation/human/wacky,
		)
		mut_options = list()
		for(var/datum/mutation/human/mutype as anything in mutypes)
			mut_options[initial(mutype.name)] = mutype

/datum/preference/choiced/innate_neutral_mutation/create_default_value()
	return RANDOM_INNATE_MUTATION

/datum/preference/choiced/innate_neutral_mutation/init_possible_values()
	return list(RANDOM_INNATE_MUTATION) + assoc_to_keys(mut_options)

/datum/preference/choiced/innate_neutral_mutation/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE

	return /datum/quirk/innate_neutral_mutation::name in preferences.all_quirks

/datum/preference/choiced/innate_neutral_mutation/apply_to_human(mob/living/carbon/human/target, value)
	return

#undef RANDOM_INNATE_MUTATION

#define COLORBLINDNESS_PROTANOPIA "Protanopia (Red-Green)"
#define COLORBLINDNESS_DEUTERANOPIA "Deuteranopia (Red-Green)"
#define COLORBLINDNESS_TRITANOPIA "Tritanopia (Blue-Yellow)"

// Uses the same values as the colorblind test debug. As always, they're not accurate and if you argue about that or argue like it is accurate i will SLAP YOU
/datum/quirk/colorblind
	name = "Colorblind"
	desc = "You are partially colorblind and are unable to percieve the full color spectrum."
	icon = FA_ICON_PALETTE
	value = 0
	gain_text = span_notice("You suddenly can't see as many colors anymore.")
	lose_text = span_danger("You can see the world in full color now! It's not that great...")
	medical_record_text = "Patient is afflicted with color blindness."
	var/colorblind_type = COLORBLINDNESS_DEUTERANOPIA //cached to prevent on-the-fly prefs switching causing issues

/datum/quirk/colorblind/add(client/client_source)
	colorblind_type = client_source?.prefs?.read_preference(/datum/preference/choiced/colorblindedness)
	switch(colorblind_type)
		if(COLORBLINDNESS_PROTANOPIA)
			quirk_holder.add_client_colour(/datum/client_colour/colorblind/protanopia)
		if(COLORBLINDNESS_DEUTERANOPIA)
			quirk_holder.add_client_colour(/datum/client_colour/colorblind/deuteranopia)
		if(COLORBLINDNESS_TRITANOPIA)
			quirk_holder.add_client_colour(/datum/client_colour/colorblind/tritanopia)

/datum/quirk/colorblind/remove()
	switch(colorblind_type)
		if(COLORBLINDNESS_PROTANOPIA)
			quirk_holder.remove_client_colour(/datum/client_colour/colorblind/protanopia)
		if(COLORBLINDNESS_DEUTERANOPIA)
			quirk_holder.remove_client_colour(/datum/client_colour/colorblind/deuteranopia)
		if(COLORBLINDNESS_TRITANOPIA)
			quirk_holder.remove_client_colour(/datum/client_colour/colorblind/tritanopia)

/datum/quirk_constant_data/colorblind
	associated_typepath = /datum/quirk/colorblind
	customization_options = list(/datum/preference/choiced/colorblindedness)

/datum/preference/choiced/colorblindedness
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "colorblindedness"
	savefile_identifier = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/colorblindedness/create_default_value()
	return COLORBLINDNESS_DEUTERANOPIA // most common type

/datum/preference/choiced/colorblindedness/init_possible_values()
	return list(COLORBLINDNESS_PROTANOPIA, COLORBLINDNESS_DEUTERANOPIA, COLORBLINDNESS_TRITANOPIA)

/datum/preference/choiced/colorblindedness/is_accessible(datum/preferences/preferences)
	if(!..(preferences))
		return FALSE

	return /datum/quirk/colorblind::name in preferences.all_quirks

/datum/preference/choiced/colorblindedness/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/client_colour/colorblind
	priority = 10 // PRIORITY_HIGH

/datum/client_colour/colorblind/protanopia
	colour = list(0.56,0.43,0,0, 0.55,0.44,0,0, 0,0.24,0.75,0, 0,0,0,1, 0,0,0,0)

/datum/client_colour/colorblind/deuteranopia
	colour = list(0.62,0.37,0,0, 0.70,0.30,0,0, 0,0.30,0.70,0, 0,0,0,1, 0,0,0,0)

/datum/client_colour/colorblind/tritanopia
	colour = list(0.95,0.5,0,0, 0,0.43,0.56,0, 0,0.47,0.52,0, 0,0,0,1, 0,0,0,0)

#undef COLORBLINDNESS_PROTANOPIA
#undef COLORBLINDNESS_DEUTERANOPIA
#undef COLORBLINDNESS_TRITANOPIA
