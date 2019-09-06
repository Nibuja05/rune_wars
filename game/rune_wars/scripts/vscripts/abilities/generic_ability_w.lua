require("libs/generic_ability")
LinkLuaModifier("modifier_base_events_generic_ability_w", "abilities/generic_ability_w.lua", LUA_MODIFIER_MOTION_NONE)

generic_ability_w = class(generic_ability)

function generic_ability_w:GetAbilityClassName()
	return "generic_ability_w"
end

--=================================================================================================
--MODIFIER
--=================================================================================================


modifier_base_events_generic_ability_w = class({})

function modifier_base_events_generic_ability_w:IsHidden()
	return true
end

function modifier_base_events_generic_ability_w:IsPurgable()
	return false
end

function modifier_base_events_generic_ability_w:DeclareFunctions()
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

function modifier_base_events_generic_ability_w:OnAttackStart(event)
	self:GetAbility():AttackStartEvent(event)
end

function modifier_base_events_generic_ability_w:OnAttack(event)
	self:GetAbility():AttackEvent(event)
end

function modifier_base_events_generic_ability_w:OnAttackLanded(event)
	self:GetAbility():AttackLandedEvent(event)
end

function modifier_base_events_generic_ability_w:OnTakeDamage(event)
	self:GetAbility():TakeDamageEvent(event)
end

function modifier_base_events_generic_ability_w:OnAttacked(event)
	self:GetAbility():AttackedEvent(event)
end

function modifier_base_events_generic_ability_w:OnDeath(event)
	self:GetAbility():DeathEvent(event)
end