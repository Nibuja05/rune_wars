
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

function generic_ability:ReloadAbility()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_reload_"..self:GetAbilityClassName(), {Duration = 1})

	print("Reload ... "..self:GetAbilityClassName())

	local modifier = caster:AddNewModifier(caster, self, "modifier_manacost_"..self:GetAbilityClassName(), nil)
	if self:GetNumberValue("manaCost") then
		modifier:SetStackCount(self:GetNumberValue("manaCost"))
	end
	modifier = caster:AddNewModifier(caster, self, "modifier_behavior_"..self:GetAbilityClassName(), nil)
	if self:GetNumberValue("behavior") then
		modifier:SetStackCount(self:GetNumberValue("behavior"))
	end
end

--=================================================================================================
--HIDDEN FUNCTIONS
--=================================================================================================

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
	if IsClient() then
		if not caster:HasModifier("modifier_reload_"..self:GetAbilityClassName()) then
			local modifierName = "modifier_"..valType:lower().."_"..self:GetAbilityClassName()
			if caster:HasModifier(modifierName) then
				local stackCount = caster:GetModifierStackCount(modifierName, caster)
				return stackCount
			end
		end
	end
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local curVal = abilityTable[valType]
	if type(curVal) == "string" then
		local values = {}
		for value in curVal:gmatch("%w+") do table.insert(values, value) end
		if values[self:GetLevel()] then
			curVal = values[self:GetLevel()]
		end
	end
	self.valType = curVal
	return tonumber(curVal)
end

function generic_ability:GetStringValue(valType)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityClassName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
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
		for value in curVal:gmatch("%w+") do table.insert(values, value) end
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
	local function GetTableLength(table)
		local index = 0
		for _,k in pairs(table) do
			index = index + 1
		end
		return index
	end
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

function generic_ability:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()
	local targetType = self:GetAbilityTargetType()
	local targetTeam = self:GetAbilityTargetTeam()
	local targetFlags = self:GetAbilityTargetFlags()
	local spellImmunity = self:GetAbilitySpellImmunityType()

	require('libs/extra_enums')
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

-- function generic_ability:CheckReloaded()
-- 	local caster = self:GetCaster()
-- 	if caster:HasModifier("modifier_reload_generic_ability_q") then

-- 	end
-- end

--=================================================================================================
--TABLE FUNCTIONS
--=================================================================================================

function GetTableLength(table)
	local index = 0
	for _,k in pairs(table) do
		index = index + 1
	end
	return index
end

function RemoveItemFromTable(tab, val)
	print("Removing from table!")
	PrintTable(tab)
	local newTab = {}
	local index = 0
	for _,v in pairs(tab) do
		if not v:GetName() ~= val:GetName() then
			newTab[index] = v
			index = index + 1
		end
	end
	PrintTable(newTab)
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