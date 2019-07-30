
DYNAMIC_EVENTS = false

if not AbilityCores then
	AbilityCores = class({})
end

function AbilityCores:Init()
	print("[AS] Initializing...")
	if DYNAMIC_EVENTS then
		print("[AS] Reloading events...")
		ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(self, 'OnItemPickedUp'), self)
	else
		ListenToGameEvent('dota_item_picked_up', self.OnItemPickedUp, self)
	end
end

function AbilityCores:OnItemPickedUp(event)
	local name = event.itemname
	local player = PlayerResource:GetPlayer(event.PlayerID)
	local item = EntIndexToHScript(event.ItemEntityIndex)
	local hero = EntIndexToHScript(event.HeroEntityIndex)

	-- print("Picked up item:"..name)
	if name:find("item_enchanted_ore") then
		-- self:OnEnchantedOrePickedUp(name, player, item, hero)
	end
end

function AbilityCores:CheckInventory(hero)
	local item = EntIndexToHScript(event.entityIndex)
	print(item)
	DeepPrintTable(event)
end

function AbilityCores:OnEnchantedOrePickedUp(name, player, item, hero)
	local item = EntIndexToHScript(event.entityIndex)
	print(item)
	self:AddAbilityStone(name, hero)
end

function AbilityCores:AddEnchantedOre(name, hero)
	local netTable = CustomNetTables:GetTableValue("ability_cores", tostring(hero:entindex()))
	--init the tables, if there aren't any for this hero
	if not netTable then
		netTable = {}
	end
	if not netTable.ores then
		netTable.ores = {}
	end
	table.insert(netTable.stones, GetTableLength(netTable.stones), name)
	DeepPrintTable(netTable)
	CustomNetTables:SetTableValue("ability_stones", tostring(hero:entindex()), netTable)
end

function AbilityCores:AddAbilityCore(name, hero)
	local netTable = CustomNetTables:GetTableValue("ability_cores", tostring(hero:entindex()))
	--init the tables, if there aren't any for this hero
	if not netTable then
		netTable = {}
	end
	if not netTable.cores then
		netTable.cores = {}
	end
	table.insert(netTable.stones, GetTableLength(netTable.stones), name)
	DeepPrintTable(netTable)
	CustomNetTables:SetTableValue("ability_stones", tostring(hero:entindex()), netTable)
end

function AbilityCores:OnItemDragStart(event)
	DeepPrintTable(event)
end

function AbilityCores:OnItemDragEnd(event)
	DeepPrintTable(event)
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

if not AbilityCores.init then
	AbilityCores:Init()
end