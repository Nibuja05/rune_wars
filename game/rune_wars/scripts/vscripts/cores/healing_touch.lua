healing_touch = class({})

function healing_touch:GetReferenceItem()
	return "item_ability_core_common_healing_touch"
end

function healing_touch:GetFunctions()
	local funcs = {
		"GetProjectileParticle",
		"OnProjectileHitUnit",
		"OnSpellStart",
	}
	return funcs
end

function healing_touch:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET,
		Cooldown = "%cooldown",
		Manacost = "%manacost",
		Castrange = "%range",
		Texture = "beastmaster_quillbeast_frenzy",
		Targettype = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		Targetflags = DOTA_UNIT_TARGET_FLAG,
		Targetteam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ALLIES_YES,
		Damagetype = DAMAGE_TYPE_NONE,
		Title = "Healing Touch",
		Description = "Heals targeted ally.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function healing_touch:GetProjectileParticle()
	return "particles/healing_touch/healing_touch_proj.vpcf"
end

function healing_touch:OnProjectileHitUnit(hTarget)
	local caster = self:GetCaster()
	local count = self:GetSpecialValueFor("heal")
	local particle = ParticleManager:CreateParticle("particles/healing_touch/healing_touch_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
	ParticleManager:SetParticleControlEnt(particle, 0, hTarget, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hTarget:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
	self:HealUnit(caster, hTarget, count)
end

function healing_touch:OnSpellStart()
	local caster = self:GetCaster()
	local casterLoc = caster:GetAbsOrigin()
	local target = self:GetCursorTarget()
	local speed = 1100

	self:DoTrackingProjectile(casterLoc, caster, target, speed)
end


