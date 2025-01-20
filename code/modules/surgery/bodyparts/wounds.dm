/**
 * check_wounding() is where we handle rolling for, selecting, and applying a wound if we meet the criteria
 *
 * We generate a "score" for how woundable the attack was based on the damage and other factors discussed in [/obj/item/bodypart/proc/check_woundings_mods], then go down the list from most severe to least severe wounds in that category.
 * We can promote a wound from a lesser to a higher severity this way, but we give up if we have a wound of the given type and fail to roll a higher severity, so no sidegrades/downgrades
 *
 * Arguments:
 * * woundtype- Either WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE, or WOUND_BURN based on the attack type.
 * * damage- How much damage is tied to this attack, since wounding potential scales with damage in an attack (see: WOUND_DAMAGE_EXPONENT)
 * * wound_bonus- The wound_bonus of an attack
 * * bare_wound_bonus- The bare_wound_bonus of an attack
 */
/obj/item/bodypart/proc/check_wounding(woundtype, damage, wound_bonus, bare_wound_bonus, attack_direction, damage_source, sharpness)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/datum/wound)

	if(isnull(owner) || HAS_TRAIT(owner, TRAIT_NEVER_WOUNDED) || (owner.status_flags & GODMODE) || wound_bonus == CANT_WOUND)
		return

	damage *= wound_modifier

	if(woundtype == WOUND_BLUNT && sharpness)
		if(sharpness & SHARP_EDGED)
			woundtype = WOUND_SLASH
		else if (sharpness & SHARP_POINTY)
			woundtype = WOUND_PIERCE

	var/mangled_state = get_mangled_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	var/bio_status = get_bio_state_status()

	var/has_exterior = ((bio_status & ANATOMY_EXTERIOR))
	var/has_interior = ((bio_status & ANATOMY_INTERIOR))

	var/exterior_ready_to_dismember = (!has_exterior || (mangled_state & BODYPART_MANGLED_EXTERIOR))

	// if we're bone only, all cutting attacks go straight to the bone
	if(!has_exterior && has_interior)
		if(woundtype == WOUND_SLASH)
			woundtype = WOUND_BLUNT
			damage *= (easy_dismember ? 1 : 0.6)
		else if(woundtype == WOUND_PIERCE)
			woundtype = WOUND_BLUNT
			damage *= (easy_dismember ? 1 : 0.75)
	else
		// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
		// So a big sharp weapon is still all you need to destroy a limb
		if(has_interior && exterior_ready_to_dismember && !(mangled_state & BODYPART_MANGLED_INTERIOR) && sharpness)
			if(woundtype == WOUND_SLASH && !easy_dismember)
				damage *= 0.6 // edged weapons pass along 60% of their wounding damage to the bone since the power is spread out over a larger area
			if(woundtype == WOUND_PIERCE && !easy_dismember)
				damage *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
			woundtype = WOUND_BLUNT

	if(HAS_TRAIT(owner, TRAIT_HARDLY_WOUNDED))
		damage *= 0.85

	if(easy_dismember)
		damage *= 1.1

	if(HAS_TRAIT(owner, TRAIT_EASYBLEED) && (woundtype == WOUND_PIERCE || woundtype == WOUND_SLASH))
		damage *= 1.5

	// note that these are fed into an exponent, so these are magnified
	if(HAS_TRAIT(owner, TRAIT_EASILY_WOUNDED))
		damage *= 1.5
	// this needs to happen last!
	else
		damage = min(damage, WOUND_MAX_CONSIDERED_DAMAGE)

	if(damage <= WOUND_MINIMUM_DAMAGE)
		return
	// checks cumulative dismemberment
	if(in_dismemberable_state() && try_dismember(woundtype, damage, wound_bonus, bare_wound_bonus))
		return

	var/base_roll = rand(1, round(damage ** WOUND_DAMAGE_EXPONENT))
	var/injury_roll = base_roll + check_woundings_mods(woundtype, damage, wound_bonus, bare_wound_bonus)

	// checks outright dismemberment
	if(injury_roll > WOUND_DISMEMBER_OUTRIGHT_THRESH && prob(get_damage() / max_damage * 100) && can_dismember())
		var/datum/wound/loss/dismembering = new
		dismembering.apply_dismember(src, woundtype, TRUE, attack_direction)
		return

	var/list/datum/wound/possible_wounds = get_possible_wounds(injury_roll, woundtype, damage, attack_direction, damage_source)

	while (TRUE)
		var/datum/wound/possible_wound = pick_weight(possible_wounds)
		if (isnull(possible_wound))
			break

		possible_wounds -= possible_wound
		var/datum/wound_pregen_data/possible_pregen_data = GLOB.all_wound_pregen_data[possible_wound]

		var/datum/wound/replaced_wound
		for(var/datum/wound/existing_wound as anything in wounds)
			var/datum/wound_pregen_data/existing_pregen_data = GLOB.all_wound_pregen_data[existing_wound.type]
			if(existing_pregen_data.wound_series != possible_pregen_data.wound_series)
				continue
			if(existing_wound.severity >= initial(possible_wound.severity))
				continue
			replaced_wound = existing_wound
			// if we get through this whole loop without continuing, we found our winner

		var/datum/wound/new_wound = new possible_wound
		if(replaced_wound)
			new_wound = replaced_wound.replace_wound(new_wound, attack_direction = attack_direction)
		else
			new_wound.apply_wound(src, attack_direction = attack_direction, wound_source = damage_source)
		log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll) // dismembering wounds are logged in the apply_wound() for loss wounds since they delete themselves immediately, these will be immediately returned
		return new_wound

/obj/item/bodypart/proc/get_possible_wounds(injury_roll, woundtype, damage, attack_direction, damage_source)
	RETURN_TYPE(/list)

	var/list/series_wounding_mods = list()
	for (var/datum/wound/iterated_wound as anything in wounds)
		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[iterated_wound.type]
		series_wounding_mods[pregen_data.wound_series] += iterated_wound.series_threshold_penalty

	var/list/possible_wounds = list()
	for (var/datum/wound/type as anything in GLOB.all_wound_pregen_data)
		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[type]
		if (pregen_data.can_be_applied_to(src, list(woundtype), random_roll = TRUE))
			possible_wounds[type] = pregen_data.get_weight(src, woundtype, damage, attack_direction, damage_source)

	for (var/datum/wound/iterated_path as anything in possible_wounds)
		for (var/datum/wound/existing_wound as anything in wounds)
			if (iterated_path == existing_wound.type)
				possible_wounds -= iterated_path
				break // breaks out of the nested loop

		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[iterated_path]
		var/specific_injury_roll = (injury_roll + series_wounding_mods[pregen_data.wound_series])
		if (pregen_data.get_threshold_for(src, attack_direction, damage_source) > specific_injury_roll)
			possible_wounds -= iterated_path
			continue

		if (pregen_data.compete_for_wounding)
			for (var/datum/wound/other_path as anything in possible_wounds)
				if (other_path == iterated_path)
					continue
				if (initial(iterated_path.severity) == initial(other_path.severity) && pregen_data.overpower_wounds_of_even_severity)
					possible_wounds -= other_path
					continue
				else if (pregen_data.competition_mode == WOUND_COMPETITION_OVERPOWER_LESSERS)
					if (initial(iterated_path.severity) > initial(other_path.severity))
						possible_wounds -= other_path
						continue
				else if (pregen_data.competition_mode == WOUND_COMPETITION_OVERPOWER_GREATERS)
					if (initial(iterated_path.severity) < initial(other_path.severity))
						possible_wounds -= other_path
						continue
	return possible_wounds

// try forcing a specific wound, but only if there isn't already a wound of that severity or greater for that type on this bodypart
/obj/item/bodypart/proc/force_wound_upwards(datum/wound/potential_wound, smited = FALSE, wound_source)
	SHOULD_NOT_OVERRIDE(TRUE)

	if (isnull(potential_wound))
		return

	var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[potential_wound]
	for(var/datum/wound/existing_wound as anything in wounds)
		var/datum/wound_pregen_data/existing_pregen_data = existing_wound.get_pregen_data()
		if (existing_pregen_data.wound_series == pregen_data.wound_series)
			if(existing_wound.severity < initial(potential_wound.severity)) // we only try if the existing one is inferior to the one we're trying to force
				existing_wound.replace_wound(new potential_wound, smited)
			return

	var/datum/wound/new_wound = new potential_wound
	new_wound.apply_wound(src, smited = smited, wound_source = wound_source)
	return new_wound

/**
 *  A simple proc to force a type of wound onto this mob. If you just want to force a specific mainline (fractures, bleeding, etc.) wound, you only need to care about the first 3 args.
 *
 * Args:
 * * wounding_type: The wounding_type, e.g. WOUND_BLUNT, WOUND_SLASH to force onto the mob. Can be a list.
 * * obj/item/bodypart/limb: The limb we wil be applying the wound to. If null, a random bodypart will be picked.
 * * min_severity: The minimum severity that will be considered.
 * * max_severity: The maximum severity that will be considered.
 * * severity_pick_mode: The "pick mode" to be used. See get_corresponding_wound_type's documentation
 * * wound_source: The source of the wound to be applied. Nullable.
 *
 * For the rest of the args, refer to get_corresponding_wound_type().
 *
 * Returns:
 * A new wound instance if the application was successful, null otherwise.
*/
/mob/living/carbon/proc/cause_wound_of_type_and_severity(wounding_type, obj/item/bodypart/limb, min_severity, max_severity = min_severity, severity_pick_mode = WOUND_PICK_HIGHEST_SEVERITY, wound_source)
	if (isnull(limb))
		limb = pick(bodyparts)

	var/list/type_list = wounding_type
	if (!islist(type_list))
		type_list = list(type_list)

	var/datum/wound/corresponding_typepath = get_corresponding_wound_type(type_list, limb, min_severity, max_severity, severity_pick_mode)
	if (corresponding_typepath)
		return limb.force_wound_upwards(corresponding_typepath, wound_source = wound_source)

/// Limb is nullable, but picks a random one. Defers to limb.get_wound_threshold_of_wound_type, see it for documentation.
/mob/living/carbon/proc/get_wound_threshold_of_wound_type(wounding_type, severity, default, obj/item/bodypart/limb, wound_source)
	if (isnull(limb))
		limb = pick(bodyparts)

	if (!limb)
		return default

	return limb.get_wound_threshold_of_wound_type(wounding_type, severity, default, wound_source)

/**
 * A simple proc that gets the best wound to fit the criteria laid out, then returns its wound threshold.
 *
 * Args:
 * * wounding_type: The wounding_type, e.g. WOUND_BLUNT, WOUND_SLASH to force onto the mob. Can be a list of wounding_types.
 * * severity: The severity that will be considered.
 * * return_value_if_no_wound: If no wound is found, we will return this instead. (It is reccomended to use named args for this one, as its unclear what it is without)
 * * wound_source: The theoretical source of the wound. Nullable.
 *
 * Returns:
 * return_value_if_no_wound if no wound is found - if one IS found, the wound threshold for that wound.
 */
/obj/item/bodypart/proc/get_wound_threshold_of_wound_type(wounding_type, severity, return_value_if_no_wound, wound_source)
	var/list/type_list = wounding_type
	if (!islist(type_list))
		type_list = list(type_list)

	var/datum/wound/wound_path = get_corresponding_wound_type(type_list, src, severity, duplicates_allowed = TRUE, care_about_existing_wounds = FALSE)
	if (wound_path)
		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[wound_path]
		return pregen_data.get_threshold_for(src, damage_source = wound_source)

	return return_value_if_no_wound

/**
 * check_wounding_mods() is where we handle the various modifiers of a wound roll
 *
 * A short list of things we consider: any armor a human target may be wearing, and if they have no wound armor on the limb, if we have a bare_wound_bonus to apply, plus the plain wound_bonus
 * We also flick through all of the wounds we currently have on this limb and add their threshold penalties, so that having lots of bad wounds makes you more liable to get hurt worse
 * Lastly, we add the inherent wound_resistance variable the bodypart has (heads and chests are slightly harder to wound), and a small bonus if the limb is already disabled
 *
 * Arguments:
 * * It's the same ones on [/obj/item/bodypart/proc/receive_damage]
 */
/obj/item/bodypart/proc/check_woundings_mods(wounding_type, damage, wound_bonus, bare_wound_bonus)
	SHOULD_CALL_PARENT(TRUE)

	var/armor_ablation = 0
	var/injury_mod = 0

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		for(var/obj/item/clothing/clothes as anything in human_owner.get_clothing_on_part(src))
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			armor_ablation += clothes.get_armor_rating(WOUND)
			if(wounding_type == WOUND_SLASH)
				clothes.take_damage_zone(body_zone, damage, BRUTE)
			else if(wounding_type == WOUND_BURN && damage >= 10) // lazy way to block freezing from shredding clothes without adding another var onto apply_damage()
				clothes.take_damage_zone(body_zone, damage, BURN)

		if(!armor_ablation)
			injury_mod += bare_wound_bonus

	injury_mod -= armor_ablation
	injury_mod += wound_bonus

	for(var/datum/wound/wound as anything in wounds)
		injury_mod += wound.threshold_penalty

	var/part_mod = -wound_resistance
	if(get_damage() >= max_damage)
		part_mod += disabled_wound_penalty

	injury_mod += part_mod

	return injury_mod

/// Get whatever wound of the given type is currently attached to this limb, if any
/obj/item/bodypart/proc/get_wound_type(checking_type)
	RETURN_TYPE(checking_type)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(isnull(wounds))
		return

	for(var/wound in wounds)
		if(istype(wound, checking_type))
			return wound

/**
 * update_wounds() is called whenever a wound is gained or lost on this bodypart, as well as if there's a change of some kind on a bone wound possibly changing disabled status
 *
 * Covers tabulating the damage multipliers we have from wounds (burn specifically), as well as deleting our gauze wrapping if we don't have any wounds that can use bandaging
 *
 * Arguments:
 * * replaced- If true, this is being called from the remove_wound() of a wound that's being replaced, so the bandage that already existed is still relevant, but the new wound hasn't been added yet
 */
/obj/item/bodypart/proc/update_wounds(replaced = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	var/dam_mul = 1

	// we can (normally) only have one wound per type, but remember there's multiple types (smites like :B:loodless can generate multiple cuts on a limb)
	for(var/datum/wound/iter_wound as anything in wounds)
		dam_mul *= iter_wound.damage_multiplier_penalty

	wound_damage_multiplier = dam_mul
	refresh_bleed_rate()

/**
 * apply_gauze() is used to- well, apply gauze to a bodypart
 *
 * As of the Wounds 2 PR, all bleeding is now bodypart based rather than the old bleedstacks system, and 90% of standard bleeding comes from flesh wounds (the exception is embedded weapons).
 * The same way bleeding is totaled up by bodyparts, gauze now applies to all wounds on the same part. Thus, having a slash wound, a pierce wound, and a broken bone wound would have the gauze
 * applying blood staunching to the first two wounds, while also acting as a sling for the third one. Once enough blood has been absorbed or all wounds with the ACCEPTS_GAUZE flag have been cleared,
 * the gauze falls off.
 *
 * Arguments:
 * * gauze- Just the gauze stack we're taking a sheet from to apply here
 */
/obj/item/bodypart/proc/apply_gauze(obj/item/stack/medical/gauze/new_gauze) // melbert todo : tape gauze may be broken
	if(!istype(new_gauze) || !new_gauze.absorption_capacity || !new_gauze.use(1))
		return
	if(!isnull(current_gauze))
		remove_gauze(drop_location())

	current_gauze = new new_gauze.type(src, 1)
	current_gauze.worn_icon_state = "[body_zone][rand(1, 3)]"
	if(can_bleed() && get_modified_bleed_rate())
		current_gauze.add_mob_blood(owner)
		if(!QDELETED(new_gauze))
			new_gauze.add_mob_blood(owner)
	SEND_SIGNAL(src, COMSIG_BODYPART_GAUZED, current_gauze, new_gauze)
	owner.update_damage_overlays()

/obj/item/bodypart/proc/remove_gauze(atom/remove_to)
	SEND_SIGNAL(src, COMSIG_BODYPART_UNGAUZED, current_gauze)
	if(remove_to)
		current_gauze.forceMove(remove_to)
	else
		current_gauze.moveToNullspace()
	if(can_bleed() && get_modified_bleed_rate())
		current_gauze.add_mob_blood(owner)
	current_gauze.worn_icon_state = initial(current_gauze.worn_icon_state)
	current_gauze.update_appearance()
	. = current_gauze
	current_gauze = null
	owner.update_damage_overlays()
	return .

/**
 * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
 *
 * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages falls off and we're left with nothing.
 *
 * Arguments:
 * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
 */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	current_gauze.update_appearance(UPDATE_NAME)
	if(current_gauze.absorption_capacity > 0)
		return
	owner.visible_message(
		span_danger("[current_gauze] on [owner]'s [name] falls away in rags."),
		span_warning("[current_gauze] on your [name] falls away in rags."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	remove_gauze(drop_location())
	owner.update_damage_overlays()

/**
 * Helper for someone helping to remove our gauze
 */
/obj/item/bodypart/proc/help_remove_gauze(mob/living/helper)
	if(!istype(helper))
		return
	if(helper.incapacitated())
		return
	if(!helper.can_perform_action(owner, NEED_HANDS|FORBID_TELEKINESIS_REACH)) // telekinetic removal can be added later
		return

	var/whose = helper == owner ? "your" : "[owner]'s"
	helper.visible_message(
		span_notice("[helper] starts carefully removing [current_gauze] from [whose] [plaintext_zone]."),
		span_notice("You start carefully removing [current_gauze] from [whose] [plaintext_zone]..."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)
	helper.balloon_alert(helper, "removing gauze...")
	if(helper != owner)
		helper.balloon_alert(owner, "removing your gauze...")

	if(!do_after(helper, 3 SECONDS, owner))
		return

	if(!current_gauze)
		return

	var/theirs = helper == owner ? helper.p_their() : "[owner]'s"
	helper.visible_message(
		span_notice("[helper] finishes removing [current_gauze] from [theirs] [plaintext_zone]."),
		span_notice("You finish removing [current_gauze] from [theirs] [plaintext_zone]."),
		vision_distance = COMBAT_MESSAGE_RANGE,
	)

	helper.balloon_alert(helper, "gauzed removed")
	if(helper != owner)
		helper.balloon_alert(owner, "gauze removed")

	helper.put_in_hands(remove_gauze())
