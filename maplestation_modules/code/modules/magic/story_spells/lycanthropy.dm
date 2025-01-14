// the many spells that are used to turn into versions of a werewolf

/datum/action/cooldown/spell/shapeshift/lycanthrope // use this for the simplemob forms, like standard wolves
	name = "Wolf Form"
	desc = "Channel the wolf within yourself and turn into one of your possible forms. \
		Be careful, for you can still die within this form."
	invocation = "RAAAAAAAAWR!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	possible_shapes = list(
		/mob/living/simple_animal/hostile/asteroid/wolf, // room to add other forms
	)

/datum/action/cooldown/spell/werewolf_form
	name = "Werewolf Change"
	desc = "Change to and from your full werewolf form. \
	You will gain the full effects of this, both negative and positive."
	invocation = "ARRRROOOOO!" // i don't know man
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_HUMAN
	button_icon = 'maplestation_modules/icons/mob/actions/actions_advspells.dmi'
	button_icon_state = "moon"
	var/datum/species/owner_base_species // what species we are other than a werewolf
	var/list/base_features = list("mcolor" = "#FFFFFF")
	// yes this might cause other implications, such as mass species change, or with synths (synthcode moment) but i'll look into it later down the line

/datum/action/cooldown/spell/werewolf_form/cast(atom/movable/cast_on)
	. = ..()
	var/mob/living/carbon/human/lycanthrope = owner
	if(istype(lycanthrope.dna.species, /datum/species/werewolf))
		lycanthrope.balloon_alert(cast_on, "changing back")
		lycanthrope.dna.features = base_features
		lycanthrope.set_species(owner_base_species)
	else
		owner_base_species = lycanthrope.dna.species
		base_features = lycanthrope.dna.features.Copy()
		lycanthrope.balloon_alert(cast_on, "turning")
		lycanthrope.set_species(/datum/species/werewolf)
