
spark = class({})

function spark:GetReferenceItem()
	return "item_ability_core_common_spark"
end

function spark:GetFunctions()
	local funcs = {
		"PlayEffect",
		"OnSpellStart",
	}
	return funcs
end

function spark:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET,
		Castrange = "%range",
		Cooldown = "%cooldown",
		Manacost	= "%manacost",
		Texture = "zuus_lightning_bolt",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_MAGICAL,
		Title = "Spark",
		Description = "Shocks a single enemy to deal damage.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function spark:PlayEffect(startUnit, endUnit, optVal)
	local particleName = "particles/core_abilities/spark/spark.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, startUnit)
	ParticleManager:SetParticleControlEnt(particle, 0, endUnit, PATTACH_POINT_FOLLOW, "attach_hitloc", endUnit:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, startUnit, PATTACH_POINT_FOLLOW, "attach_attack1", startUnit:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
end

function spark:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self:PlayEffect(caster, target)
	self:DealDamage(self:GetSpecialValueFor("damage"), caster, target, self:GetAbilitySpecialDamageType())
end