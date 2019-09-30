
if not GenericAbility then
	GenericAbility = class({})
end

function GenericAbility:Init()
	self.started = true
	print("[GA] Initializing General Ability Manager...")
end

function GenericAbility:InitHero(hero)
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(hero:entindex()))
	if not netTable then
		netTable = {}
	else
		return
	end
	print("[GA] Initializing for hero "..hero:GetUnitName())
	if not netTable.nameLookup then
		netTable.nameLookup = {}
	end
	local nameTable = netTable.nameLookup
	if not netTable.abilities then
		netTable.abilities = {}
	end

	for i=0, 8 do
		local ability = hero:GetAbilityByIndex(i)
		if ability then
			local abilityName = ability:GetAbilityName()
			if abilityName:find("generic_ability") then
				ability.name = abilityName
				netTable.nameLookup[abilityName] = i

				local abilityTable = {}
				abilityTable.behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
				abilityTable.castRange = "0"
				abilityTable.cooldown = "0"
				abilityTable.manaCost = "0"
				abilityTable.aoeRadius = "0"
				abilityTable.duration = "0"
				abilityTable.castPoint = "0.3"

				abilityTable.name = abilityName
				abilityTable.title = "Variable Ability"
				abilityTable.description = ""
				abilityTable.lore = ""
				abilityTable.texture = "rubick_empty1"
				abilityTable.targetType = DOTA_UNIT_TARGET_NONE
				abilityTable.targetTeam = DOTA_UNIT_TARGET_TEAM_NONE
				abilityTable.targetFlags = DOTA_UNIT_TARGET_FLAG_NONE
				abilityTable.damageType = DAMAGE_TYPE_NONE
				abilityTable.specialDamageType = DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_NONE
				abilityTable.dispelType = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE
				abilityTable.spellImmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE
				abilityTable.attributes = {}

				netTable.abilities[i] = abilityTable
				ability:ReloadAbility()
			end
		end
	end

	netTable.nameLookup = nameTable
	CustomNetTables:SetTableValue("generic_ability", tostring(hero:entindex()), netTable)
	print("[GA] Initialized Hero!")

	Timers:CreateTimer({
		useGameTime = false,
		endTime = 5,
		callback = function()
			local playerID = hero:GetPlayerID()
			local player = PlayerResource:GetPlayer(playerID)
			CustomGameEventManager:Send_ServerToPlayer(player, "init_tooltips", {})
		end
	})
end

function GenericAbility:ResetAbility(hero, ability, index)
	-- print("Reset..."..tostring(index))
	local netTable = CustomNetTables:GetTableValue("generic_ability", tostring(hero:entindex()))
	local abilityName = ability:GetAbilityName()

	self:RemoveAllPassives(hero, ability)

	local abilityTable = {}
	abilityTable.behavior = DOTA_ABILITY_BEHAVIOR_PASSIVE
	abilityTable.castRange = "0"
	abilityTable.cooldown = "0"
	abilityTable.manaCost = "0"
	abilityTable.aoeRadius = "0"
	abilityTable.duration = "0"
	abilityTable.castPoint = "0.3"

	abilityTable.name = abilityName
	abilityTable.title = "Variable Ability"
	abilityTable.description = ""
	abilityTable.lore = ""
	abilityTable.texture = "rubick_empty1"
	abilityTable.targetType = DOTA_UNIT_TARGET_NONE
	abilityTable.targetTeam = DOTA_UNIT_TARGET_TEAM_NONE
	abilityTable.targetFlags = DOTA_UNIT_TARGET_FLAG_NONE
	abilityTable.damageType = DAMAGE_TYPE_NONE
	abilityTable.specialDamageType = DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_NONE
	abilityTable.dispelType = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE
	abilityTable.spellImmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE
	abilityTable.attributes = {}
	abilityTable.runeAttributes = {}

	ability:SetCurrentRunes({})

	netTable.abilities[tostring(index)] = abilityTable
	CustomNetTables:SetTableValue("generic_ability", tostring(hero:entindex()), netTable)
end

function GenericAbility:RemoveAllPassives(hero, ability)
	local modifiers = hero:FindAllModifiers()
	for _,modifier in pairs(modifiers) do
		-- if modifier:GetAbility() == ability then
		local name = modifier:GetName()
		if name:find("passive") then
			hero:RemoveModifierByName(name)
		end
		-- end
	end
end

function GenericAbility:LoadAbilityFromTable(ability, abilityTable)
	if abilityTable.Specialvalues then
		ability:ClearAllSpecialValues()
		for _,val in pairs(abilityTable.Specialvalues) do
			if not val.name then
				print("Wrong specialvalues format!")
			elseif not val.text then
				print("Wrong specialvalues format!")
			elseif not val.val then
				print("Wrong specialvalues format!")
			else
				ability:AddSpecialValue(val.name, val.text, val.val)
			end
		end
	end
	if abilityTable.Behavior then ability:SetBehavior(abilityTable.Behavior) end
	if abilityTable.Castrange then ability:SetCastRange(abilityTable.Castrange) end
	if abilityTable.Cooldown then ability:SetCooldown(abilityTable.Cooldown) end
	if abilityTable.Manacost then ability:SetManaCost(abilityTable.Manacost) end
	if abilityTable.Aoeradius then ability:SetAOERadius(abilityTable.Aoeradius) end
	if abilityTable.Duration then ability:SetAbilityDuration(abilityTable.Duration) end
	if abilityTable.Castpoint then ability:SetCastPoint(abilityTable.Castpoint) end
	if abilityTable.Texture then ability:SetAbilityTextureName(abilityTable.Texture) end
	if abilityTable.Targettype then ability:SetAbilityTargetType(abilityTable.Targettype) end
	if abilityTable.Targetflags then ability:SetAbilityTargetFlags(abilityTable.Targetflags) end
	if abilityTable.Targetteam then ability:SetAbilityTargetTeam(abilityTable.Targetteam) end
	if abilityTable.Damagetype then ability:SetAbilityDamageType(abilityTable.Damagetype) end
	if abilityTable.Specialdamagetype then ability:SetAbilitySpecialDamageType(abilityTable.Specialdamagetype) end
	if abilityTable.Spellimmunity then ability:SetAbilitySpellImmunityType(abilityTable.Spellimmunity) end
	if abilityTable.Dispel then ability:SetAbilityDispelType(abilityTable.Dispel) end
	if abilityTable.Title then ability:SetAbilityTitle(abilityTable.Title) end
	if abilityTable.Description then ability:SetAbilityDescription(abilityTable.Description) end
	if abilityTable.Lore then ability:SetAbilityLore(abilityTable.Lore) end
end

function GenericAbility:GetAllGenericAbilites(unit)
	local abilityTable = {}
	for i=0, 8 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			local abilityName = ability:GetAbilityName()
			if abilityName:find("generic_ability") then
				table.insert(abilityTable, ability)
			end
		end
	end
	return abilityTable
end

function GenericAbility:GetGenericAbilityByIndex(unit, index)
	local ability = unit:GetAbilityByIndex(index)
	if ability then
		local abilityName = ability:GetAbilityName()
		if not abilityName:find("generic_ability") then
			return nil
		end
	end
	return ability
end

function GenericAbility:AddFunction(ability, funcName, func, itemName)
	-- print("Adding the function "..ability:GetAbilityName()..":"..funcName.."() for ")
	if not ability.funcs then
		ability.funcs = {}
	end
	if funcName == "GetReferenceItem" then
		ability[funcName] = func
		return
	end
	if not ability[funcName] or not ability.funcs[funcName] then
		ability.funcs[funcName] = {}

		local function ExecuteFunctions(self, funcName, ...)
			-- print("Exec "..funcName.."()...")
			local finalRet
			for _,func in pairs(self.funcs[funcName]) do
				local ret = func(self, select(1, ...))
				if ret ~= nil then
					finalRet = ret
				end
			end
			if finalRet ~= nil then
				-- print("Return: "..tostring(finalRet))
			end
			return finalRet
		end
		ability[funcName] = function(self, ...) return ExecuteFunctions(self, funcName, ...) end
	end
	if not itemName then
		itemName = ability:GetReferenceItem()
	end
	ability.funcs[funcName][itemName] = func
	-- table.insert(ability.funcs[funcName], func)
end

function GenericAbility:AddFunctionOverwrite(ability, funcName, func)
	-- print("Adding the function "..ability:GetAbilityName()..":"..funcName.."() <- OVERWRITE")
	if not ability.funcs then
		ability.funcs = {}
	end
	ability[funcName] = nil
	ability.funcs[funcName] = nil
	self:AddFunction(ability, funcName, func)
end

function GenericAbility:RemoveFunction(ability, funcName, itemName)
	if not ability.funcs then
		return
	end
	if not ability.funcs[funcName] then
		return
	end
	if not itemName then
		itemName = ability:GetReferenceItem()
	end
	for key, val in pairs(ability.funcs[funcName]) do
		print("[GA] "..key..", "..itemName)
		if key == itemName then
			ability.funcs[funcName][key] = nil
			print("[GA] Return!")
			return
		end
	end
end

function GenericAbility:ClearCustomFunctions(ability)
	-- print("Reset Custom Functions!")
	if ability.funcs then
		for key,_ in pairs(ability.funcs) do
			ability[key] = nil
		end
		ability.funcs = nil
	end
end

function GenericAbility:AddNewGenericAbility(unit, index, args)
	unit:AddAbility("generic_ability_q")
end

function GenericAbility:GetStringLocalization(token)

end

local charset = {}  do -- [0-9a-zA-Z]
	for c = 48, 57  do table.insert(charset, string.char(c)) end
	for c = 65, 90  do table.insert(charset, string.char(c)) end
	for c = 97, 122 do table.insert(charset, string.char(c)) end
end

function randomString(length)
	if not length or length <= 0 then return '' end
	return randomString(length - 1) .. charset[RandomInt(1, #charset)]
end

function randomizeString(str)
	local newString = randomString(str:len())
	for i=0,str:len() do
		local char = str[i]
		if char == " " then
			newString[i] = " "
		end
	end
	return newString
end

-- init the helper lib
if not GenericAbility.started then
	GenericAbility:Init()
end