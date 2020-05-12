LinkLuaModifier("modifier_water_bomb_thinker", "cores/water_bomb.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_water_bomb_attach", "cores/water_bomb.lua", LUA_MODIFIER_MOTION_NONE)

water_bomb = class({})

function water_bomb:GetReferenceItem()
	return "item_ability_core_uncommon_water_bomb"
end

function water_bomb:GetFunctions()
	local funcs = {
		"PlayEffect",
		"GetProjectileParticle",
		"OnSpellStart",
		"CastOnPosition",
		"OnBombHit",
		"Explode",
	}
	return funcs
end


function water_bomb:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE,
		Castrange = "%range",
		Cooldown = "%cooldown",
		Manacost	= "%manacost",
		Aoeradius = "%radius",
		Texture = "120px-Alluvion_Prophecy_Fortune's_End_icon",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_MAGICAL,
		Title = "Water Bomb",
		Description = "Fires a bomb of concentrated water energy at target location. The bomb hovers there until an enemy unit approaches and attaches to that unit. When three bombs are attached to a unit or the maximum duration is reached, the bomb explodes and deals damage to all enemies around.",
		Lore = "lore...",
	}
	return abilityTable
end

function water_bomb:PlayEffect(loc, optArg)
	local particle = ParticleManager:CreateParticle("particles/core_abilities/water_bomb/water_bomb_explosion.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 3, loc)
end

function water_bomb:GetProjectileParticle()
	return "particles/core_abilities/water_bomb/water_bomb_projectile.vpcf"
end

function water_bomb:OnSpellStart()
	local loc = self:GetCursorPosition()
	self:CastOnPosition(loc)
end

function water_bomb:CastOnPosition(loc)
	local caster = self:GetCaster()
	local casterLoc = caster:GetAbsOrigin()

	local projectileSpeed = self:GetSpecialValueFor("projectile_speed")

	self:FireBomb(casterLoc, caster, loc, projectileSpeed, 0, nil)
end

function water_bomb:OnBombHit(loc, extraData)
	local caster = self:GetCaster()

	local maxDistance = self:GetSpecialValueFor("attach_range")
	local thinker = CreateModifierThinker(caster, self, "modifier_water_bomb_thinker", {maxDistance = maxDistance, Duration = 5}, loc, caster:GetTeamNumber(), false)
end

function water_bomb:Explode(loc)
	local caster = self:GetCaster()

	local targetTeam = self:GetAbilityTargetTeam()
	local targetType = self:GetAbilityTargetType()
	local targetFlags = self:GetAbilityTargetFlags()

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), loc, nil, self:GetAOERadius(), targetTeam, targetType, targetFlags, FIND_CLOSEST, false)
	for _,enemy in pairs(enemies) do
		self:DealDamage(self:GetSpecialValueFor("damage"), caster, enemy, self:GetAbilitySpecialDamageType())
	end
end

modifier_water_bomb_thinker = class({})

function modifier_water_bomb_thinker:IsPurgable()
	return false
end

function modifier_water_bomb_thinker:OnCreated(event)
	if IsClient() then return end
	self.particle = ParticleManager:CreateParticle("particles/core_abilities/water_bomb/water_bomb_hover.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	self.maxDistance = event.maxDistance
	self.outtimed = true
	self:StartIntervalThink(0.25)
end

function modifier_water_bomb_thinker:OnIntervalThink()
	if IsClient() then return end
	local caster = self:GetCaster()
	local casterLoc = self:GetParent():GetAbsOrigin()
	local ability = self:GetAbility()

	local targetTeam = ability:GetAbilityTargetTeam()
	local targetType = ability:GetAbilityTargetType()
	local targetFlags = ability:GetAbilityTargetFlags()

	local target = nil
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), casterLoc, nil, self.maxDistance, targetTeam, targetType, targetFlags, FIND_CLOSEST, false)
	for _,enemy in pairs(enemies) do
		target = enemy
		break
	end

	if target then
		local duration = ability:GetSpecialValueFor("duration")
		local modifier = target:AddNewModifier(caster, ability, "modifier_water_bomb_attach", {Duration = duration})
		modifier:SetStartLoc(casterLoc)
		modifier:IncrementCount()
		self.outtimed = false
		self:Destroy()
	end
end

function modifier_water_bomb_thinker:OnDestroy()
	if self.particle then
		if self.outtimed then
			local thinkerLoc = self:GetParent():GetAbsOrigin()
			self:GetAbility():PlayEffect(thinkerLoc)
			self:GetAbility():Explode(thinkerLoc)
		end
		ParticleManager:DestroyParticle(self.particle, false)
	end
end

modifier_water_bomb_attach = class({})

function modifier_water_bomb_attach:IsHidden()
	return false
end

function modifier_water_bomb_attach:IsDebuff()
	return true
end

function modifier_water_bomb_attach:IsPurgable()
	return false
end

function modifier_water_bomb_attach:OnCreated(event)
	if IsClient() then return end
	local parent = self:GetParent()
	self.particle = ParticleManager:CreateParticle("particles/core_abilities/water_bomb/water_bomb_attached.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	ParticleManager:SetParticleControlEnt(self.particle, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), false)
	self.count = 0
	self.startLoc = nil
	self.maxCount = self:GetAbility():GetSpecialValueFor("max_attach")
end

function modifier_water_bomb_attach:SetStartLoc(loc)
	self.startLoc = loc
	ParticleManager:SetParticleControl(self.particle, 2, self.startLoc)
end

function modifier_water_bomb_attach:IncrementCount()
	self.count = self.count + 1
	Timers:CreateTimer({
		endTime = 0.1,
		callback = function()
			ParticleManager:SetParticleControl(self.particle, 10, Vector(self.count,0,0))
		end
	})
	if self.count >= self.maxCount then
		Timers:CreateTimer({
			endTime = 1,
			callback = function()
				self:Destroy()
			end
		})	
	end
end

function modifier_water_bomb_attach:OnDestroy()
	if self.particle then
		local thinkerLoc = self:GetParent():GetAbsOrigin()
		for i=1,self.count do
			self:GetAbility():Explode(thinkerLoc)
		end
		ParticleManager:DestroyParticle(self.particle, false)
	end
end