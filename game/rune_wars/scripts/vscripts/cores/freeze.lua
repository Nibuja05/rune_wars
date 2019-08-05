LinkLuaModifier("modifier_freeze_debuff", "cores/freeze.lua", LUA_MODIFIER_MOTION_NONE)
freeze = class({})

function freeze:GetReferenceItem()
	return "item_ability_core_common_freeze"
end

function freeze:GetFunctions()
	local funcs = {
		"DoTrackingProjectile",
		"OnProjectileHit",
		"OnSpellStart",
	}
	return funcs
end

function freeze:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET,
		Cooldown = "%cooldown",
		Manacost = "%manacost",
		Castrange = "%range",
		Texture = "crystal_maiden_frostbite",
		Targettype = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		Targetflags = DOTA_UNIT_TARGET_FLAG,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_YES,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_NONE,
		Title = "Freeze",
		Description = "Fires a fsat projectile at target unit to freeze it and deal damage over time",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function freeze:DoTrackingProjectile(startLoc, endUnit, speed, optVal)
	local caster = self:GetCaster()
	 local info = {
		Source = caster,
		Target = endUnit,
		Ability = self,	
		EffectName = "particles/core_abilities/freeze/freeze.vpcf",
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

function freeze:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("freeze_duration")
	hTarget:AddNewModifier(caster, self, "modifier_freeze_debuff", {Duration = duration})
end

function freeze:OnSpellStart()
	local caster = self:GetCaster()
	local casterLoc = caster:GetAbsOrigin()
	local target = self:GetCursorTarget()
	local speed = 1600

	self:DoTrackingProjectile(casterLoc, target, speed)
end

modifier_freeze_debuff = class({})

function modifier_freeze_debuff:IsHidden()
	return false
end

function modifier_freeze_debuff:IsDebuff()
	return true
end

function modifier_freeze_debuff:IsPurgable()
	return true
end

function modifier_freeze_debuff:CheckState()	 
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

function modifier_freeze_debuff:GetEffectName()
	return "particles/core_abilities/freeze/freeze_debuff.vpcf"
end

function modifier_freeze_debuff:OnCreated(event)
	if IsServer() then
		local ability = self:GetAbility()
		local damage = ability:GetSpecialValueFor("damage")
		local duration = event.Duration
		self.interval = 0.1
		self.damage = (damage / duration) * self.interval
		self:StartIntervalThink(self.interval)
		ability:DealDamage(self.damage, self:GetCaster(), self:GetParent(), ability:GetAbilitySpecialDamageType())
	end
end

function modifier_freeze_debuff:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		ability:DealDamage(self.damage, self:GetCaster(), self:GetParent(), ability:GetAbilitySpecialDamageType())
	end
end

