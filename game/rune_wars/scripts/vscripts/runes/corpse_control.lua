LinkLuaModifier("modifier_corpse_control_debuff", "runes/corpse_control.lua", LUA_MODIFIER_MOTION_NONE)

corpse_control = class({})

function corpse_control:GetReferenceItem()
	return "item_ability_rune_uncommon_corpse_control"
end

function corpse_control:GetAdditionalFunctions()
	local funcs = {
		"OnDealDamageCustom",
		"GetAdditionalAbilityKeys"
	}
	return funcs
end

function corpse_control:OnDealDamageCustom(eventData)
	local caster = self:GetCaster()
	local target = eventData.victim
	local duration = self:GetSpecialRuneValueFor("duration", "corpse_control")

	target:AddNewModifier(caster, self, "modifier_corpse_control_debuff", {Duration = duration})
end

function corpse_control:GetAdditionalAbilityKeys()
	local values = {
		DOTA_EXTRA_ENUMS.SPECIAL_ABILITY_KEY_SUMMON
	}
	return values
end

modifier_corpse_control_debuff = class({})

function modifier_corpse_control_debuff:IsHidden()
	return false
end

function modifier_corpse_control_debuff:IsPurgable()
	return true
end

function modifier_corpse_control_debuff:IsStunDebuff()
	return false
end

function modifier_corpse_control_debuff:IsDebuff()
	return true
end

function modifier_corpse_control_debuff:DeclareFunctions()
	local funcs =  {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_corpse_control_debuff:OnDeath(event)
	if IsServer() then
		if event.unit == self:GetParent() then
			local parent = self:GetParent()
			local ability = self:GetAbility()
			local duration = ability:GetSpecialRuneValueFor("skeleton_duration", "corpse_control")
			local modifiers = {}
			modifiers.first = {
				name = "modifier_kill",
				duration = duration,
			}
			ability:SummonUnit("npc_dota_corpse_skeleton", parent:GetAbsOrigin(), modifiers)
		end
	end
end