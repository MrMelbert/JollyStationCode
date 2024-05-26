/// Magic

#define BASE_STORY_MAGIC_CAST_COST_MULT 1
#define NO_CATALYST_COST_MULT 4

// Assumes we are at average leyline intensity
#define LEYLINE_BASE_RECHARGE 0.1 // Per second, we recharge this much man

#define MANA_CRYSTAL_BASE_HARDCAP 200
#define MANA_CRYSTAL_BASE_RECHARGE 0.001

#define BASE_MANA_CAPACITY 1000
#define MANA_CRYSTAL_BASE_MANA_CAPACITY (BASE_MANA_CAPACITY * 0.2)
#define CARBON_BASE_MANA_CAPACITY (BASE_MANA_CAPACITY)
#define LEYLINE_BASE_CAPACITY 600 //todo: standardize

#define BASE_MANA_SOFTCAP (BASE_MANA_CAPACITY * 0.2) //20 percent
#define BASE_MANA_CRYSTAL_SOFTCAP  MANA_CRYSTAL_BASE_MANA_CAPACITY
#define BASE_CARBON_MANA_SOFTCAP (CARBON_BASE_MANA_CAPACITY * 0.2)

#define BASE_MANA_OVERLOAD_THRESHOLD BASE_MANA_CAPACITY * 0.9
#define MANA_CRYSTAL_OVERLOAD_THRESHOLD MANA_CRYSTAL_BASE_MANA_CAPACITY
#define CARBON_MANA_OVERLOAD_THRESHOLD BASE_CARBON_MANA_SOFTCAP

#define BASE_MANA_OVERLOAD_COEFFICIENT 1
#define MANA_CRYSTAL_OVERLOAD_COEFFICIENT 0.1
#define CARBON_MANA_OVERLOAD_COEFFICIENT 2

#define ROBOTIC_MANA_OVERLOAD_COEFFICIENT_MULT 3
#define ROBOTIC_MANA_SOFTCAP_MULT 0.5
#define ROBOTIC_MANA_OVERLOAD_THRESHOLD_MULT ROBOTIC_MANA_SOFTCAP_MULT

#define MANA_OVERLOAD_DAMAGE_THRESHOLD 2
#define MANA_OVERLOAD_BASE_DAMAGE 1

// inverse - higher numbers decrease the intensity of the decay
#define BASE_MANA_EXPONENTIAL_DIVISOR 60 // careful with this value - low numbers will cause some fuckery
#define BASE_CARBON_MANA_EXPONENTIAL_DIVISOR (BASE_MANA_EXPONENTIAL_DIVISOR * 0.5)
#define MANA_CRYSTAL_BASE_DECAY_DIVISOR (BASE_MANA_EXPONENTIAL_DIVISOR * 5)

// in vols per second
#define BASE_MANA_DONATION_RATE (BASE_MANA_CAPACITY * 0.5)
#define BASE_MANA_CRYSTAL_DONATION_RATE (BASE_MANA_DONATION_RATE * 0.1)
#define BASE_LEYLINE_DONATION_RATE 30

#define MANA_BATTERY_MAX_TRANSFER_DISTANCE 1

#define MAGIC_MATERIAL_NAME "Volite"
#define MAGIC_UNIT_OF_MEASUREMENT "Vol"
#define MAGIC_UNIT_OF_MAGNITUDE "TP" // Thaumatergic Potential
#define STORY_MAGIC_BASE_CONSUME_SCORE 50

#define CONVECT_MANA_COST_PER_KELVIN 0.25

#define THAUMATERGIC_SENSE_POOL_DISCERNMENT_LEVEL_ZERO 0
#define THAUMATERGIC_SENSE_POOL_DISCERNMENT_LEVEL_ONE 1
#define THAUMATERGIC_SENSE_POOL_DISCERNMENT_LEVEL_TWO 2

#define SPECIES_BASE_MANA_CAPACITY_MULT 1
