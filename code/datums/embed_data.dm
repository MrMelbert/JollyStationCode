/// Assosciative list of type -> embed data.
GLOBAL_LIST_INIT(embed_by_type, generate_embed_type_cache())

/proc/generate_embed_type_cache()
	var/list/embed_cache = list()
	for(var/datum/embed_data/embed_type as anything in subtypesof(/datum/embed_data))
		var/datum/embed_data/embed = new embed_type
		embed_cache[embed_type] = embed
	return embed_cache

/proc/get_embed_by_type(embed_type)
	var/datum/embed_data/embed = GLOB.embed_by_type[embed_type]
	if(embed)
		return embed
	CRASH("Attempted to get an embed type that did not exist! '[embed_type]'")

/datum/embed_data
	/// Chance for an object to embed into somebody when thrown
	var/embed_chance = 45
	/// Chance for embedded object to fall out (causing pain but removing the object)
	var/fall_chance = 5
	/// Chance for embedded objects to cause pain (damage user)
	var/pain_chance = 15
	/// Coefficient of multiplication for the damage the item does while embedded (this*item.w_class)
	var/pain_mult = 2
	/// Coefficient of multiplication for the damage the item does when it first embeds (this*item.w_class)
	var/impact_pain_mult = 4
	/// Coefficient of multiplication for the damage the item does when it falls out or is removed without a surgery (this*item.w_class)
	var/remove_pain_mult = 6
	/// Time in ticks, total removal time = (this*item.w_class)
	var/rip_time = 30
	/// If this should ignore throw speed threshold of 4
	var/ignore_throwspeed_threshold = FALSE
	/// Chance for embedded objects to cause pain every time they move (jostle)
	var/jostle_chance = 5
	/// Coefficient of multiplication for the damage the item does while
	var/jostle_pain_mult = 1
	/// This percentage of all pain will be dealt as stam damage rather than brute (0-1)
	var/pain_stam_pct = 0
	/// The embed doesn't show up on examine, only on health analyze
	/// (Note: This means you can't rip it out)
	var/hidden_embed = FALSE
	/// How much blood is lost per life tick while embedded
	var/blood_loss = 0.25

/datum/embed_data/proc/generate_with_values(
	embed_chance = src.embed_chance,
	fall_chance = src.fall_chance,
	pain_chance = src.pain_chance,
	pain_mult = src.pain_mult,
	impact_pain_mult = src.impact_pain_mult,
	remove_pain_mult = src.remove_pain_mult,
	rip_time = src.rip_time,
	ignore_throwspeed_threshold = src.ignore_throwspeed_threshold,
	jostle_chance = src.jostle_chance,
	jostle_pain_mult = src.jostle_pain_mult,
	pain_stam_pct = src.pain_stam_pct,
	hidden_embed = src.hidden_embed,
	force_new = FALSE,
)
	var/datum/embed_data/data = (isnull(GLOB.embed_by_type[type]) && !force_new) ? new() : src

	data.embed_chance = embed_chance
	data.fall_chance = fall_chance
	data.pain_chance = pain_chance
	data.pain_mult = pain_mult
	data.impact_pain_mult = impact_pain_mult
	data.remove_pain_mult = remove_pain_mult
	data.rip_time = rip_time
	data.ignore_throwspeed_threshold = ignore_throwspeed_threshold
	data.jostle_chance = jostle_chance
	data.jostle_pain_mult = jostle_pain_mult
	data.pain_stam_pct = pain_stam_pct
	data.hidden_embed = hidden_embed
	return data

/datum/embed_data/proc/on_embed(
	mob/living/carbon/victim,
	obj/item/bodypart/limb,
	obj/item/weapon,
	harmful = weapon?.is_embed_harmless(),
)
	victim.visible_message(
		span_danger("[weapon] [harmful ? "lodges" : "sticks"] itself [harmful ? "in" : "to"] [victim]'s [limb.plaintext_zone]!"),
		span_userdanger("[weapon] [harmful ? "lodges" : "sticks"] itself [harmful ? "in" : "to"] your [limb.plaintext_zone]!"),
	)
	if(harmful)
		playsound(victim, 'sound/weapons/bladeslice.ogg', 40)
