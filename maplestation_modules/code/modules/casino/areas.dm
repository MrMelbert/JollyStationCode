#define CASINO_MAZE "casino_maze"

/area/awaymission/casino
	name = "Casino"
	icon_state = "away"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = "#FFFFCC"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY

/area/awaymission/casino/staffhall
	name = "Staff Hallway"
	base_lighting_alpha = 220
	icon_state = "awaycontent1"

/area/awaymission/casino/vault
	name = "Agent Green's Riches"
	icon_state = "awaycontent2"

/area/awaymission/casino/floor
	name = "Casino Floor"
	icon_state = "awaycontent3"
	ambientsounds = list(
		'maplestation_modules/sound/ambience/casino/CasinoAmbience1.ogg',
		'maplestation_modules/sound/ambience/casino/CasinoAmbience2.ogg'
	)

/// Lowered volume, not actually sure if this works?
/area/awaymission/casino/floor/play_ambience(M, override_sound, volume = 10)
	return ..()

/area/awaymission/casino/utility
	name = "Utility Closet"
	icon_state = "awaycontent4"
	base_lighting_alpha = 120

/area/awaymission/casino/security
	name = "Security Podium"
	icon_state = "awaycontent5"

/area/awaymission/casino/security/armory
	name = "Armory"
	icon_state = "awaycontent17"

/area/awaymission/casino/kitchen
	name = "Kitchen"
	icon_state = "awaycontent6"
	base_lighting_alpha = 220

/area/awaymission/casino/kitchen/coldroom
	name = "Kitchen Coldroom"
	icon_state = "awaycontent7"
	base_lighting_alpha = 220

/area/awaymission/casino/restaurant
	name = "Restaurant"
	icon_state = "awaycontent8"

/area/awaymission/casino/bar
	name = "Bar"
	icon_state = "awaycontent9"

/area/awaymission/casino/bar/backroom
	name = "Bar Backroom"
	icon_state = "awaycontent10"
	base_lighting_alpha = 220

/area/awaymission/casino/arcade
	name = "Arcade"
	icon_state = "awaycontent11"

/area/awaymission/casino/janitor
	name = "Custodial Closet"
	icon_state = "awaycontent12"
	base_lighting_alpha = 220

/area/awaymission/casino/mantrap
	name = "Man-Trap"
	icon_state = "awaycontent13"
	base_lighting_alpha = 220

/area/awaymission/casino/cage
	name = "Payout Cage"
	icon_state = "awaycontent14"

/area/awaymission/casino/friendmaker
	name = "Jackpot Room"
	icon_state = "awaycontent15"
	base_lighting_alpha = 5

/area/awaymission/casino/parking
	name = "Parking Lot"
	icon_state = "awaycontent16"

/area/awaymission/casino/checkin
	name = "Check-in"
	icon_state = "awaycontent18"

/area/awaymission/casino/floor/tables
	name = "Casino Tables"
	icon_state = "awaycontent19"

/area/awaymission/casino/floor/tables/Initialize(mapload)
	ambientsounds |= list(
		'sound/items/cardshuffle.ogg',
		'sound/items/cardflip.ogg'
		)
	. = ..()

/area/awaymission/casino/floor/maze
	name = "The Labyrinth"
	icon_state = "awaycontent20"
	// Otherworldly maze noise
	ambientsounds = list(
		'maplestation_modules/sound/ambience/casino/MazeHallucinations.ogg',
		'maplestation_modules/sound/ambience/casino/MazeHallucinations2.ogg',
		'maplestation_modules/sound/ambience/casino/MazeBuffalo.ogg',
		'maplestation_modules/sound/ambience/casino/MazeBuffalo2.ogg',
	)
	area_flags = UNIQUE_AREA|NOTELEPORT|HIDDEN_AREA
	base_lighting_color = "#ffcccc"

// Louder volume
/area/awaymission/casino/floor/maze/play_ambience(M, override_sound, volume = 30)
	return ..()

/area/awaymission/casino/floor/maze/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	for(var/mob/living/enterer as anything in arrived.get_all_contents_type(/mob/living))
		to_chat(enterer, span_userdanger("This was a bad idea..."))
		enterer.become_blind(CASINO_MAZE)
		// It's a timed effect but we're going to remove it when they leave, so we make it really long.
		enterer.adjust_jitter(60 MINUTES)
		enterer.adjust_hallucinations(60 MINUTES)
		// Want to make them not able to get help through the maze but don't want them to become deaf
		curse_of_babel(enterer)

/area/awaymission/casino/floor/maze/Exited(atom/movable/gone, direction)
	. = ..()
	for(var/mob/living/exiter as anything in gone.get_all_contents_type(/mob/living))
		to_chat(exiter, span_boldnicegreen("I feel so much better!"))
		exiter.cure_blind(CASINO_MAZE)
		exiter.adjust_jitter(-60 MINUTES)
		exiter.adjust_hallucinations(-60 MINUTES)
		cure_curse_of_babel(exiter)


/area/awaymission/casino/bathroom
	name = "Restroom"
	icon_state = "awaycontent21"
	ambientsounds = list(
		'maplestation_modules/sound/ambience/casino/RestroomAmbience.ogg'
	)

/area/awaymission/casino/clinic
	name = "Medical Clinic"
	icon_state = "awaycontent22"

#undef CASINO_MAZE
