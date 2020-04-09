
LinkLuaModifier("modifier_plague_swarm_spawner", "cores/plague_swarm.lua", LUA_MODIFIER_MOTION_NONE)
plague_swarm = class({})

function plague_swarm:GetReferenceItem()
	return "item_ability_core_uncommon_plague_swarm"
end

function plague_swarm:GetFunctions()
	local funcs = {
		"OnSpellStart",
		"CastOnPosition",
	}
	return funcs
end

function plague_swarm:GetAbilityTable()
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
		Title = "Plague Swarm",
		Description = "Continously spawns swarms that search for nearby enemies and attack them. They despawn if no enemy is nearby.",
		Lore = "Calling out everything that lurks in the dark",
	}
	return abilityTable
end

function plague_swarm:OnSpellStart()
	local loc = self:GetCursorPosition()
	self:CastOnPosition(loc)
end

function plague_swarm:CastOnPosition(loc)
	local caster = self:GetCaster()

	local radius = self:GetSpecialValueFor("radius")
	local targetTeam = self:GetAbilityTargetTeam()
	local targetType = self:GetAbilityTargetType()
	local targetFlags = self:GetAbilityTargetFlags()
	local duration = self:GetSpecialValueFor("duration")
	local interval = self:GetSpecialValueFor("spawn_interval")
	local damage = self:GetSpecialValueFor("damage_per_swarm")

	local thinker = CreateModifierThinker(caster, self, "modifier_plague_swarm_spawner", {Duration=duration, radius=radius, targetTeam=targetTeam, targetFlags=targetFlags, targetType=targetType, interval=interval, damage=damage}, loc, caster:GetTeamNumber(), false)
end

modifier_plague_swarm_spawner = class({})

function modifier_plague_swarm_spawner:OnCreated(event)
	if IsClient() then return end
	self.radius = event.radius
	self.particle = ParticleManager:CreateParticle("particles/core_abilities/plague_swarm/plague_swarm_pit.vpcf", PATTACH_ABSORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, Vector(self.radius,0,0))
	self.targetTeam = event.targetTeam
	self.targetType = event.targetType
	self.targetFlags = event.targetFlags
	self.damage = event.damage

	self.interval = event.interval
	self:StartIntervalThink(self.interval)

end

function modifier_plague_swarm_spawner:OnIntervalThink()
	if IsClient() then return end

	local randLoc = self:GetParent():GetAbsOrigin() + RandomVector(RandomInt(0, self.radius))
	local newSwarm = Swarm(self:GetCaster(), self:GetParent(), self:GetAbility(), randLoc, self.targetTeam, self.targetType, self.targetFlags, self.damage)
	newSwarm:spawn()
end

function modifier_plague_swarm_spawner:OnDestroy()
	if IsClient() then return end
	ParticleManager:DestroyParticle(self.particle, false)
end

Swarm = {}
Swarm.__index = Swarm
Swarm_mt = {__call = function(_, ...) return Swarm.new(...) end }
setmetatable(Swarm, Swarm_mt)

function Swarm.new(caster, parent, ability, loc, targetTeam, targetType, targetFlags, damage)
	return setmetatable({id=RandomInt(0, 99999),caster=caster, parent=parent, ability=ability, loc=loc, curLoc=loc, target=nil, spawnTimer=0, targetTeam=targetTeam, targetType=targetType, targetFlags=targetFlags, damage=damage, timer=""}, Swarm)
end

function Swarm:__eq(sp)
	return (self.id == sp.id)
end

function Swarm:spawn()
	self.particle = ParticleManager:CreateParticle("particles/core_abilities/plague_swarm/plague_swarm_projectile_controller.vpcf", PATTACH_CUSTOMORIGIN, self.caster)
	ParticleManager:SetParticleControl(self.particle, 0, self.loc)
	ParticleManager:SetParticleControl(self.particle, 1, self.loc)
	self.timer = Timers:CreateTimer(function()
		local kill = self:tick()
		if not kill then
			return 0.01
		else
			return nil
		end
	end)
end

function Swarm:tick()
	-- print("tick!", self.spawnTimer)
	self.spawnTimer = self.spawnTimer + 0.01
	if self.spawnTimer < 1 then
		self.curLoc = self.curLoc + Vector(0,0,2)
		ParticleManager:SetParticleControl(self.particle, 1, self.curLoc)
	else
		if not self.target then
			local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.curLoc, nil, 500, self.targetTeam, self.targetType, self.targetFlags, FIND_CLOSEST, false)
			for _,enemy in pairs(enemies) do
				self.target = enemy
				break
			end
			if not self.target then
				self:Kill(true)
				return true
			end
		end
		local targetLoc = self.target:GetAbsOrigin() + Vector(0,0,100)
		local direction = (targetLoc - self.curLoc):Normalized()
		local speed = 600 * 0.01 * 3
		self.curLoc = self.curLoc + direction * speed
		ParticleManager:SetParticleControl(self.particle, 1, self.curLoc)

		local distance = (targetLoc - self.curLoc):Length2D()
		if distance < 5 then
			self:Kill(false)
			return true
		end
	end
	if self.target then
		if not self.target:IsAlive() then
			self:Kill(true)
			return true
		end
	end
	if self.spawnTimer > 6 then
		self:Kill(true)
		return true
	end
	return false
end

function Swarm:isAlive()
	return self.alive
end

function Swarm:Kill(noTarget)
	self.ability:DealDamage(self.damage, self.caster, self.target, self.ability:GetAbilitySpecialDamageType())
	ParticleManager:DestroyParticle(self.particle, noTarget)
end