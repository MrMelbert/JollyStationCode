/// -- Module defines for all maplestation_modules files. --

/// How much flavor text gets displayed before cutting off.
#define EXAMINE_FLAVOR_MAX_DISPLAYED 65

/// Language flag for languages added via quirk
#define LANGUAGE_QUIRK "quirk"
#define LANGUAGE_PREF "pref"

/// Some string files.
#define COMPANY_FILE "companies.json"
#define RESOURCE_EVENT_FILE "resource_events.json"

#define INFO_GREYSCALE "greyscale"
#define INFO_NAMED "name"
#define INFO_RESKIN "reskin"
#define INFO_LAYER "layer"

/// Max amonut of misc / backpack items that are allowed.
#define MAX_ALLOWED_MISC_ITEMS 3

/// Used to make something not recolorable even if it's capable
#define DONT_GREYSCALE -1

/// Defines for extra info blurbs, for loadout items.
#define TOOLTIP_NO_ARMOR "This item has no armor and is entirely cosmetic."
#define TOOLTIP_NO_DAMAGE "This item has very low force and is largely cosmetic."
#define TOOLTIP_RANDOM_COLOR "This item has a random color and will change every round."

// Modular traits
/// Provides additional resistance to contracting diseases. Should be removed next upstream
#define TRAIT_DISEASE_RESISTANT "disease_resistant"
/// Does not harm patients when undergoing CPR
#define TRAIT_CPR_CERTIFIED "cpr_certified"

/// Bitflags for speech sounds
#define SOUND_NORMAL (1<<0)
#define SOUND_QUESTION (1<<1)
#define SOUND_EXCLAMATION (1<<2)
