
if not DOTA_EXTRA_ENUMS then
	DOTA_EXTRA_ENUMS = class({})
end
DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE = 0
DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NO = 1
DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_YES = 2
DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_STRONG = 4

DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE	= 0	
DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ALLIES_YES = 1	
DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ALLIES_NO = 2	
DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ENEMIES_YES = 4	
DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ENEMIES_NO = 8

DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_SELF_TARGET = 0
DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_SINGLE_TARGET = 1
DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_POINT = 2
DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_LINEAR_PROJECTILE = 4
DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_TRACKING_PROJECTILE = 8
DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_AOE = 16
DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_PASSIVE = 32
DOTA_EXTRA_ENUMS.SPECIAL_TARGET_TYPE_DOT = 64

DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_NONE = 0
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_WATER = 1
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_EARTH = 2
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_FIRE = 4
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_STORM = 8
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_ORDER = 16
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_CHAOS = 32
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_DIVINE = 64
DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_RANDOM = 128

DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_UNIT = 0
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_SELF = 1
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_POINT = 2
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_PASSIVE = 4
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_LINEAR_PROJECTILE = 8
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_TRACKING_PROJECTILE = 16
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_SINGLE_TARGET = 32
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_MULTI_TARGET = 64
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_AOE = 128
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_SUMMON = 256
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_DAMAGE = 512
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_HEAL = 1024
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_BUFF = 2048
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_EFFECTIVE = 4096
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_DURATION = 8192
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_DEBUFF = 16384
DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_BOMB = 32768