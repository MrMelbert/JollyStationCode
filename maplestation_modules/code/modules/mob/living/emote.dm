// -- Module emotes. --
/datum/emote/living/wince
	key = "wince"
	key_third_person = "winces"
	message = "winces."
	stat_allowed = SOFT_CRIT

/datum/emote/living/inhale_s
	key = "inhale_s"
	message = "inhales sharply."
	stat_allowed = SOFT_CRIT

/datum/emote/living/exhale_s
	key = "exhale_s"
	message = "exhales sharply."
	stat_allowed = SOFT_CRIT

/datum/emote/living/blush/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	playsound(user, 'maplestation_modules/sound/emote/blush.ogg', 80)

/datum/emote/living/weeze
	key = "weeze"
	key_third_person = "weezes"
	message = "weezes."
	stat_allowed = SOFT_CRIT

/datum/emote/living/flinch
	key = "flinch"
	key_third_person = "flinches"
	message = "flinches."
