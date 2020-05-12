
if not ItemManager then
	ItemManager = class({})
end

function ItemManager:Init()
	print("[IM] Initializing Item Manager...")
	-- ListenToGameEvent('item_purchased ', Dynamic_Wrap(self, 'OnInventoryChange'), self)
	-- GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(self, "OnItemAddedToInventory"), self)
end

function ItemManager:OnItemAddedToInventory(event)
	print("[IM] Inventory Changed!")
	
	local itemID = event.item_entindex_const
	local item = EntIndexToHScript(itemID)
	local itemName = item:GetName()
	if not itemName:find("ability_core") and not itemName:find("ability_rune") then return true end
	
	local netTable = CustomNetTables:GetTableValue("item_extras", tostring(itemID))
	if not netTable then
		self:CreateNewValuesForItem(item)
	end

	return true
end

function ItemManager:CreateNewValuesForItem(item)
	print("[IM] Creating new values for "..item:GetName())
	local itemID = item:entindex()
	local itemName = item:GetName()

	local itemTable = {}

	print("?")

	if itemName:find("ability_core") then
		print("core!")
		local itemKVs = item:GetAbilityKeyValues()
		local damageType = itemKVs.SpecialDamageType
		if damageType == "SPECIAL_DAMAGE_TYPE_RANDOM" then
			itemTable.specialDamageType = 2^RandomInt(0, 5)
		else
			itemTable.specialDamageType = DOTA_EXTRA_ENUMS[damageType]
		end
		local specialTypes = itemKVs.SpecialAbilityType
		specialTypesTable = self:ExtractKeys(specialTypes)
		itemTable.specialKeys = specialTypesTable
	else
		print("rune!")
		local itemKVs = item:GetAbilityKeyValues()
		local requirements = itemKVs.KeyRequirements
		if requirements then
			local requirementTable = self:ExtractKeys(requirements)
			itemTable.keyRequirements = requirementTable
		else
			itemTable.keyRequirements = {}
		end

		local additions = itemKVs.KeyAddition
		if additions then
			local additionTable = self:ExtractKeys(additions)
			itemTable.keyAdditions = additionTable
		else
			itemTable.keyAdditions = {}
		end
	end

	itemTable.rarity = self:ExtractRarity(itemName)
	
	CustomNetTables:SetTableValue("item_extras", tostring(itemID), itemTable)
end

function ItemManager:ExtractRarity(name)
	local itemType = "ability_rune"
	if name:find("ability_core") then itemType = "ability_core" end
	local index = name:find(itemType) + (itemType):len() + 1
	local temp = name:sub(index)
	local endIndex = temp:find("_") - 1
	local rarity = temp:sub(0, endIndex)
	return rarity
end

function ItemManager:ExtractKeys(keyString)
	local keys = StringSplit(keyString, "|")
	local newKeys = {}
	for _,key in pairs(keys) do
		local newKey = key:match("[%a_]+")
		table.insert(newKeys, newKey)
	end
	return newKeys
end

--==============================
-- Other functions
--==============================

function GetTableLength(table)
	local index = 0
	for _,k in pairs(table) do
		index = index + 1
	end
	return index
end

function StringSplit(str, sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   str:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end


--==============================
-- Init the class
--==============================

if not ItemManager.init then
	ItemManager:Init()
end