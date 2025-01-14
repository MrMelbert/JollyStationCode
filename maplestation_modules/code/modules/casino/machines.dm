/// Sprite update, also moved the random names & descriptions from the green slots to normal slots. Now all slot machines on NT stations are gifts from U.M.E.F.!
/obj/machinery/computer/slot_machine
	icon = 'maplestation_modules/icons/obj/machines/computer.dmi'
	/// Possible names that this machine can have.
	var/static/list/possible_names = list(
		"AGENT GREEN'S MEAN MACHINE",
		"BOSS BUX",
		"PAYCHECK QUEST",
		"RICKOLO'S RICHES",
		"GLAN'S GOLD",
		"RITZ'S RACKS",
		"AGENT RUSH",
		"AGENT BIG WIN",
		"THE BOSS ZHU ZHAO FU",
		"DR. MONSTER'S MONSTER WINS",
		"SUPER BUFFALO",
		"BOSS KINGS",
		"AGENT BUFFALO",
	)
	/// Added descriptor of what the machine looks like.
	var/this_slot_type = "It's a standard slot machine housing some mechanical reels with symbols on each one."

/obj/machinery/computer/slot_machine/Initialize(mapload)
	. = ..()
	name = pick(possible_names)
	var/static/list/slot_type_descriptions
	if(!length(slot_type_descriptions))
		slot_type_descriptions = world.file2list("maplestation_modules/strings/slots.txt")
	if(length(slot_type_descriptions))
		this_slot_type = pick(slot_type_descriptions)

/obj/machinery/computer/slot_machine/examine(mob/user)
	. = ..()
	. += this_slot_type
	. += span_notice("All proceeds go to continued U.M.E.F. research into advanced gambling techniques!")

// 1 free spin per machine, and a random amount of max money from 500 to 1 million credits.
/obj/machinery/computer/slot_machine/green
	name = "AGENT GREEN'S MEAN MACHINE"
	desc = "A sign on the side says \"ALL MACHINES START WITH 1 FREE SPIN!\""
	balance = 5


/obj/machinery/computer/slot_machine/green/Initialize(mapload)
	. = ..()
	money = rand(500,1000000)

/// Always jackpots* and has 1 mil
/// *This part doesn't seem to work so it really only always has 1 mil, which is still a little funny.
/obj/machinery/computer/slot_machine/boss
	name = "THE BOSS' PRIVATE SLOTS"
	desc = "Now THOSE are odds I like to see!"
	money = 1000000

/obj/machinery/roulette/green
	name = "AGENT GREEN'S BIG SPIN"
	anchored = TRUE
	// Names need to be set when you swipe the ID anyway, so these are more just suggestions.
	// We didn't realize that when we made it lol.
	var/list/possible_names = list(
		"AGENT GREEN'S BIG SPIN",
		"AGENT SPIN'S ADVENTURE",
	)

/obj/machinery/roulette/green/Initialize(mapload)
	. = ..()
	name = pick(possible_names)

/obj/machinery/biogenerator/infinite
	biomass = INFINITY
	max_output = 300
