
heal = class({})

function heal:GetReferenceItem()
	return "item_ability_core_common_heal"
end

function heal:GetFunctions()
	local funcs = {
		"PlayEffect",
		"OnSpellStart",
	}
	return funcs
end

function heal:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET,
		Cooldown = "%cooldown",
		Manacost = "%manacost",
		Texture = "oracle_purifying_flames",
		Targettype = DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ALLIES_YES,
		Damagetype = DAMAGE_TYPE_NONE,
		Title = "Heal",
		Description = "Heals the caster briefly.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function heal:PlayEffect(unit, optVal)
	local particle = ParticleManager:CreateParticle("particles/core_abilities/heal/heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControlEnt(particle, 0, unit, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
end

function heal:OnSpellStart()
	local caster = self:GetCaster()
	local count = self:GetSpecialValueFor("heal")


	self:PlayEffect(caster)
	self:HealUnit(caster, caster, count)
end