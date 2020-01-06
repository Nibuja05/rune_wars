
LinkLuaModifier("modifier_elemental_attack", "abilities/neutral_elemental_attack.lua", LUA_MODIFIER_MOTION_NONE)

neutral_elemental_attack = class({})

function neutral_elemental_attack:IsInnate()
	return true
end

--make ability icon match the attack type!
function generic_ability:GetAbilityTextureName()
	return "modifier_invulnerable"
end

function generic_ability:GetIntrinsicModifierName()
	return "modifier_elemental_attack"
end

modifier_elemental_attack = class({})

function modifier_elemental_attack:IsHidden()
	return false
end

function modifier_elemental_attack:IsDebuff()
	return false
end

function modifier_elemental_attack:IsPurgable()
	return false
end