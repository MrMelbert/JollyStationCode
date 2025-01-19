/obj/structure/redtech_indestructable
	name = "redtech setpiece"
	desc = "Report this to a coder."
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/setpieces.dmi'
	icon_state = "server_off" // Temp sprite KEKW.
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/redtech_indestructable/server_off
	name = "redtech server"
	desc = "A large quantum computing server machine, which seems to be deactivated at the moment. Its construction looks nigh-indestructable."
	icon_state = "server_off"

/obj/structure/redtech_indestructable/server_off/alias
	name = "crimson server"

/obj/structure/redtech_indestructable/heatsink_off
	name = "redtech heatsink"
	desc = "Ab excessively large heatsink, which thankfully seems to be deactivated at the moment. Its construction looks nigh-indestructable."
	icon_state = "heatsink_off"

/obj/structure/redtech_indestructable/heatsink_off/alias
	name = "crimson heatsink"

/obj/structure/redtech_indestructable/inert_AV
	name = "inert Anti Void"
	desc = "Something has gone terribly wrong."
	icon_state = "inert_AV"

/obj/structure/redtech_indestructable/inert_AV/worse
	icon_state = "inert_AV_worse"
