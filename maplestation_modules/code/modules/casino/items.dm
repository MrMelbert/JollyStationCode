/// IDs
/datum/id_trim/away/casino
	access = list(ACCESS_AWAY_GENERAL)

/datum/id_trim/away/casino/tier_2
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_GENERIC1)

/datum/id_trim/away/casino/security
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_GENERIC1, ACCESS_AWAY_SEC)

/obj/item/card/id/away/casino/tier1
	trim = /datum/id_trim/away/casino

/obj/item/card/id/away/casino/tier1/chef
	name = "Casino Chef ID"

/obj/item/card/id/away/casino/tier1/bar
	name = "Casino Barkeeper ID"

/obj/item/card/id/away/casino/tier1/waiter
	name = "Casino Wait-Staff ID"

/obj/item/card/id/away/casino/tier2
	trim = /datum/id_trim/away/casino/tier_2

/obj/item/card/id/away/casino/tier2/janitor
	name = "Casino Janitor ID"

/obj/item/card/id/away/casino/tier2/staff
	name = "Casino Operator ID"

/obj/item/card/id/away/casino/security
	name = "Casino Security ID"
	trim = /datum/id_trim/away/casino/security

/// Security Uniforms

/obj/item/clothing/under/suit/black/casino
	name = "security suit"
	desc = "A sleek black suit lined with kevlar to give it an edge against the drunks in the casino."
	armor_type = /datum/armor/clothing_under/rank_security
	strip_delay = 50
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/outfit/casino_security
	name = "Casino Security"

	id = /obj/item/card/id/away/casino/security
	id_trim = /obj/item/card/id/away/casino/security
	uniform = /obj/item/clothing/under/suit/black/casino
	belt = /obj/item/modular_computer/pda/security
	ears = /obj/item/radio/headset/headset_sec
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/restraints/handcuffs/cable/red
	r_pocket = /obj/item/assembly/flash/handheld

	back = /obj/item/storage/backpack/messenger

	box = /obj/item/storage/box/survival
	glasses = /obj/item/clothing/glasses/sunglasses



/obj/item/card/mining_point_card/casino
	name = "Casino Rewards Card"
	desc = "Redeem your cash for mining point prizes!"

/obj/item/card/mining_point_card/casino/Initialize(mapload)
	. = ..()
	points = rand(1000,3000)


/// Spawners

/obj/effect/spawner/random/casino_vault
	name = "Vault Loot Spawner"
	desc = "Spawns a completely random amount of loot for the casino vault"
	spawn_loot_count = 10
	loot = list(
		/obj/effect/spawner/random/entertainment/money_large = 4,
		/obj/effect/spawner/random/entertainment/money_medium = 5,
		/obj/effect/spawner/random/entertainment/money_small = 6,
		/obj/effect/spawner/random/entertainment/coin = 7,
		/obj/item/stack/sheet/mineral/gold = 3,
		/obj/item/stack/sheet/mineral/silver = 4,
		/obj/item/stack/sheet/mineral/diamond = 2,
		/obj/item/fish/goldfish = 2,
		/obj/item/reagent_containers/cup/glass/bottle/goldschlager = 3,
		/obj/item/bikehorn/golden = 3,
		/obj/item/wheelchair/gold = 2,
		/obj/item/card/id/advanced/gold/captains_spare = 1,
		/obj/item/food/grown/apple/gold = 2,
		/obj/item/instrument/violin/golden = 3,
		/obj/item/reagent_containers/cup/glass/flask/gold = 3,
		/obj/item/reagent_containers/cup/glass/trophy/gold_cup = 3,
		/obj/item/seeds/apple/gold = 2,
		/obj/item/slime_cookie/gold = 3,
		/obj/item/slime_extract/gold = 2,
		/obj/item/slime_cookie/silver = 4,
		/obj/item/slime_extract/silver = 3,
		/obj/item/clothing/accessory/medal/gold/heroism = 3,
		/obj/item/stack/ore/gold = 3,
		/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 3,
		/obj/item/stack/tile/mineral/gold = 2,
		/obj/item/melee/baseball_bat/golden = 1,
		/obj/item/clothing/accessory/medal/silver/valor = 4,
		/obj/item/pickaxe/silver = 3,
		/obj/item/reagent_containers/cup/bottle/silver = 4,
		/obj/item/reagent_containers/cup/glass/trophy/silver_cup = 4,
		/obj/item/stack/ore/silver = 4,
		/obj/item/reagent_containers/cup/glass/bottle/patron = 4,
		/obj/item/pickaxe/diamond = 3,
		/obj/item/pickaxe/drill/diamonddrill = 2,
		/obj/item/stack/ore/diamond = 2,
		/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 2,
		/obj/item/card/mining_point_card/casino = 4,
		/obj/item/stack/arcadeticket = 7,
		/obj/item/stack/arcadeticket/thirty = 3,
		/obj/item/storage/belt/champion = 3,
		/obj/item/coupon/bee = 2,
		/obj/item/storage/bag/money/vault = 4,
	)

/obj/effect/spawner/random/casino_vault/Initialize(mapload)
	spawn_loot_count = rand(7,15)
	return ..()
