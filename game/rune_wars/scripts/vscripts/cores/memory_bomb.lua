LinkLuaModifier("modifier_memory_bomb_mark", "cores/memory_bomb.lua", LUA_MODIFIER_MOTION_NONE)

memory_bomb = class({})

function memory_bomb:GetReferenceItem()
	return "item_ability_core_uncommon_memory_bomb"
end

function memory_bomb:GetFunctions()
	local funcs = {
		"PlayEffect",
		"GetProjectileParticle",
		"OnSpellStart",
		"CastOnPosition",
		"OnBombHit",
	}
	return funcs
end


function memory_bomb:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE,
		Castrange = "%range",
		Cooldown = "%cooldown",
		Manacost	= "%manacost",
		Aoeradius = "%radius",
		Texture = "nightelf_mana_flare",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_MAGICAL,
		Title = "Memory Bomb",
		Description = "Fires a bomb of dark energy at target location, which instantly explodes there and leaves a memory marker. Additionally it fires two additional bombs at the last marked positions. Marks expire, if the caster gets too far away.",
		Lore = "'Never forget, always remember.' Shamanic Wisdom",
	}
	return abilityTable
end

function memory_bomb:PlayEffect(loc, optVal)
	local radius = self:GetSpecialValueFor("aoe_radius")
	local particle = ParticleManager:CreateParticle("particles/core_abilities/memory_bomb/memory_bomb_explosion.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, loc)
	ParticleManager:SetParticleControl(particle, 5, Vector(radius, 0, 0))
end

function memory_bomb:GetProjectileParticle()
	return "particles/core_abilities/memory_bomb/memory_bomb.vpcf"
end

function memory_bomb:OnSpellStart()
	local loc = self:GetCursorPosition()
	self:CastOnPosition(loc)
end

function memory_bomb:CastOnPosition(loc)
	local caster = self:GetCaster()
	local casterLoc = caster:GetAbsOrigin()

	local projectileSpeed = self:GetSpecialValueFor("projectile_speed")

	self:FireBomb(casterLoc, caster, loc, projectileSpeed, 0, {isMainBomb = true})

	if not self.memorySaves then self.memorySaves = {} end
	for _,thinker in pairs(self.memorySaves) do
		if thinker and IsValidEntity(thinker) then
			local thinkerLoc = thinker:GetAbsOrigin()
			self:FireBomb(casterLoc, caster, thinkerLoc, projectileSpeed, 0, nil)
			-- thinker:ForceKill(false)
		end
	end

end

function memory_bomb:OnBombHit(loc, extraData)
	local caster = self:GetCaster()

	local targetTeam = self:GetAbilityTargetTeam()
	local targetType = self:GetAbilityTargetType()
	local targetFlags = self:GetAbilityTargetFlags()

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), loc, nil, self:GetAOERadius(), targetTeam, targetType, targetFlags, FIND_CLOSEST, false)
	for _,enemy in pairs(enemies) do
		self:DealDamage(self:GetSpecialValueFor("damage"), caster, enemy, self:GetAbilitySpecialDamageType())
	end

	self:PlayEffect(loc)

	local maxDistance = self:GetSpecialValueFor("max_range")
	local maxCount = self:GetSpecialValueFor("saved_locations")

	if extraData.isMainBomb then
		local thinker = CreateModifierThinker(caster, self, "modifier_memory_bomb_mark", {maxDistance = maxDistance}, loc, caster:GetTeamNumber(), false)
		local oldThinker = nil
		self.memorySaves, oldThinker = PushPopTable(self.memorySaves, thinker, maxCount)
		if oldThinker and IsValidEntity(oldThinker) then
			oldThinker:ForceKill(false)
		end
	end
end

modifier_memory_bomb_mark = class({})

function modifier_memory_bomb_mark:IsPurgable()
	return false
end

function modifier_memory_bomb_mark:OnCreated(event)
	if IsClient() then return end
	self.particle = ParticleManager:CreateParticle("particles/core_abilities/memory_bomb/memory_bomb_mark.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	self.maxDistance = event.maxDistance

	self:StartIntervalThink(1)
end

function modifier_memory_bomb_mark:OnIntervalThink()
	if IsClient() then return end
	local caster = self:GetCaster()
	local casterLoc = caster:GetAbsOrigin()
	local parent = self:GetParent()
	local parentLoc = parent:GetAbsOrigin()

	local distance = (parentLoc - casterLoc):Length2D()
	if distance > self.maxDistance then
		self:Destroy()
	end
end

function modifier_memory_bomb_mark:OnDestroy()
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
	end
end