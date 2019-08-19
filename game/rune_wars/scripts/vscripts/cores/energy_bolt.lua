energy_bolt = class({})

function energy_bolt:GetReferenceItem()
	return "item_ability_core_common_energy_bolt"
end

function energy_bolt:GetFunctions()
	local funcs = {
		"DoTrackingProjectile",
		"OnProjectileHitUnit",
		"OnSpellStart",
	}
	return funcs
end

function energy_bolt:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET,
		Cooldown = "%cooldown",
		Manacost = "%manacost",
		Castrange = "%range",
		Texture = "120px-Blessing_of_the_Crested_Umbra_Magic_Missile_icon",
		Targettype = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		Targetflags = DOTA_UNIT_TARGET_FLAG,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_YES,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_NONE,
		Title = "Energy Bolt",
		Description = "Fires an energy bolt to targeted enemy that deals damage.",
		Lore = "A simple powerful blast, but never underestimate it's power.",
	}
	return abilityTable
end

function energy_bolt:DoTrackingProjectile(startLoc, endUnit, speed, optVal)
	local caster = self:GetCaster()
	 local info = {
		Source = caster,
		Target = endUnit,
		Ability = self,	
		EffectName = "particles/econ/items/templar_assassin/templar_assassin_butterfly/templar_assassin_meld_attack_butterfly.vpcf",
		iMoveSpeed = speed,
		vSourceLoc= startLoc,                -- Optional (HOW)
		bDrawsOnMinimap = false,                          -- Optional
		bDodgeable = true,                                -- Optional
		bIsAttack = false,                                -- Optional
		bVisibleToEnemies = true,                         -- Optional
		bReplaceExisting = false,                         -- Optional
		bProvidesVision = true,                           -- Optional
		iVisionRadius = 200,                              -- Optional
		iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
	}	
	
	ProjectileManager:CreateTrackingProjectile(info)
end

function energy_bolt:OnProjectileHitUnit(hTarget)
	local caster = self:GetCaster()
	self:DealDamage(self:GetSpecialValueFor("damage"), caster, hTarget, self:GetAbilitySpecialDamageType())
end

function energy_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local casterLoc = caster:GetAbsOrigin()
	local target = self:GetCursorTarget()
	local speed = 1600

	self:DoTrackingProjectile(casterLoc, target, speed)
end


