
if not AbilityAspects then
	AbilityAspects = class({})
end

function AbilityAspects:BuildCoreAbility(caster)

	local inv = self:GetInventory(caster, "backpack")
	local cores = {}
	local runes = {}
	local runeTable = CustomNetTables:GetTableValue("rune_slots", tostring(caster:entindex()))
	for key,val in pairs(runeTable) do
		local coreIndex = -1
		if key == "abilityQ" then
			coreIndex = 0
		elseif key == "abilityW" then
			coreIndex = 1
		elseif key == "abilityE" then
			coreIndex = 2
		end
		if coreIndex >= 0 and tonumber(val.core) >= 0 then
			local core = EntIndexToHScript(tonumber(val.core))
			if core:GetName():find("item_ability_core") then
				cores[coreIndex] = core
			end
			local runeCount = self:GetTableLength(val.runes)
			if runeCount > 0 then
				runes[coreIndex] = {}
				for k,v in pairs(val.runes) do
					runes[coreIndex][k] = EntIndexToHScript(tonumber(v))
				end
			end
		end
	end

	for index = 0, 2 do
		local ability = GenericAbility:GetGenericAbilityByIndex(caster, index)
		GenericAbility:ResetAbility(caster, ability, index)
		ability:ReloadAbility()
	end
	for index, core in pairs(cores) do
		-- Filter uncomplete cores:
		if not core then
			print("No Core! Aborting...")
			return
		end
		local coreKVs = core:GetAbilityKeyValues()
		if not coreKVs.SpecialAbilityType then
			print("No Special Ability Type set! Aborting...")
			return
		end
		if not coreKVs.SpecialDamageType then
			print("No Special Damage Type set! Aborting...")
			return
		end
		if not coreKVs.SpecialSpellName then
			print("No Spell Name set! Aborting...")
			return
		end

		local ability = GenericAbility:GetGenericAbilityByIndex(caster, index)
		if not ability then return end

		local spellName = coreKVs.SpecialSpellName
		assert(require("cores/"..spellName..""), "No valid spell found for "..spellName)
		local spell = _G[spellName]
		local funcs = spell:GetFunctions()
		local abilityTable = spell:GetAbilityTable()
		abilityTable.Specialvalues = self:ExtractAbilitySpecials(coreKVs)
		abilityTable.Specialdamagetype = DOTA_EXTRA_ENUMS[coreKVs.SpecialDamageType]
		GenericAbility:LoadAbilityFromTable(ability, abilityTable)
		AbilityAspects:AddAbilitySpecialKeys(ability, coreKVs.SpecialAbilityType)

		GenericAbility:ClearCustomFunctions(ability)
		GenericAbility:AddFunction(ability, "GetReferenceItem", spell["GetReferenceItem"])
		for _,val in pairs(funcs) do
			GenericAbility:AddFunction(ability, val, spell[val])
		end

		ability:SetCurrentRunes({})
		ability:ClearAllSpecialRuneValues()
		-- ability:PrintAllSpecialRuneValues()
		local spellRunes = runes[index]
		if spellRunes then
			for k,v in pairs(spellRunes) do
				self:AddRune(ability, k, v)
			end
		end

		ability:ReloadAbility()
	end
end

function AbilityAspects:AddRune(ability, index, item)
	local runeName = item:GetName()
	local curRunes = ability:GetCurrentRunes()
	if self:FindValueInTable(curRunes, runeName) then return end

	local runeKVs = item:GetAbilityKeyValues()
	local requirements = runeKVs.KeyRequirements
	if not ability:HasSpecialAbilityKey(DOTA_EXTRA_ENUMS[requirements]) then
		RuneBuilder:SetRuneDisabled(ability, index)
		return 
	end

	curRunes[index] = runeName
	-- ability:ClearAllSpecialRuneValues(runeName)
	ability:SetCurrentRunes(curRunes)
	local runeShortName = runeKVs.RuneName
	assert(require("runes/"..runeShortName..""), "No valid rune found for "..runeShortName)
	local rune = _G[runeShortName]

	local funcs = rune:GetAdditionalFunctions()
	for _,func in pairs(funcs) do
		GenericAbility:AddFunction(ability, func, rune[func])
	end

	local specials = self:ExtractAbilitySpecials(runeKVs)
	for _,special in pairs(specials) do
		ability:AddSpecialRuneValue(special.name, special.text, special.val, runeShortName)
	end

	-- local description = self:FindItemTooltip(item:GetName(), "Description")
	-- print(description)
end

function AbilityAspects:AddAbilitySpecialKeys(ability, specials)
	local keys = 0
	for key in specials:gmatch("[%u_]+") do
		local value = DOTA_EXTRA_ENUMS[key]
		if value then
			keys = keys + value
		end
	end
	ability:SetAbilitySpecialKeys(keys)
end

function AbilityAspects:ExtractAbilitySpecials(KVTable)
	local specials = {}
	if KVTable["AbilitySpecial"] then
		for _,special in pairs(KVTable["AbilitySpecial"]) do
			local tempTable = {}
			for key,val in pairs(special) do
				if key ~= "var_type" then
					tempTable.name = key
					tempTable.val = val
					tempTable.text = key
					tempTable.text = tempTable.text:gsub("_", " "):upper()
				end
			end
			table.insert(specials, tempTable)
		end
	end
	return specials
end

-- function AbilityAspects:FindItemTooltip(itemName, tooltipType)
-- 	local file = "resource/addon_english.txt"
-- 	local kvs = LoadKeyValues(file)
-- 	local tooltipNameBase = "DOTA_Tooltip_ability_"..itemName
-- 	local tooltipName = tooltipNameBase.."_"..tooltipType
-- 	if tooltipType == "Name" then
-- 		tooltipName = tooltipNameBase
-- 	end
-- 	print(tooltipName)
-- 	return kvs.Tokens[tooltipName]
-- end

--INVTYPE:
--all: completle inventory (also no arg)
--basic: basic 6 inv slots only
--stash: stash only
--backpack: backpack only
--combined: backpack + basic
function AbilityAspects:GetInventory(unit, invType)
	local invTable = {}
	local startIndex = 0
	local endIndex = 13
	if invType == "basic" then
		endIndex = 5
	elseif invType == "stash" then
		startIndex = 9
	elseif invType == "backpack" then
		startIndex = 6
		endIndex = 8
	elseif invType == "combined" then
		endIndex = 8
	end
	for i=startIndex, endIndex do
		local item = unit:GetItemInSlot(i)
		if item then
			table.insert(invTable, i, item)
		end
	end
	return invTable
end

function AbilityAspects:GetTableLength(table)
	local index = 0
	for _,k in pairs(table) do
		index = index + 1
	end
	return index
end

function AbilityAspects:FindValueInTable(tab, value)
	for _,val in pairs(tab) do
		if val == value then
			return true
		end
	end
	return false
end