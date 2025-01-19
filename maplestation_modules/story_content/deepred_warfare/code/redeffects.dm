/obj/effect/temp_visual/red_lightning_trail
	name = "red lightning trail"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redeffects.dmi'
	icon_state = "trail"
	duration = 15

	light_on = TRUE
	light_range = 2
	light_power = 2
	light_color = COLOR_RED
	light_system = STATIC_LIGHT

/obj/effect/temp_visual/faraday
	name = "faraday block"
	icon = 'maplestation_modules/story_content/deepred_warfare/icons/redeffects64.dmi'
	icon_state = "block"
	layer = LARGE_MOB_LAYER
	anchored = TRUE
	duration = 2
	pixel_x = -16
	pixel_y = -16

/obj/effect/temp_visual/faraday/energy
	name = "faraday absorb"
	icon_state = "absorb"

/obj/effect/temp_visual/faraday/emp
	name = "faraday emp"
	icon_state = "emp"

/obj/effect/temp_visual/faraday/shatter
	name = "faraday shatter"
	icon_state = "shatter"
