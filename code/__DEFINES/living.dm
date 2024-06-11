// living_flags
/// Simple mob trait, indicating it may follow continuous move actions controlled by code instead of by user input.
#define MOVES_ON_ITS_OWN (1<<0)

// NON-MODULE CHANGE
// Sticking these here for now because i'm dumb

/// Updating a mob's movespeed when lacking limbs. (list/modifiers)
#define COMSIG_LIVING_LIMBLESS_MOVESPEED_UPDATE "living_get_movespeed_modifiers"

// -- Defines for the pain system. --

/// Sent when a carbon gains pain. (source = mob/living/carbon/human, obj/item/bodypart/affected_bodypart, amount, type)
#define COMSIG_CARBON_PAIN_GAINED "pain_gain"
/// Sent when a carbon loses pain. (source = mob/living/carbon/human, obj/item/bodypart/affected_bodypart, amount, type)
#define COMSIG_CARBON_PAIN_LOST "pain_loss"
/// Sent when a temperature pack runs out of juice. (source = obj/item/temperature_pack)
#define COMSIG_TEMPERATURE_PACK_EXPIRED "temp_pack_expired"

#define COMSIG_HUMAN_ON_HANDLE_BLOOD "human_on_handle_blood"
	#define HANDLE_BLOOD_HANDLED (1<<0)
	#define HANDLE_BLOOD_NO_NUTRITION_DRAIN (1<<1)
	#define HANDLE_BLOOD_NO_EFFECTS (1<<2)

/// Various lists of body zones affected by pain.
#define BODY_ZONES_ALL list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
#define BODY_ZONES_MINUS_HEAD list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
#define BODY_ZONES_LIMBS list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
#define BODY_ZONES_MINUS_CHEST list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/// List of some emotes that convey pain.
#define PAIN_EMOTES list("wince", "gasp", "grimace", "shiver", "sway", "twitch_s", "whimper", "inhale_s", "exhale_s", "groan")

/// Amount of pain gained (to chest) from dismembered limb
#define PAIN_LIMB_DISMEMBERED 90
/// Amount of pain gained (to chest) from surgically removed limb
#define PAIN_LIMB_REMOVED 30

/// Soft max pains for bodyparts, adds up to 500
#define PAIN_LIMB_MAX 70
#define PAIN_CHEST_MAX 120
#define PAIN_HEAD_MAX 100

// Keys for pain modifiers
#define PAIN_MOD_CHEMS "chems"
#define PAIN_MOD_LYING "lying"
#define PAIN_MOD_NEAR_DEATH "near-death"
#define PAIN_MOD_KOD "ko-d"
#define PAIN_MOD_RECENT_SHOCK "recently-shocked"
#define PAIN_MOD_QUIRK "quirk"
#define PAIN_MOD_SPECIES "species"
#define PAIN_MOD_OFF_STATION "off-station-pain-resistance"

// ID for traits and modifiers gained by pain
#define PAIN_LIMB_PARALYSIS "pain_paralysis"
#define MOVESPEED_ID_PAIN "pain_movespeed"
#define ACTIONSPEED_ID_PAIN "pain_actionspeed"

/// If the mob enters shock, they will have +1 cure condition (helps cure it faster)
#define TRAIT_ABATES_SHOCK "shock_abated"
/// Pain effects, such as stuttering or feedback messages ("Everything hurts") are disabled.
/// A way of saying "this mob doesn't feel pain" without actually
/// removing the pain system (giving them a big pain modifier)
#define TRAIT_NO_PAIN_EFFECTS "no_pain_effects"
/// Shock buildup does not increase, only decrease. Cannot enter shock if at the threshold.
/// No effect if already in shock (unlike abates_shock)
#define TRAIT_NO_SHOCK_BUILDUP "no_shock_buildup"
/// Blocks KO from high oxygen damage
#define TRAIT_NO_OXY_PASSOUT "no_oxy_passout"
/// All this trait does is change your stat to soft crit, which itself doesn't do much,
/// but as your stat is changed many stat checks will block you (such as using the radio)
#define TRAIT_SOFT_CRIT "soft_crit"
/// Blocks losebreath from accumulating from things such as heart attacks or choking
#define TRAIT_ASSISTED_BREATHING "assisted_breathing"

/// The trait that determines if someone has the robotic limb reattachment quirk.
#define TRAIT_ROBOTIC_LIMBATTACHMENT "trait_robotic_limbattachment"

#define COLOR_BLOOD "#c90000"
