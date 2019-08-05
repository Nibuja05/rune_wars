LinkLuaModifier("modifier_passive_fiendish_hunger", "cores/fiendish_hunger.lua", LUA_MODIFIER_MOTION_NONE)

fiendish_hunger = class({})

function fiendish_hunger:GetReferenceItem()
	return "item_ability_core_passive_fiendish_hunger"
end

function fiendish_hunger:GetFunctions()
	local funcs = {
		"GetPassives",
		"OnUpgrade",
	}
	return funcs
end

function fiendish_hunger:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE,
		Texture = "orc_devour",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_NONE,
		Title = "Fiendish Hunger",
		Description = "Passively heals caster with percentage of elemental damage dealt.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function fiendish_hunger:GetPassives()
	local passives = {
		"modifier_passive_fiendish_hunger",
	}
	return passives
end

modifier_passive_fiendish_hunger = class({})

function modifier_passive_fiendish_hunger:IsDebuff()
	return false
end

function modifier_passive_fiendish_hunger:IsPassive()
	return true
end

function modifier_passive_fiendish_hunger:IsPurgable()
	return false
end

function modifier_passive_fiendish_hunger:IsHidden()
	return false
end 

function modifier_passive_fiendish_hunger:DeclareFunctions()
    local funcs =  {
        MODIFIER_EVENT_ON_ATTACK,
    }
    return funcs
end

function modifier_passive_fiendish_hunger:OnAttack( event )
    print("Attack!")
end

