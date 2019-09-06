
generic_ability = class({})

--=================================================================================================
--PUBLIC FUNCTIONS
--=================================================================================================

function generic_ability:GetSpecialValueFor(name)
	return tonumber(self:GetAttribute(name, self:GetLevel()))
end

function generic_ability:GetLevelSpecialValueFor(name, level)
	return tonumber(self:GetAttribute(name, level))
end

function generic_ability:AddSpecialValue(name, text, val)
	self:AddAttribute(name, text, val)
end

function generic_ability:RemoveSpecialValue(name)
	self:RemoveAttribute(name)
end

function generic_ability:ClearAllSpecialValues()
	self:ClearAttributes()
end

function generic_ability:GetSpecialRuneValueFor(name, runeName)
	return tonumber(self:GetRuneAttribute(name, runeName))
end

function generic_ability:AddSpecialRuneValue(name, text, val, runeName)
	self:AddRuneAttribute(name, text, val, runeName)
end

function generic_ability:RemoveSpecialRuneValue(name, runeName)
	self:RemoveRuneAttribute(name, runeName)
end

function generic_ability:ClearAllSpecialRuneValues(runeName)
	self:ClearRuneAttributes(runeName)
end

function generic_ability:GetBehavior()
	local val
	if IsClient() then
		-- val = self:LimitFunctionCall(function(self, valType) return self:GetNumberValue(valType) end, 200, "behavior", "behavior")
		val = self:GetNumberValue("behavior")
	else
		val = self:GetNumberValue("behavior")
	end
	return val
end

function generic_ability:SetBehavior(behavior)
	self:SetValues("behavior", behavior)
end

function generic_ability:GetCastRange(vLocation, hTarget)
	return self:GetNumberValue("castRange")
end

function generic_ability:SetCastRange(castRange)
	self:SetValues("castRange", castRange)
end

function generic_ability:GetCooldown(level)
	return self:GetNumberValue("cooldown")
end

function generic_ability:SetCooldown(cooldown)
	self:SetValues("cooldown", cooldown)
end

function generic_ability:GetManaCost(level)
	local val
	if IsClient() then
		-- val = self:LimitFunctionCall(function(self, valType) return self:GetNumberValue(valType) end, 50, "manaCost", "manaCost")
		val = self:GetNumberValue("manaCost")
	else
		val = self:GetNumberValue("manaCost")
	end
	return val
end

function generic_ability:SetManaCost(manaCost)
	self:SetValues("manaCost", manaCost)
end

function generic_ability:GetAOERadius()
	return self:GetNumberValue("aoeRadius")
end

function generic_ability:SetAOERadius(aoeRadius)
	self:SetValues("aoeRadius", aoeRadius)
end

function generic_ability:GetAbilityDuration()
	return self:GetNumberValue("duration")
end

function generic_ability:SetAbilityDuration(duration)
	self:SetValues("duration", duration)
end

function generic_ability:GetAbilityTextureName()
	return self:GetStringValue("texture")
end

function generic_ability:SetAbilityTextureName(texture)
	self:SetValues("texture", texture)
end

function generic_ability:GetCastPoint()
	return self:GetNumberValue("castPoint")
end

function generic_ability:SetCastPoint(castPoint)
	self:SetValues("castPoint", castPoint)
	self:UpdateCastPoint()
end

function generic_ability:GetAbilityTargetType()
	return self:GetNumberValue("targetType")
end

function generic_ability:SetAbilityTargetType(targetType)
	self:SetValues("targetType", targetType)
end

function generic_ability:GetAbilityTargetFlags()
	return self:GetNumberValue("targetFlags")
end

function generic_ability:SetAbilityTargetFlags(targetFlags)
	self:SetValues("targetFlags", targetFlags)
end

function generic_ability:GetAbilityTargetTeam()
	return self:GetNumberValue("targetTeam")
end

function generic_ability:SetAbilityTargetTeam(targetTeam)
	self:SetValues("targetTeam", targetTeam)
end

function generic_ability:GetAbilityDamageType()
	return self:GetNumberValue("damageType")
end

function generic_ability:SetAbilityDamageType(damageType)
	self:SetValues("damageType", damageType)
end

function generic_ability:GetAbilitySpecialDamageType()
	return self:GetNumberValue("specialDamageType")
end

function generic_ability:SetAbilitySpecialDamageType(specialDamageType)
	self:SetValues("specialDamageType", specialDamageType)
end

function generic_ability:GetAbilitySpellImmunityType()
	return self:GetNumberValue("spellImmunity")
end

function generic_ability:SetAbilitySpellImmunityType(spellImmunity)
	self:SetValues("spellImmunity", spellImmunity)
end

function generic_ability:GetAbilityDispelType()
	return self:GetNumberValue("dispelType")
end

function generic_ability:SetAbilityDispelType(dispelType)
	self:SetValues("dispelType", dispelType)
end

function generic_ability:GetAbilityDescription()
	return self:GetStringValue("description")
end

function generic_ability:SetAbilityDescription(description)
	self:SetValues("description", description)
end

function generic_ability:GetAbilityLore()
	return self:GetStringValue("lore")
end

function generic_ability:SetAbilityLore(lore)
	self:SetValues("lore", lore)
end

function generic_ability:GetAbilityTitle()
	return self:GetStringValue("title")
end

function generic_ability:SetAbilityTitle(title)
	self:SetValues("title", title)
end

function generic_ability:GetCurrentRunes()
	return self.runes
end

function generic_ability:SetCurrentRunes(curRunes)
	self.runes = curRunes
	self:SetCurrentRunesInTable()
end

function generic_ability:GetAbilitySpecialKeys()
	return self:GetNumberValue("specialkeys")
end

function generic_ability:SetAbilitySpecialKeys(specialkeys)
	self:SetValues("specialkeys", specialkeys)
end

function generic_ability:HasSpecialAbilityKey(key)
	if bit.band(self:GetAbilitySpecialKeys(), key) ~= 0 then
		return true
	end
	return false
end

function generic_ability:ReloadAbility()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_reload_"..self:GetAbilityClassName(), {Duration = 0.1})

	-- self:AddEventModifier()
	-- self:UpdateModifier("manaCost")
	-- self:UpdateModifier("cooldown")
	-- self:UpdateModifier("behavior")
	-- self:UpdateModifier("castRange")
	-- self:UpdateModifier("targetTeam")
	-- self:UpdateModifier("targetType")
	-- self:UpdateModifier("targetFlags")
	-- self:UpdateModifier("spellImmunity")
	-- self:UpdateModifier("aoeRadius")
	-- self:UpdateModifier("duration")
	-- self:UpdateModifier("castPoint")

	if self["GetPassives"] then
		local passives = self:GetPassives()
		if type(passives) == "table" then
			if self:GetLevel() > 0 then
				self:AddPassives(passives)
			end
		end
	end

	self:UpdateCastPoint()
end

--=================================================================================================
--ADVANCED PUBLIC FUNCTIONS
--=================================================================================================

function generic_ability:DealDamage(damage, attacker, victim, specialDamageType)
	local damageTable = {
		damage = damage,
		attacker = attacker,
		victim = victim,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self,
	}
	Elements:ApplyDamage(damageTable, specialDamageType)
	local eventData = {
		damage = damage,
		victim = victim,
		specialDamageType = specialDamageType,
	}
	if self["OnDealDamageCustom"] then self:OnDealDamageCustom(eventData) end
end

function generic_ability:HealUnit(target, source, amount)
	Elements:HealUnit(target, source, amount)
end

function generic_ability:ModifyElementalStat(statType, change)
	local caster = self:GetCaster()
	HeroStats:ModifyElementalStat(caster, statType, change)
end

function generic_ability:DoLinearProjectile(startLoc, direction, speed, distance, width, visionRadius, extraData)
	local caster = self:GetCaster()
	if not visionRadius then visionRadius = 0 end

	if not extraData then extraData = {} end
	extraData.startX = startLoc.x
	extraData.startY = startLoc.y
	extraData.startZ = startLoc.z
	extraData.directionX = direction.x
	extraData.directionY = direction.y
	extraData.directionZ = direction.z
	extraData.speed = speed
	extraData.distance = distance
	extraData.width = width
	extraData.visionRadius = visionRadius

	local info = 
	{
		Ability = self,
    	EffectName = self:GetProjectileParticle(),
    	vSpawnOrigin = startLoc,
    	fDistance = distance,
    	fStartRadius = width,
    	fEndRadius = width,
    	Source = caster,
    	bHasFrontalCone = (extraData.hasFrontalCone == true),
    	bReplaceExisting = (extraData.replaceExisting == true),
    	iUnitTargetTeam = self:GetAbilityTargetTeam(),
    	iUnitTargetFlags = self:GetAbilityTargetFlags(),
    	iUnitTargetType = self:GetAbilityTargetType(),
    	fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = (extraData.deleteOnHit == true),
		vVelocity = direction * speed,
		bProvidesVision = (visionRadius > 0),
		iVisionRadius = visionRadius,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = extraData,
	}
	local projectile = ProjectileManager:CreateLinearProjectile(info)
end

function generic_ability:DoTrackingProjectile(startLoc, startUnit, endUnit, speed, visionRadius, extraData)
	local caster = self:GetCaster()
	if not visionRadius then visionRadius = 0 end

	if not extraData then extraData = {} end
	extraData.startX = startLoc.x
	extraData.startY = startLoc.y
	extraData.startZ = startLoc.z
	extraData.speed = speed
	extraData.targetID = endUnit:entindex()
	extraData.sourceID = startUnit:entindex()
	extraData.visionRadius = visionRadius

	local info = {
		Source = startUnit,
		Target = endUnit,
		Ability = self,	
		EffectName = self:GetProjectileParticle(),
		iMoveSpeed = speed,
		vSourceLoc= startLoc,
		bDrawsOnMinimap = false,
		bDodgeable = (extraData.dodgeable == true),
		bIsAttack = (extraData.isAttack == true),
		bVisibleToEnemies = (extraData.visibleToEnemies == true),
		bReplaceExisting = (extraData.replaceExisting == true),
		bProvidesVision = (visionRadius > 0),
		iVisionRadius = visionRadius,
		iVisionTeamNumber = caster:GetTeamNumber(),
		ExtraData = extraData,
	}	
	
	local projectile = ProjectileManager:CreateTrackingProjectile(info)
end

--=================================================================================================
--HIDDEN FUNCTIONS
--=================================================================================================

function generic_ability:UpdateModifier(name)
	local caster = self:GetCaster()
	local modifierName = "modifier_"..name:lower().."_"..self:GetAbilityClassName()
	local modifier = caster:AddNewModifier(caster, self, modifierName, nil)
	if self:GetNumberValue(name) then
		modifier:SetStackCount(self:GetNumberValue(name))
	end
end

function generic_ability:ReplaceRelativeString(str)
	str = tostring(str)
	local newString = str:match("%%(%a*)")
	if newString then
		newString = str:match("%%(%a*)")
		local caster = self:GetCaster()
		local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
		if not netTable then return 0 end
		local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
		if not abilityIndex then return 0 end
		local abilityTable = netTable.abilities[tostring(abilityIndex)]
		if not abilityTable then return 0 end
		newString = FindAttribute(abilityTable.attributes, newString)
	else
		return str
	end
	return newString
end

function generic_ability:LimitFunctionCall(func, cycle, save, ...)
	if not self[save] then
		self[save] = {}
		self[save].tick = 0
	end
	self[save].tick = self[save].tick + 1
	if self[save].tick % cycle == 0 or self[save].val == nil then
		local ret = func(self, select(1, ...))
		self[save].val = ret
		self[save].tick = 0
		return ret
	end
	return self[save].val
end

function generic_ability:GetNumberValue(valType)
	local caster = self:GetCaster()
	-- if IsClient() then
	-- 	local count = collectgarbage("count")
	-- 	local modifierName = "modifier_"..valType:lower().."_"..self:GetAbilityClassName()
	-- 	if caster:HasModifier(modifierName) then
	-- 		local stackCount = caster:GetModifierStackCount(modifierName, caster)
	-- 		return stackCount
	-- 	end
	-- end

	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local curVal = abilityTable[valType]
	if type(curVal) == "string" then
		local values = {}
		for value in curVal:gmatch("[%w%.]+") do table.insert(values, value) end
		if values[self:GetLevel()] then
			curVal = values[self:GetLevel()]
		end
	end
	self.valType = curVal
	return tonumber(curVal)
end

function generic_ability:GetStringValue(valType)
	local caster = self:GetCaster()
	-- if IsClient() then
	-- 	if not caster:HasModifier("modifier_reload_"..self:GetAbilityClassName()) then
	-- 		if self.valType ~= nil then
	-- 			return self.valType
	-- 		end
	-- 	end
	-- end

	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end

	-- if IsClient() then
	-- 	self.valType = abilityTable[valType]
	-- end
	return abilityTable[valType]
end

function generic_ability:SetValues(valType, val)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	abilityTable[valType] = self:ReplaceRelativeString(val)
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:GetAttribute(name, level)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local attributeTable = abilityTable.attributes
	local curVal = FindAttribute(attributeTable, name)
	if type(curVal) == "string" then
		local values = {}
		for value in curVal:gmatch("[%w%.]+") do table.insert(values, value) end
		if values[level] then
			curVal = values[level]
		end
	end
	return curVal
end

function generic_ability:AddAttribute(name, text, val)
	local caster = self:GetCaster()
	self:RemoveAttribute(name)
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local newTable = {
		Name = name,
		Key = text,
		Val = val
	}
	table.insert(abilityTable.attributes, GetTableLength(abilityTable.attributes), newTable)
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:RemoveAttribute(name)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local attributeTable = abilityTable.attributes
	local function removeAttribute(table, attrName)
		for _,obj in pairs(table) do
			if obj.Name:lower() == attrName:lower() then
				obj = nil
			end
		end
		return table
	end
	abilityTable.attributes = removeAttribute(attributeTable, name)
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:ClearAttributes()
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	abilityTable.attributes = {}
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:GetRuneAttribute(name, runeName)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local runeTable = abilityTable.runeAttributes
	if not runeTable[runeName] then return 0 end

	return FindAttribute(runeTable[runeName], name)
end

function generic_ability:AddRuneAttribute(name, text, val, runeName)
	local caster = self:GetCaster()
	-- self:RemoveRuneAttribute(name, runeName)
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local runeTable = abilityTable.runeAttributes
	if not runeTable[runeName] then runeTable[runeName] = {} end

	local newTable = {
		Name = name,
		Key = text,
		Val = val
	}
	runeTable[runeName][tostring(GetTableLength(runeTable[runeName]))] = newTable

	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:RemoveRuneAttribute(name, runeName)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local runeTable = abilityTable.runeAttributes
	if not runeTable[runeName] then return 0 end

	local function removeAttribute(table, attrName)
		for _,obj in pairs(table) do
			if obj.Name:lower() == attrName:lower() then
				obj = nil
			end
		end
		return table
	end
	abilityTable.runeAttributes = removeAttribute(runeTable[runeName], name)
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:PrintAllSpecialRuneValues()
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local runeTable = abilityTable.runeAttributes

	print("\n<--- Print Rune Special Values --->\n")
	PrintTable(runeTable)
	print("\n<--- End --->")
end

function generic_ability:ClearRuneAttributes(runeName)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	if not runeName then
		abilityTable.runeAttributes = {}
	else
		if not abilityTable.runeAttributes then
			return
		end
		abilityTable.runeAttributes[runeName] = {}
	end
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:SetCurrentRunesInTable()
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	abilityTable.runes = self.runes
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()
	local targetType = self:GetAbilityTargetType()
	local targetTeam = self:GetAbilityTargetTeam()
	local targetFlags = self:GetAbilityTargetFlags()
	local spellImmunity = self:GetAbilitySpellImmunityType()

	if not DOTA_EXTRA_ENUMS then
		require('libs/extra_enums')
	end

	--manipulate the flags according to the set spell immunity
	if bit.band(spellImmunity, DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ALLIES_NO) ~= 0 then
		targetFlags = targetFlags + DOTA_UNIT_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
	end
	if bit.band(spellImmunity, DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ENEMIES_YES) ~= 0 then
		targetFlags = targetFlags + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end

	local team = caster:GetTeamNumber()
	local filter = UnitFilter(hTarget, targetTeam, targetType, targetFlags, team)

	return filter
end

function generic_ability:OnUpgrade()
	self:ReloadAbility()
	self:AddEventModifier()
end

function generic_ability:AddPassives(passives)
	local caster = self:GetCaster()
	for _,passive in pairs(passives) do
		if not caster:HasModifier(passive) then
			caster:AddNewModifier(caster, self, passive, nil)
		end
	end
end

function generic_ability:UpdateCastPoint()
	local castPoint = self:GetCastPoint()
	self:SetOverrideCastPoint(castPoint)
end

--=================================================================================================
--HIDDEN FUNCTIONS: EVENT DATA
--=================================================================================================

function generic_ability:OnProjectileHit(hTarget, vLocation)
	if hTarget then
		if self["OnProjectileHitUnit"] then return self:OnProjectileHitUnit(hTarget) end
	else
		if self["OnProjectileFinish"] then return self:OnProjectileFinish(vLocation) end
	end
	return false
end

-- Extra Data contains:
-- start, direction, speed, distance, width
function generic_ability:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
	if extraData then
		if extraData.startX and extraData.startY and extraData.startZ then
			local start = Vector(extraData.startX, extraData.startY, extraData.startZ)
			extraData.startX = nil
			extraData.startY = nil
			extraData.startZ = nil
			extraData.start = start
		end
		if extraData.directionX and extraData.directionY and extraData.directionZ then
			local direction = Vector(extraData.directionX, extraData.directionY, extraData.directionZ)
			extraData.directionX = nil
			extraData.directionY = nil
			extraData.directionZ = nil
			extraData.direction = direction
		end
		if extraData.targetID then
			extraData.target = EntIndexToHScript(extraData.targetID)
			extraData.targetID = nil
		end
		if extraData.sourceID then
			extraData.source = EntIndexToHScript(extraData.sourceID)
			extraData.sourceID = nil
		end
	end
	if hTarget then
		if self["OnProjectileHitUnitExtra"] then return self:OnProjectileHitUnitExtra(hTarget, extraData) end
	else
		if self["OnProjectileHitFinishExtra"] then return self:OnProjectileHitFinishExtra(vLocation, extraData) end
	end
	return false
end

function generic_ability:AddEventModifier()
	local modifierName = "modifier_base_events_"..self:GetAbilityClassName()
	local caster = self:GetCaster()
	if caster:HasModifier(modifierName) then
		return
	end
	caster:AddNewModifier(caster, self, modifierName, nil)
end

function generic_ability:AttackStartEvent(event)
	if not event.attacker == self:GetCaster() then return end
	if self["OnAttackStart"] then self:OnAttackStart(event) end
end

function generic_ability:AttackEvent(event)
	if not event.attacker == self:GetCaster() then return end
	if self["OnAttack"] then self:OnAttack(event) end
end

function generic_ability:AttackLandedEvent(event)
	if not event.attacker == self:GetCaster() then return end
	if self["OnAttackLanded"] then self:OnAttackLanded(event) end
end

function generic_ability:TakeDamageEvent(event)
	if event.unit == self:GetCaster() then
		if self["OnTakeDamage"] then self:OnTakeDamage(event) end
	elseif event.attacker == self:GetCaster() then
		if self["OnDealDamage"] then self:OnDealDamage(event) end
	end
end

function generic_ability:AttackedEvent(event)
	if not event.target == self:GetCaster() then return end
	if self["OnAttacked"] then self:OnAttacked(event) end
end

function generic_ability:DeathEvent(event)
	if not event.attacker == self:GetCaster() then return end
	if event.inflictor:GetName() == self:GetAbilityClassName() then
		if self["OnKilled"] then self:OnKilled(event) end
	else
		if self["OnDeath"] then self:OnDeath(event) end
	end
end

--=================================================================================================
--TABLE FUNCTIONS
--=================================================================================================

function GetTableLength(table)
	print("\nGet Table Length!\n")
	PrintTable(table)
	local index = 0
	for _,k in pairs(table) do
		index = index + 1
	end
	return index
end

function RemoveItemFromTable(tab, val)
	local newTab = {}
	local index = 0
	for _,v in pairs(tab) do
		if not v:GetName() ~= val:GetName() then
			newTab[index] = v
			index = index + 1
		end
	end
	return newTab
end

function IsEmpty(tab)
	if GetTableLength(tab) == 0 then
		return true
	end
	return false
end

function FindAttribute(table, attrName)
	for _,obj in pairs(table) do
		if obj.Name:lower() == attrName:lower() then
			return obj.Val
		end
	end
end