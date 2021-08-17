// -- The loadout item datum and related procs. --

/// Global list of ALL loadout datums instantiated.
GLOBAL_LIST_EMPTY(all_loadout_datums)

/*
 * Generate a list of singleton loadout_item datums from all subtypes of [type_to_generate]
 *
 * returns a list of singleton datums.
 */
/proc/generate_loadout_items(type_to_generate)
	RETURN_TYPE(/list)

	. = list()
	if(!ispath(type_to_generate))
		CRASH("generate_loadout_items(): called with an invalid or null path as an argument!")

	for(var/datum/loadout_item/found_type as anything in subtypesof(type_to_generate))
		/// Any item without a name is "abstract"
		if(isnull(initial(found_type.name)))
			continue

		if(!ispath(initial(found_type.item_path)))
			stack_trace("generate_loadout_items(): Attempted to instantiate a loadout item ([initial(found_type.name)]) with an invalid or null typepath! (got path: [initial(found_type.item_path)])")
			continue

		var/datum/loadout_item/spawned_type = new found_type()
		GLOB.all_loadout_datums[spawned_type.item_path] = spawned_type
		. |= spawned_type

/// Loadout item datum.
/// Holds all the information about each loadout items.
/// A list of singleton loadout items are generated on initialize.
/datum/loadout_item
	/// Displayed name of the loadout item.
	var/name
	/// Whether this item has greyscale support.
	var/can_be_greyscale = FALSE
	/// Whether this item can be renamed.
	var/can_be_named = FALSE
	/// The category of the loadout item.
	var/category
	/// The actual item path of the loadout item.
	var/item_path
	/// List of additional text for the tooltip displayed on this item.
	var/list/additional_tooltip_contents

/datum/loadout_item/New()
	if(can_be_named)
		if(LAZYLEN(additional_tooltip_contents))
			additional_tooltip_contents.Insert(1, TOOLTIP_RENAMABLE)
		else
			LAZYADD(additional_tooltip_contents, TOOLTIP_RENAMABLE)

	if(can_be_greyscale)
		if(LAZYLEN(additional_tooltip_contents))
			additional_tooltip_contents.Insert(1, TOOLTIP_GREYSCALE)
		else
			LAZYADD(additional_tooltip_contents, TOOLTIP_GREYSCALE)

/*
 * Place our [var/item_path] into [outfit].
 *
 * By default, just adds the item into the outfit's backpack contents, if non-visual.
 *
 * equipper - If we're equipping out outfit onto a mob at the time, this is the mob it is equipped on. Can be null.
 * outfit - The outfit we're equipping our items into.
 * visual - If TRUE, then our outfit is only for visual use (for example, a preview).
 */
/datum/loadout_item/proc/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only)
	if(!visuals_only)
		LAZYADD(outfit.backpack_contents, item_path)

/*
 * Called after the item is equipped on [equipper].
 */
/datum/loadout_item/proc/post_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper, visuals_only)
	// MELBERT TODO: This doesn't work on the preview, but it does work in game?
	if(!preference_source)
		return

	var/list/our_loadout = preference_source?.loadout_list
	if(can_be_greyscale && (INFO_GREYSCALE in our_loadout[item_path]))
		if(ispath(item_path, /obj/item/clothing))
			// When an outfit is equipped in preview, get_equipped_items() does not work, so we have to use GetAllContents()
			var/obj/item/clothing/equipped_item = locate(item_path) in (visuals_only ? equipper.GetAllContents() : equipper.get_equipped_items())
			equipped_item?.set_greyscale(our_loadout[item_path][INFO_GREYSCALE])
		else if(!visuals_only)
			var/obj/item/other_item = locate(item_path) in equipper.GetAllContents()
			other_item?.set_greyscale(our_loadout[item_path][INFO_GREYSCALE])

	if(can_be_named && !visuals_only && (INFO_NAMED in our_loadout[item_path]))
		var/obj/item/equipped_item = locate(item_path) in equipper.GetAllContents()
		equipped_item.name = our_loadout[item_path][INFO_NAMED]
