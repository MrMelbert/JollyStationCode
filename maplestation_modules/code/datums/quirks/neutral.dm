// --Adds the neutral quirk to start with TDATET cards and a binder to quickly play a game and store said cards.
/datum/quirk/item_quirk/cardcollector
	name = "Card Collector"
	desc = "You carry your personal card binder and fresh packs of unopened cards, it's time to duel!"
	icon = "diamond"
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
	//Will add named cardbinder, starting base 2 cards, and a packbox of 28 Red cards.
	give_item_to_holder(card_binder, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(/obj/item/cardpack/tdatet_box, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(/obj/item/cardpack/tdatet_base, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
