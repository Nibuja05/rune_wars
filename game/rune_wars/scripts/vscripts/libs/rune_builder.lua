
DOTA_ITEM_STASH_MAX = 15;

if not RuneBuilder then
	RuneBuilder = class({})
end

function RuneBuilder:Init()
	self.started = true
	print("[RB] Initializing Rune Builder...")
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(RuneBuilder, 'OnNPCSpawned'), self)
	CustomGameEventManager:RegisterListener("delete_inv_item", Dynamic_Wrap(RuneBuilder, "DeleteInventoryItem"))
	CustomGameEventManager:RegisterListener("add_inv_item", Dynamic_Wrap(RuneBuilder, "AddInventoryItem"))
	CustomGameEventManager:RegisterListener("update_runes", Dynamic_Wrap(RuneBuilder, "OnUpdateRunes"))
end

function RuneBuilder:OnNPCSpawned(event)
	local npc = EntIndexToHScript(event.entindex)
	if npc:IsRealHero() and npc.bFirstSpawned == nil then
		npc.bFirstSpawned = true
		local playerID = npc:GetPlayerID()
		local player = PlayerResource:GetPlayer(playerID)
	    if player then
	    	print("[RB] Init HUD for player!")
	    	CustomGameEventManager:Send_ServerToPlayer(player, "init_tooltips", {})
			CustomGameEventManager:Send_ServerToPlayer(player, "init_stat_tooltips", {})
	        CustomGameEventManager:Send_ServerToPlayer(player, "init_rune_slots", {})
	        CustomGameEventManager:Send_ServerToPlayer(player, "init_item_tooltips", {})
	        CustomNetTables:SetTableValue("rune_slots", tostring(npc:entindex()), {})
	    end
	end
end

function RuneBuilder:SetRuneDisabled(ability, index, markType)
	-- print("[RB] Set a rune disabled!")
	local className = ability:GetAbilityClassName()
	local suffix = className:gsub("generic_ability", "")
	local slotName = "rune"..index.."_slot"..suffix

	local caster = ability:GetCaster()
	local playerID = caster:GetPlayerID()
	local player = PlayerResource:GetPlayer(playerID)
	if not markType then markType = "disabled" end
	CustomGameEventManager:Send_ServerToPlayer(player, "mark_rune_slot", {slotName = slotName, markType = markType})
end

function RuneBuilder:DeleteInventoryItem(event)
	local caster = PlayerResource:GetSelectedHeroEntity(event.playerID)
	local item = caster:GetItemInSlot(event.itemSlot)
	caster:TakeItem(item)
end

function RuneBuilder:AddInventoryItem(event)
	local caster = PlayerResource:GetSelectedHeroEntity(event.playerID)
	local item = EntIndexToHScript(event.itemID)
	caster:AddItem(item)
	local tempSlot = RuneBuilder:FindItemSlot(caster, item)
	if tempSlot >= 0 and event.itemSlot >= 0 then
		caster:SwapItems(tempSlot, event.itemSlot)
	end
end

function RuneBuilder:FindItemSlot(unit, testItem)
	for i=0, 15 do
		local item = unit:GetItemInSlot(i)
		if item then
			if item:entindex() == testItem:entindex() then
				return i
			end
		end
	end
	return -1
end

function RuneBuilder:OnUpdateRunes(event)
	local caster = PlayerResource:GetSelectedHeroEntity(event.playerID)
	local netTable = CustomNetTables:GetTableValue("rune_slots", tostring(caster:entindex()))
	local runeTable = event.runeTable
	if not netTable.abilityQ then
		netTable.abilityQ = {}
		netTable.abilityW = {}
		netTable.abilityE = {}
	end
	netTable.abilityQ.core = "-1";
	netTable.abilityQ.runes = {};
	netTable.abilityW.core = "-1";
	netTable.abilityW.runes = {};
	netTable.abilityE.core = "-1";
	netTable.abilityE.runes = {};

	for key,val in pairs(runeTable) do
		local slotName = RuneBuilder:GetRuneSlotFromSlotNumber(key)
		local tableName = ""
		if slotName:find("_q") then
			tableName = "abilityQ"
		elseif slotName:find("_w") then
			tableName = "abilityW"
		elseif slotName:find("_e") then
			tableName = "abilityE"
		end
		if slotName:find("core") then
			netTable[tableName].core = val.Id
		elseif slotName:find("rune") then
			local find = slotName:find("%d")
			local index = slotName:sub(find, find)
			netTable[tableName].runes[index] = val.Id
		end
	end
	CustomNetTables:SetTableValue("rune_slots", tostring(caster:entindex()), netTable)
	AbilityAspects:BuildCoreAbility(caster)
end

function RuneBuilder:GetRuneSlotFromSlotNumber(slot)
	slot = tonumber(slot)
	if slot == 15 then
		return "core_slot_q"
	elseif slot == 16 then
		return "rune1_slot_q"
	elseif slot == 17 then
		return "rune2_slot_q"
	elseif slot == 18 then
		return "rune3_slot_q"
	elseif slot == 19 then
		return "core_slot_w"
	elseif slot == 20 then
		return "rune1_slot_w"
	elseif slot == 21 then
		return "rune2_slot_w"
	elseif slot == 22 then
		return "rune3_slot_w"
	elseif slot == 23 then
		return "core_slot_e"
	elseif slot == 24 then
		return "rune1_slot_e"
	elseif slot == 25 then
		return "rune2_slot_e"
	elseif slot == 26 then
		return "rune3_slot_e"
	end
	return ""
end

function GetTableLength(table)
	local index = 0
	for _,k in pairs(table) do
		index = index + 1
	end
	return index
end

-- init the helper lib
if not RuneBuilder.started then
	RuneBuilder:Init()
end