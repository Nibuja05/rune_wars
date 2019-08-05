
if not AbilityAspects then
	AbilityAspects = class({})
end

function AbilityAspects:BuildCoreAbility(caster)

	local inv = self:GetInventory(caster, "backpack")
	local cores = {}
	for k,v in pairs(inv) do
		if v:GetName():find("item_ability_core") then
			if not core then
				cores[k % 3] = v
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
		for _,val in pairs(funcs) do
			GenericAbility:AddFunction(ability, val, spell[val])
		end

		ability:ReloadAbility()

	end

	local playerID = caster:GetPlayerID()
	local player = PlayerResource:GetPlayer(playerID)
	CustomGameEventManager:Send_ServerToPlayer(player, "init_tooltips", {})
	CustomGameEventManager:Send_ServerToPlayer(player, "init_stat_tooltips", {})
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