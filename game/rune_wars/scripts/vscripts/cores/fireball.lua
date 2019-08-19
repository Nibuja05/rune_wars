
fireball = class({})

function fireball:GetReferenceItem()
	return "item_ability_core_common_fireball"
end

function fireball:GetFunctions()
	local funcs = {
		"GetProjectileParticle",
		"OnSpellStart",
		"OnProjectileHitUnit",
	}
	return funcs
end

function fireball:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_POINT,
		Castrange = "%range",
		Cooldown = "%cooldown",
		Manacost = "%manacost",
		Texture = "lina_dragon_slave",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_MAGICAL,
		Title = "Fireball",
		Description = "Fires a fireball in a straight line to deal damage to all enemies it passes.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function fireball:GetProjectileParticle()
	return "particles/core_abilities/fireball/fireball.vpcf"
end

function fireball:OnProjectileHitUnit(hTarget)
	local caster = self:GetCaster()
	self:DealDamage(self:GetSpecialValueFor("damage"), caster, hTarget, self:GetAbilitySpecialDamageType())
	return false
end

function fireball:OnSpellStart()
	local caster = self:GetCaster()
	local loc = self:GetCursorPosition()
	local casterLoc = caster:GetAbsOrigin()

	local direction = (loc - casterLoc):Normalized()
	local speed = self:GetSpecialValueFor("projectile_speed")
	local distance = self:GetSpecialValueFor("range")

	self:DoLinearProjectile(casterLoc, direction, speed, distance, 100, 250)
end