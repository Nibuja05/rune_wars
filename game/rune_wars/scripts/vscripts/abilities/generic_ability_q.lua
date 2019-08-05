LinkLuaModifier("modifier_reload_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_manacost_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_behavior_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_castrange_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cooldown_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_targetteam_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_targettype_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_targetflags_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spellimmunity_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_duration_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aoeradius_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_castpoint_generic_ability_q", "abilities/generic_ability_q.lua", LUA_MODIFIER_MOTION_NONE)

require("libs/generic_ability")

generic_ability_q = class(generic_ability)

--IMPORTANT!
--Please only use the public functions, as all other function can cause bad beahvior or malfunctioning
--Thanks!

function generic_ability_q:GetAbilityClassName()
	return "generic_ability_q"
end

--=================================================================================================
--MODIFIER
--=================================================================================================

modifier_reload_generic_ability_q = class({})

function modifier_reload_generic_ability_q:IsHidden()
	return true
end

function modifier_reload_generic_ability_q:IsDebuff()
	return false
end

function modifier_reload_generic_ability_q:IsPurgable()
	return false
end

modifier_manacost_generic_ability_q = class({})

function modifier_manacost_generic_ability_q:IsHidden()
	return true
end

function modifier_manacost_generic_ability_q:IsDebuff()
	return false
end

function modifier_manacost_generic_ability_q:IsPurgable()
	return false
end

modifier_behavior_generic_ability_q = class({})

function modifier_behavior_generic_ability_q:IsHidden()
	return true
end

function modifier_behavior_generic_ability_q:IsDebuff()
	return false
end

function modifier_behavior_generic_ability_q:IsPurgable()
	return false
end

modifier_castrange_generic_ability_q = class({})

function modifier_castrange_generic_ability_q:IsHidden()
	return true
end

function modifier_castrange_generic_ability_q:IsDebuff()
	return false
end

function modifier_castrange_generic_ability_q:IsPurgable()
	return false
end

modifier_cooldown_generic_ability_q = class({})

function modifier_cooldown_generic_ability_q:IsHidden()
	return true
end

function modifier_cooldown_generic_ability_q:IsDebuff()
	return false
end

function modifier_cooldown_generic_ability_q:IsPurgable()
	return false
end

modifier_targetteam_generic_ability_q = class({})

function modifier_targetteam_generic_ability_q:IsHidden()
	return true
end

function modifier_targetteam_generic_ability_q:IsDebuff()
	return false
end

function modifier_targetteam_generic_ability_q:IsPurgable()
	return false
end

modifier_targettype_generic_ability_q = class({})

function modifier_targettype_generic_ability_q:IsHidden()
	return true
end

function modifier_targettype_generic_ability_q:IsDebuff()
	return false
end

function modifier_targettype_generic_ability_q:IsPurgable()
	return false
end

modifier_targetflags_generic_ability_q = class({})

function modifier_targetflags_generic_ability_q:IsHidden()
	return true
end

function modifier_targetflags_generic_ability_q:IsDebuff()
	return false
end

function modifier_targetflags_generic_ability_q:IsPurgable()
	return false
end

modifier_aoeradius_generic_ability_q = class({})

function modifier_aoeradius_generic_ability_q:IsHidden()
	return true
end

function modifier_aoeradius_generic_ability_q:IsDebuff()
	return false
end

function modifier_aoeradius_generic_ability_q:IsPurgable()
	return false
end

modifier_spellimmunity_generic_ability_q = class({})

function modifier_spellimmunity_generic_ability_q:IsHidden()
	return true
end

function modifier_spellimmunity_generic_ability_q:IsDebuff()
	return false
end

function modifier_spellimmunity_generic_ability_q:IsPurgable()
	return false
end

modifier_duration_generic_ability_q = class({})

function modifier_duration_generic_ability_q:IsHidden()
	return true
end

function modifier_duration_generic_ability_q:IsDebuff()
	return false
end

function modifier_duration_generic_ability_q:IsPurgable()
	return false
end

modifier_castpoint_generic_ability_q = class({})

function modifier_castpoint_generic_ability_q:IsHidden()
	return true
end

function modifier_castpoint_generic_ability_q:IsDebuff()
	return false
end

function modifier_castpoint_generic_ability_q:IsPurgable()
	return false
end