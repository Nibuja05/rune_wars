
generic_ability_q = class({})

--=================================================================================================
--PUBLIC FUNCTIONS
--=================================================================================================

function generic_ability_q:GetSpecialValueFor(name)
	return tonumber(self:GetAttribute(name, self:GetLevel()))
end

function generic_ability_q:GetLevelSpecialValueFor(name, level)
	return tonumber(self:GetAttribute(name, level))
end

function generic_ability_q:AddSpecialValue(name, text, val)
	self:AddAttribute(name, text, val)
end

function generic_ability_q:RemoveSpecialValue(name)
	self:RemoveAttribute(name)
end

function generic_ability_q:ClearAllSpecialValues()
	self:ClearAttributes()
end

function generic_ability_q:GetBehavior()
	local val
	if IsClient() then
		val = self:LimitFunctionCall(function(self, valType) return self:GetNumberValue(valType) end, 200, "behavior", "behavior")
	else
		val = self:GetNumberValue("behavior")
	end
	return val
end

function generic_ability_q:SetBehavior(behavior)
	self:SetValues("behavior", behavior)
end

function generic_ability_q:GetCastRange(vLocation, hTarget)
	return self:GetNumberValue("castRange")
end

function generic_ability_q:SetCastRange(castRange)
	self:SetValues("castRange", castRange)
end

function generic_ability_q:GetCooldown(level)
	return self:GetNumberValue("cooldown")
end

function generic_ability_q:SetCooldown(cooldown)
	self:SetValues("cooldown", cooldown)
end

function generic_ability_q:GetManaCost(level)
	local val
	if IsClient() then
		val = self:LimitFunctionCall(function(self, valType) return self:GetNumberValue(valType) end, 50, "manaCost", "manaCost")
	else
		val = self:GetNumberValue("manaCost")
	end
	return val
end

function generic_ability_q:SetManaCost(manaCost)
	self:SetValues("manaCost", manaCost)
end

function generic_ability_q:GetAbilityTextureName()
	return self:GetStringValue("texture")
end

function generic_ability_q:SetAbilityTextureName(texture)
	self:SetValues("texture", texture)
end

function generic_ability_q:GetAbilityTargetType()
	return self:GetNumberValue("targetType")
end

function generic_ability_q:SetAbilityTargetType(targetType)
	self:SetValues("targetType", targetType)
end

function generic_ability_q:GetAbilityTargetFlags()
	return self:GetNumberValue("targetFlags")
end

function generic_ability_q:SetAbilityTargetFlags(targetFlags)
	self:SetValues("targetFlags", targetFlags)
end

function generic_ability_q:GetAbilityTargetTeam()
	return self:GetNumberValue("targetTeam")
end

function generic_ability_q:SetAbilityTargetTeam(targetTeam)
	self:SetValues("targetTeam", targetTeam)
end

function generic_ability_q:GetAbilityDamageType()
	return self:GetNumberValue("damageType")
end

function generic_ability_q:SetAbilityDamageType(damageType)
	self:SetValues("damageType", damageType)
end

function generic_ability_q:GetAbilitySpellImmunityType()
	return self:GetNumberValue("spellImmunity")
end

function generic_ability_q:SetAbilitySpellImmunityType(spellImmunity)
	self:SetValues("spellImmunity", spellImmunity)
end

function generic_ability_q:GetAbilityDispelType()
	return self:GetNumberValue("dispelType")
end

function generic_ability_q:SetAbilityDispelType(dispelType)
	self:SetValues("dispelType", dispelType)
end

function generic_ability_q:GetAbilityDescription()
	return self:GetStringValue("description")
end

function generic_ability_q:SetAbilityDescription(description)
	self:SetValues("description", description)
end

function generic_ability_q:GetAbilityLore()
	return self:GetStringValue("lore")
end

function generic_ability_q:SetAbilityLore(lore)
	self:SetValues("lore", lore)
end

function generic_ability_q:GetAbilityTitle()
	return self:GetStringValue("title")
end

function generic_ability_q:SetAbilityTitle(title)
	self:SetValues("title", title)
end

function generic_ability_q:OnProjectileHit(target, loc)
	local caster = self:GetCaster()
	if target then
		print(self:GetSpecialValueFor("damage"))
		print(self:GetAbilityDamageType())
		local damageTable = {
			attacker = caster,
			victim = target,
			ability = self,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType(),
		}
		ApplyDamage(damageTable)
	end
	return true
end


--=================================================================================================
--HIDDEN FUNCTIONS
--=================================================================================================

function generic_ability_q:LimitFunctionCall(func, cycle, save, ...)
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

function generic_ability_q:GetNumberValue(valType)
	-- print("Get Value of "..valType)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup["generic_ability_q"]
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
	return tonumber(curVal)
end

function generic_ability_q:GetStringValue(valType)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup["generic_ability_q"]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	return abilityTable[valType]
end

function generic_ability_q:SetValues(valType, val)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup[self:GetAbilityName()]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	abilityTable[valType] = val
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability_q:GetAttribute(name, level)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup["generic_ability_q"]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	local attributeTable = abilityTable.attributes
	local function findAttribute(table, attrName)
		for _,obj in pairs(table) do
			if obj.Name:lower() == attrName:lower() then
				return obj.Val
			end
		end
	end
	local curVal = findAttribute(attributeTable, name)
	if type(curVal) == "string" then
		local values = {}
		for value in curVal:gmatch("%w+") do table.insert(values, value) end
		if values[level] then
			curVal = values[level]
		end
	end
	return curVal
end

function generic_ability_q:AddAttribute(name, text, val)
	local caster = self:GetCaster()
	self:RemoveAttribute(name)
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup["generic_ability_q"]
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

function generic_ability_q:RemoveAttribute(name)
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup["generic_ability_q"]
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

function generic_ability_q:ClearAttributes()
	local caster = self:GetCaster()
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(caster:entindex()))
	if not netTable then return 0 end
	local abilityIndex = netTable.nameLookup["generic_ability_q"]
	if not abilityIndex then return 0 end
	local abilityTable = netTable.abilities[tostring(abilityIndex)]
	if not abilityTable then return 0 end
	abilityTable.attributes = {}
	netTable.abilities[tostring(abilityIndex)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(caster:entindex()), netTable)
end

function generic_ability_q:CastFilterResultTarget(hTarget)
	local caster = self:GetCaster()
	local targetType = self:GetAbilityTargetType()
	local targetTeam = self:GetAbilityTargetTeam()
	local targetFlags = self:GetAbilityTargetFlags()
	local spellImmunity = self:GetAbilitySpellImmunityType()

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
