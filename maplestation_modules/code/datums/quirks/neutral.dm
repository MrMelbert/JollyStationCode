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
	RegisterSignals(quirk_holder, list(COMSIG_CARBON_DRINK_CAFFEINE), PROC_REF(drank_caffeine))
	quirk_holder.add_mood_event("caffeine", /datum/mood_event/no_coffee)

/datum/quirk/caffeinated/process(seconds_per_tick)
	if(HAS_TRAIT(quirk_holder, TRAIT_NOMETABOLISM))
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
			addtimer(CALLBACK(PROC_REF(caffeine_overdose)), 4 MINUTES) //wuh oh
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
	if(!caffeine_drank)
		caffeine_drank = TRUE
	caffeine_content += beverage_caffeine_content

/datum/quirk/caffeinated/proc/caffeine_overdose()
	if(caffeine_overdosed)
		quirk_holder.add_mood_event("caffeine", /datum/mood_event/caffeine_death)
		var/mob/living/carbon/quirk_carbon = quirk_holder
		if(quirk_carbon.can_heartattack())
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

