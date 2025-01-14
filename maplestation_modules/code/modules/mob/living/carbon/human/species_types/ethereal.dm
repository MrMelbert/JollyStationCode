// -- Ethereal species additions --
/datum/species/ethereal

/datum/species/ethereal/get_species_speech_sounds(sound_type)
	switch(sound_type)
		if(SOUND_QUESTION)
			return string_assoc_list(list(
				'goon/sound/voice/speak_1_ask.ogg' = 120,
				'goon/sound/voice/speak_2_ask.ogg' = 120,
				'goon/sound/voice/speak_3_ask.ogg' = 120,
				'goon/sound/voice/speak_4_ask.ogg' = 120,
			))
		if(SOUND_EXCLAMATION)
			return string_assoc_list(list(
				'goon/sound/voice/speak_1_exclaim.ogg' = 120,
				'goon/sound/voice/speak_2_exclaim.ogg' = 120,
				'goon/sound/voice/speak_3_exclaim.ogg' = 120,
				'goon/sound/voice/speak_4_exclaim.ogg' = 120,
			))
		else
			return string_assoc_list(list(
				'goon/sound/voice/speak_1.ogg' = 120,
				'goon/sound/voice/speak_2.ogg' = 120,
				'goon/sound/voice/speak_3.ogg' = 120,
				'goon/sound/voice/speak_4.ogg' = 120,
			))
