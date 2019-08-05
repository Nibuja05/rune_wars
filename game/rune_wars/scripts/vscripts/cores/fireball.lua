
fireball = class({})

function fireball:GetReferenceItem()
	return "item_ability_core_common_fireball"
end

function fireball:GetFunctions()
	local funcs = {
		"DoLinearProjectile",
		"OnProjectileHit",
		"OnSpellStart",
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

function fireball:DoLinearProjectile(startLoc, direction, speed, distance, width)
	local caster = self:GetCaster()

	local info = 
	{
		Ability = self,
    	EffectName = "particles/core_abilities/fireball/fireball.vpcf",
    	vSpawnOrigin = startLoc,
    	fDistance = distance,
    	fStartRadius = width,
    	fEndRadius = width,
    	Source = caster,
    	bHasFrontalCone = true,
    	bReplaceExisting = false,
    	iUnitTargetTeam = self:GetAbilityTargetTeam(),
    	iUnitTargetFlags = self:GetAbilityTargetFlags(),
    	iUnitTargetType = self:GetAbilityTargetType(),
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = direction * speed,
		bProvidesVision = true,
		iVisionRadius = width,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	local projectile = ProjectileManager:CreateLinearProjectile(info)
end

function fireball:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		self:DealDamage(self:GetSpecialValueFor("damage"), caster, hTarget, self:GetAbilitySpecialDamageType())
	end
	return false
end

function fireball:OnSpellStart()
	local caster = self:GetCaster()
	local loc = self:GetCursorPosition()
	local casterLoc = caster:GetAbsOrigin()

	local direction = (loc - casterLoc):Normalized()
	local speed = self:GetSpecialValueFor("projectile_speed")
	local distance = self:GetSpecialValueFor("range")

	self:DoLinearProjectile(casterLoc, direction, speed, distance, 100)
end