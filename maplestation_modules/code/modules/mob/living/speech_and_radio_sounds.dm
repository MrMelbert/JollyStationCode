/// -- mob/living vars and overrides. --

/// Default, middle frequency
#define DEFAULT_FREQUENCY 44100

/mob/living
	/// Modifier to speech sounds frequency
	/// Lower = longer, deeper speech sounds
	/// Higher = quicker, higher-pitch speech sounds
	var/speech_sound_frequency_modifier = 1

/mob/living/silicon
	speech_sound_frequency_modifier = -1 // is set from preferences when we first speak.

/**
 * Gets the sound this mob plays when they speak
 *
 * Returns null or a statically cached list (via string_assoc_list)
 */
/mob/living/proc/get_speech_sounds(sound_type)
	// These sounds have been ported from Goonstation.
	return string_assoc_list(list(
		'goon/sound/voice/speak_1.ogg' = 120,
		'goon/sound/voice/speak_2.ogg' = 120,
		'goon/sound/voice/speak_3.ogg' = 120,
		'goon/sound/voice/speak_4.ogg' = 120,
	))

/mob/living/basic/get_speech_sounds(sound_type)
	return

/mob/living/simple_animal/get_speech_sounds(sound_type)
	return

/mob/living/simple_animal/bot/get_speech_sounds(sound_type)
	return string_assoc_list(list('goon/sound/voice/radio_ai.ogg' = 100))

/mob/living/silicon/get_speech_sounds(sound_type)
	return string_assoc_list(list('goon/sound/voice/radio_ai.ogg' = 100))

/mob/living/carbon/get_speech_sounds(sound_type)
	return dna?.species?.get_species_speech_sounds(sound_type)

/**
 * Gets the sound this mob plays when they transmit over radio (to other people on the radio)
 *
 * Returns null or a statically cached list (via string_assoc_list)
 */
/mob/living/proc/get_radio_sounds()
	return string_assoc_list(list(
		'goon/sound/voice/radio.ogg' = 75,
		'goon/sound/voice/radio_2.ogg' = 75,
	))

/mob/living/simple_animal/bot/get_radio_sounds()
	return string_assoc_list(list('goon/sound/voice/radio_ai.ogg' = 100))

/mob/living/silicon/get_radio_sounds()
	return string_assoc_list(list('goon/sound/voice/radio_ai.ogg' = 100))

/// Extend say so we can have talking make sounds.
/mob/living/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	. = ..()
	// If say failed for some reason we should probably fail
	if(!.)
		return
	// Eh, probably don't play a sound if it's forced (like spells)
	if(forced)
		return
	// No sounds for sign language folk
	if(HAS_TRAIT(src, TRAIT_SIGN_LANG))
		return

	// Whether this is a question, an exclamation, or neither
	var/sound_type
	// What frequency we pass to playsound for variance.
	var/sound_frequency = DEFAULT_FREQUENCY
	// Determine if this is a question, an exclamation, or neither and update sound_type and sound_frequency accordingly.
	switch(copytext_char(message, -1))
		if("?")
			sound_type = SOUND_QUESTION
			sound_frequency = rand(DEFAULT_FREQUENCY, 55000) //questions are raised in the end
		if("!")
			sound_type = SOUND_EXCLAMATION
			sound_frequency = rand(32000, DEFAULT_FREQUENCY) //exclamations are lowered in the end
		else
			sound_type = SOUND_NORMAL
			sound_frequency = round((get_rand_frequency() + get_rand_frequency()) / 2) //normal speaking is just the average of 2 random frequencies (to trend to the middle)

	// [speech_sound_frequency_modifier] is set directly for humans via pref [apply_to_humans], but for other mobs we need to double-check
	if(speech_sound_frequency_modifier == -1)
		speech_sound_frequency_modifier = client?.prefs?.read_preference(/datum/preference/numeric/frequency_modifier) || 1

	sound_frequency *= speech_sound_frequency_modifier

	var/list/sound_pool = get_speech_sounds(sound_type)
	if(!LAZYLEN(sound_pool))
		return
	var/list/message_mods = list()
	message = get_message_mods(message, message_mods)

	// Pick a sound from our found sounds and play it.
	var/picked_sound = pick(sound_pool)
	var/speech_sound_vol = sound_pool[picked_sound]
	var/speech_sound_rangemod = -10 // 7 range
	if(message_mods[WHISPER_MODE])
		speech_sound_vol = max(speech_sound_vol - 10, 10)
		speech_sound_rangemod = -14 // 3 range

	playsound(
		source = src,
		soundin = picked_sound,
		vol = speech_sound_vol,
		vary = TRUE,
		extrarange = speech_sound_rangemod,
		frequency = sound_frequency,
		pressure_affected = TRUE,
		ignore_walls = FALSE,
		pref_to_use = /datum/preference/toggle/toggle_speech,
	)

	if(message_mods[MODE_HEADSET] || message_mods[RADIO_EXTENSION])
		var/list/radio_sound_pool = get_radio_sounds()
		if(LAZYLEN(radio_sound_pool))
			var/picked_radio_sound = pick(radio_sound_pool)
			playsound(
				source = src,
				soundin = picked_radio_sound,
				vol = max(radio_sound_pool[picked_radio_sound] - 10, 10),
				vary = TRUE,
				extrarange = -13, // 4 range
				pressure_affected = TRUE,
				ignore_walls = FALSE,
				pref_to_use = /datum/preference/toggle/toggle_radio,
			)

/// Extend hear so we can have radio messages make radio sounds.
/mob/living/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range=0)
	. = ..()
	if(!.)
		return

	// No message = no sound.
	if(!message)
		return

	// Don't bother playing sounds to clientless mobs to save time
	if(!client?.prefs.read_preference(/datum/preference/toggle/toggle_radio))
		return

	// We only deal with radio messages from this point
	if(!message_mods[MODE_HEADSET] && !message_mods[RADIO_EXTENSION])
		return

	// Speaker typecasted into a virtual speaker (Radios use virtualspeakers)
	var/atom/movable/virtualspeaker/vspeaker = speaker
	// Speaker typecasted into a /mob/living
	var/mob/living/living_speaker
	// Speaker is either a virtual speaker or a mob - whatever it is it needs to be a mob in the end.
	if(istype(vspeaker))
		living_speaker = vspeaker.source
		if(!istype(living_speaker))
			return
	else if(isliving(speaker))
		living_speaker = speaker
	else
		return

	var/list/radio_sound_pool = living_speaker.get_radio_sounds()
	if(!LAZYLEN(radio_sound_pool))
		return

	// Pick a sound from our found sounds and play it.
	var/picked_sound = pick(radio_sound_pool)
	var/radio_sound_vol = radio_sound_pool[picked_sound]
	if(living_speaker != src)
		radio_sound_vol = max(radio_sound_vol - 15, 10) // other people's radio's are slightly quieter, so you can differentiate

	// It would be pretty cool to make this come from nearby intercoms, if that's how you're hearing the radio -
	// But that's for a later time. At least when I undertand vspeakers more
	playsound_local(
		turf_source = get_turf(src),
		soundin = picked_sound,
		vol = radio_sound_vol,
		vary = TRUE,
		pressure_affected = TRUE,
	)

#undef DEFAULT_FREQUENCY
