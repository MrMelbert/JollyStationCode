/obj/item/organ/internal/eyes
	/// Overlay file to take eye icons from
	var/eye_overlay_file = 'icons/mob/human/human_face.dmi'

/mob/living/carbon
	/// Overlay file to take (missing) eye icons from
	var/missing_eye_file = 'icons/mob/human/human_face.dmi'

/obj/item/organ/internal/eyes/werewolf
	name = "wolf eyes"
	desc = "Large and powerful eyes."
	sight_flags = SEE_MOBS
	color_cutoffs = list(25, 5, 42)
