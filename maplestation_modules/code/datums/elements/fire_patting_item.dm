/// You can slap someone with this item to put out fires on them.
/datum/element/pat_out_fire

/datum/element/pat_out_fire/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY, PROC_REF(do_the_pat))

/datum/element/pat_out_fire/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY)

/datum/element/pat_out_fire/proc/do_the_pat(obj/item/source, mob/living/carbon/human/user, mob/living/target)
	SIGNAL_HANDLER

	if(!isliving(target) || !ishuman(user) || user == target || !target.on_fire)
		return NONE

	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living/carbon/human, do_pat_fire), target, source)
	return ITEM_INTERACT_SUCCESS
