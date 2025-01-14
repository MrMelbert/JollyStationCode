/obj/item/organ/internal/heart/werewolf
	name = "massive heart"
	desc = "An absolutely monstrous heart."
	icon_state = "heart-on"
	base_icon_state = "heart"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD

/obj/item/organ/internal/heart/wolf/Initialize(mapload)
	. = ..()
	transform = transform.Scale(1.5)
