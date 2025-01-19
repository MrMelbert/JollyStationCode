/**
 * The flying machinegun drone planning:
 * - If too close to target, back up to keep distance.
 * - If too far from target, close the distance.
 * - BANG BANG BANG.
 * - Find non DEEP RED faction target.
 */
/datum/ai_controller/basic_controller/rapidlightflying
	blackboard = list(
			BB_BASIC_MOB_CURRENT_TARGET,
			BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION,
			BB_TARGET_MINIMUM_STAT = HARD_CRIT,
			BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)
	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
			/datum/ai_planning_subtree/target_retaliate/check_faction,
			/datum/ai_planning_subtree/simple_find_target,
			/datum/ai_planning_subtree/maintain_distance/rapidlightflying,
			/datum/ai_planning_subtree/attack_obstacle_in_path,
			/datum/ai_planning_subtree/ranged_skirmish/rapidlightflying,
	)

/datum/ai_planning_subtree/maintain_distance/rapidlightflying
	minimum_distance = 3
	maximum_distance = 8

/datum/ai_planning_subtree/ranged_skirmish/rapidlightflying
	min_range = 0
