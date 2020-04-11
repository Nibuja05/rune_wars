require("libs/generic_ability")
LinkLuaModifier("modifier_base_events_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)

generic_ability_q = class(generic_ability)

function generic_ability_q:GetAbilityClassName()
	return "generic_ability_q"
end

--=================================================================================================
--MODIFIER
--=================================================================================================

modifier_base_events_generic_ability_q = class({})

function modifier_base_events_generic_ability_q:IsHidden()
	return true
end

function modifier_base_events_generic_ability_q:IsPurgable()
	return false
end

function modifier_base_events_generic_ability_q:DeclareFunctions()
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

function modifier_base_events_generic_ability_q:OnAttackStart(event)
	self:GetAbility():AttackStartEvent(event)
end

function modifier_base_events_generic_ability_q:OnAttack(event)
	self:GetAbility():AttackEvent(event)
end

function modifier_base_events_generic_ability_q:OnAttackLanded(event)
	self:GetAbility():AttackLandedEvent(event)
end

function modifier_base_events_generic_ability_q:OnTakeDamage(event)
	self:GetAbility():TakeDamageEvent(event)
end

function modifier_base_events_generic_ability_q:OnAttacked(event)
	self:GetAbility():AttackedEvent(event)
end

function modifier_base_events_generic_ability_q:OnDeath(event)
	self:GetAbility():DeathEvent(event)
end