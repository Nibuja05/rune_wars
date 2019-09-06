require("libs/generic_ability")
LinkLuaModifier("modifier_base_events_generic_ability_e", "abilities/generic_ability_e.lua", LUA_MODIFIER_MOTION_NONE)

generic_ability_e = class(generic_ability)

function generic_ability_e:GetAbilityClassName()
	return "generic_ability_e"
end

--=================================================================================================
--MODIFIER
--=================================================================================================


modifier_base_events_generic_ability_e = class({})

function modifier_base_events_generic_ability_e:IsHidden()
	return true
end

function modifier_base_events_generic_ability_e:IsPurgable()
	return false
end

function modifier_base_events_generic_ability_e:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_base_events_generic_ability_e:OnAttackStart(event)
	self:GetAbility():AttackStartEvent(event)
end

function modifier_base_events_generic_ability_e:OnAttack(event)
	self:GetAbility():AttackEvent(event)
end

function modifier_base_events_generic_ability_e:OnAttackLanded(event)
	self:GetAbility():AttackLandedEvent(event)
end

function modifier_base_events_generic_ability_e:OnTakeDamage(event)
	self:GetAbility():TakeDamageEvent(event)
end

function modifier_base_events_generic_ability_e:OnAttacked(event)
	self:GetAbility():AttackedEvent(event)
end

function modifier_base_events_generic_ability_e:OnDeath(event)
	self:GetAbility():DeathEvent(event)
end