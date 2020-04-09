
LinkLuaModifier("modifier_shake_damage_per_second", "cores/shake.lua", LUA_MODIFIER_MOTION_NONE)
shake = class({})

function shake:GetReferenceItem()
	return "item_ability_core_common_shake"
end

function shake:GetFunctions()
	local funcs = {
		"PlayEffect",
		"OnSpellStart",
		"CastOnPosition",
	}
	return funcs
end

function shake:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE,
		Castrange = "%range",
		Cooldown = "%cooldown",
		Manacost	= "%manacost",
		Aoeradius = "%radius",
		Duration = "%duration",
		Texture = "leshrac_split_earth",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_MAGICAL,
		Title = "Shake",
		Description = "Shakes the ground in an area to damage all enemies within over time.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function shake:PlayEffect(loc, optVal)
	local particle = ParticleManager:CreateParticle("particles/core_abilities/shake/shake.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, loc)
	ParticleManager:SetParticleControl(particle, 1, Vector(1, 1, optVal/500))
	ParticleManager:ReleaseParticleIndex(particle)
end

function shake:OnSpellStart()
	local loc = self:GetCursorPosition()
	self:CastOnPosition(loc)
end

function shake:CastOnPosition(loc)
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor("radius")
	local targetTeam = self:GetAbilityTargetTeam()
	local targetType = self:GetAbilityTargetType()
	local targetFlags = self:GetAbilityTargetFlags()
	local duration = self:GetSpecialValueFor("spawn_interval")

	self:PlayEffect(loc, radius)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), loc, nil, radius, targetTeam, targetType, targetFlags, FIND_CLOSEST, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_shake_damage_per_second", {Duration = duration})
	end
end

modifier_shake_damage_per_second = class({})

function modifier_shake_damage_per_second:IsHidden()
	return false
end

function modifier_shake_damage_per_second:IsPurgable()
	return false
end

function modifier_shake_damage_per_second:IsDebuff()
	return true
end

function modifier_shake_damage_per_second:OnCreated(event)
	if IsServer() then
		local ability = self:GetAbility()
		local damage = ability:GetSpecialValueFor("total_damage")
		local duration = event.Duration
		self.interval = 0.1
		self.damage = (damage / duration) * self.interval
		self:StartIntervalThink(self.interval)
	end
end

function modifier_shake_damage_per_second:OnIntervalThink()
	if IsServer() then
		local ability = self:GetAbility()
		ability:DealDamage(self.damage, self:GetCaster(), self:GetParent(), ability:GetAbilitySpecialDamageType())
	end
end