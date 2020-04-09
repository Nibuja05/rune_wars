
LinkLuaModifier("modifier_elemental_attack", "abilities/neutral_elemental_attack.lua", LUA_MODIFIER_MOTION_NONE)
require("libs/extra_enums")

neutral_elemental_attack = class({})

function neutral_elemental_attack:IsInnate()
	return true
end

function neutral_elemental_attack:GetNeutralValue(name)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("neutrals", tostring(caster:entindex()))
	if not netTable then return end
	if not netTable[name] then return end
	return netTable[name]
end

function neutral_elemental_attack:SetNeutralValue(name, value)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("neutrals", tostring(caster:entindex()))
	if not netTable then return end
	netTable[name] = value
	CustomNetTables:SetTableValue("neutrals", tostring(caster:entindex()), netTable)
end

function neutral_elemental_attack:RemoveNeutral()
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("neutrals", tostring(caster:entindex()))
	if not netTable then return end
	netTable = nil
	CustomNetTables:SetTableValue("neutrals", tostring(caster:entindex()), netTable)
end

function neutral_elemental_attack:GetIntrinsicModifierName()
	return "modifier_elemental_attack"
end

neutral_elemental_attack_fire = class(neutral_elemental_attack)
neutral_elemental_attack_water = class(neutral_elemental_attack)
neutral_elemental_attack_earth = class(neutral_elemental_attack)
neutral_elemental_attack_storm = class(neutral_elemental_attack)
neutral_elemental_attack_order = class(neutral_elemental_attack)
neutral_elemental_attack_chaos = class(neutral_elemental_attack)
neutral_elemental_attack_divine = class(neutral_elemental_attack)

-- function neutral_elemental_attack_fire:GetIntrinsicModifierName()
-- 	return "modifier_elemental_attack"
-- end

-- function neutral_elemental_attack_water:GetIntrinsicModifierName()
-- 	return "modifier_elemental_attack"
-- end

-- function neutral_elemental_attack_earth:GetIntrinsicModifierName()
-- 	return "modifier_elemental_attack"
-- end

-- function neutral_elemental_attack_storm:GetIntrinsicModifierName()
-- 	return "modifier_elemental_attack"
-- end

-- function neutral_elemental_attack_order:GetIntrinsicModifierName()
-- 	return "modifier_elemental_attack"
-- end

-- function neutral_elemental_attack_chaos:GetIntrinsicModifierName()
-- 	return "modifier_elemental_attack"
-- end

-- function neutral_elemental_attack_divine:GetIntrinsicModifierName()
-- 	return "modifier_elemental_attack"
-- end

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

function modifier_elemental_attack:OnCreated(event)
	if IsClient() then return end
	self.ability = self:GetAbility()
end

function modifier_elemental_attack:GetDamageType()
	return self.ability:GetNeutralValue("attackType")
end

function modifier_elemental_attack:DeclareFunctions()
	local funcs =  {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_elemental_attack:OnDeath(event)
	if IsClient() then return end
	if event.unit == self:GetParent() then
		self.ability:RemoveNeutral()
	end
end