// this is the containment area for magic related chems, or changes to chems to add interactivity
/datum/reagent/consumable/ethanol/wizz_fizz/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	//Its a magic drink. it regens mana, if mildly
	if(drinker?.mana_pool)
		drinker.safe_adjust_personal_mana(1.5)

/datum/reagent/consumable/ethanol/pod_tesla/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	//electrical drink, very mild regen, will do better if electrically attuened (when implemented)
	if(drinker?.mana_pool)
		drinker.safe_adjust_personal_mana(1)
/* TODOS:
* Telepole & Pod Tesla regen mana if electrically attuned/or it has an electric attunement (me when the charge build)
* Sea Breeze (lizard drink) & Tropical Storm (mothic drink) mildly regens mana if water attuned
*/
/datum/reagent/medicine/quintessence
	name = "Quintessence"
	description = "Quintessence is mana that has been fixed into a digestible, chemical form."
	taste_description = "a unique feeling of raw power"
	ph = 5
	color = "#a1fcdc"
	var/mana_adjust = 1.5

/datum/reagent/medicine/quintessence/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	//magic chem. regens mana, shouldn't be obtained by reaction, instead from sources like botany.
	if(drinker?.mana_pool)
		drinker.safe_adjust_personal_mana(mana_adjust)

/datum/reagent/medicine/quintessence/crystalized
	name = "Crystallized Quintessence"
	description = "A rarer form of Quintessence, fixed into a liquid crystal form. Increased effects."
	taste_description = "a spark of life"
	ph = 4
	color = "#9effdd"
	mana_adjust = 3

/datum/reagent/medicine/quintessence/misty
	name = "Misty Quintessence"
	description = "A more common, improperly fixed, version of Quintessence. Reduced effects."
	taste_description = "potential yet unrealized"
	ph = 6
	color = "#b3ead7"
	mana_adjust = 0.5

/datum/reagent/toxin/agnosticine
	name = "Agnosticine"
	description = "Agnosticine is Quintessence's natural opposite. It saps mana from those who consume it."
	taste_description = "dreams deferred"
	ph = 9
	toxpwr = 0
	color = "#5e0323" // the inverse of quintessence
	var/mana_adjust = -1.5

/datum/reagent/toxin/agnosticine/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	// also a magic chem. drains mana, shouldn't be obtained by reaction, instead from sources like botany.
	if(drinker?.mana_pool)
		drinker.safe_adjust_personal_mana(mana_adjust)

/datum/reagent/toxin/agnosticine/fading
	name = "Fading Agnosticine"
	description = "Agnosticine congealed to a point it gains a near translucent appearence. Increased effects."
	taste_description = "a hollow feeling in your heart"
	ph = 10
	color = "#610022"
	mana_adjust = -3

/datum/reagent/toxin/agnosticine/foggy
	name = "Foggy Agnosticine"
	description = "An impure, unrealized version of Agnosticine. Reduced effects."
	taste_description = "fading wishes"
	ph = 8
	color = "#4c1528"
	mana_adjust = -0.5

/datum/reagent/volite_powder
	name = "Volite Powder"
	description = "Pure Volite crystals which has been grinded up into a powder."
	taste_description = "lots of little sparks"
	ph = 8
	color = "#22dcb5"
	var/mana_adjust = 1
