LinkLuaModifier("modifier_weakness_passive_aura_emit", "cores/weakness.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_weakness_aura_debuff", "cores/weakness.lua", LUA_MODIFIER_MOTION_NONE)
weakness = class({})

function weakness:GetReferenceItem()
	return "item_ability_core_common_weakness"
end

function weakness:GetFunctions()
	local funcs = {
		"GetPassives",
	}
	return funcs
end

function weakness:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE + DOTA_ABILITY_BEHAVIOR_AURA,
		Aoeradius = "%radius",
		Duration = "%duration",
		Texture = "satyr_trickster_purge",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_NONE,
		Title = "Weakness Aura",
		Description = "Emits a dark aura, that weakens enemies, reducing their damage dealt while amplifying their damage taken from any type of damage.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function weakness:GetPassives()
	local passives = {
		"modifier_weakness_passive_aura_emit",
	}
	return passives
end

modifier_weakness_passive_aura_emit = class({})

function modifier_weakness_passive_aura_emit:IsDebuff()
	return false
end

function modifier_weakness_passive_aura_emit:IsPassive()
	return true
end

function modifier_weakness_passive_aura_emit:IsPurgable()
	return false
end

function modifier_weakness_passive_aura_emit:IsHidden()
	return false
end

function modifier_weakness_passive_aura_emit:IsAura()
	return true
end

function modifier_weakness_passive_aura_emit:GetModifierAura()
	return "modifier_weakness_aura_debuff"
end

function modifier_weakness_passive_aura_emit:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_weakness_passive_aura_emit:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_weakness_passive_aura_emit:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

function modifier_weakness_passive_aura_emit:GetAuraSearchFlags()
	return self:GetAbility():GetAbilityTargetFlags()
end

modifier_weakness_aura_debuff = class({})

function modifier_weakness_aura_debuff:IsHidden()
	return false
end

function modifier_weakness_aura_debuff:IsPurgable()
	return false
end

function modifier_weakness_aura_debuff:IsDebuff()
	return true
end

function modifier_weakness_aura_debuff:DeclareFunctions()
	local funcs =  {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
	return funcs
end

function modifier_weakness_aura_debuff:OnCreated(event)
	if IsServer() then
		local ability = self:GetAbility()
		self.incomingPerc = ability:GetSpecialValueFor("damage_amplificaton")
		self.outgoingPerc = ability:GetSpecialValueFor("damage_reduction")
	end
end

function modifier_weakness_aura_debuff:GetModifierIncomingDamage_Percentage()
	return self.incomingPerc
end

function modifier_weakness_aura_debuff:GetModifierDamageOutgoing_Percentage()
	return self.outgoingPerc
end