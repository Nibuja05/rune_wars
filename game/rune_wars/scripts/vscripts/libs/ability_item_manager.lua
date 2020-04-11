
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

	if itemName:find("ability_core") then
		local itemKVs = item:GetAbilityKeyValues()
		local damageType = itemKVs.SpecialDamageType
		if damageType == "SPECIAL_DAMAGE_TYPE_RANDOM" then
			itemTable.specialDamageType = 2^RandomInt(0, 5)
		else
			itemTable.specialDamageType = DOTA_EXTRA_ENUMS[damageType]
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


--==============================
-- Init the class
--==============================

if not ItemManager.init then
	ItemManager:Init()
end