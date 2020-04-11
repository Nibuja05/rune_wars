
LinkLuaModifier("modifier_creep_death", "libs/creep_manager.lua", LUA_MODIFIER_MOTION_NONE)

if not CreepManager then
	CreepManager = class({})
end

ListenToGameEvent("game_rules_state_change", function()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		CreepManager:Init()
	end
end, nil)

function CreepManager:Init()
	self.started = true
	print("[CM] Initializing CreepManager...")
	ListenToGameEvent('npc_spawned ', Dynamic_Wrap(self, 'OnNPCSpawned'), self)
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 20)
	self.startTime = nil
end

function CreepManager:OnNPCSpawned(event)
	print("[CM] Something spawned!!")
end

function CreepManager:OnThink(event)
	-- if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local time = GameRules:GetGameTime()
		if not self.startTime then self.startTime = time end
		local interval = 30
		if (time - self.startTime) % interval < 1 then
			print("[CM] Spawn Neutrals!")
			self:SpawnAllCreeps()
		end
	-- elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	if not self.startTime then return 0.1 end
	return 1
end

function CreepManager:SpawnAllCreeps()
	local all = Entities:FindAllByName("custom_neutral_spawner_easy")
	for _,spawner in pairs(all) do
		self:SpawnCreeps(spawner, "easy")
	end
end

function CreepManager:SpawnCreeps(spawner, spawnType)
	if spawner.count then
		-- print("[CM] Try spawning... ", spawner.count)
		if spawner.count > 0 then return end
	end
	if not spawner.units then
		spawner.units = {}
		spawner.count = 0
	end
	if spawnType == "easy" then
		local count = 3
		spawner.count = count
		local spawnerLoc = spawner:GetAbsOrigin()
		for i=1,count do
			local unit = CreateUnitByName("npc_dota_neutral_kobold_basic", spawnerLoc, true, nil, nil, DOTA_TEAM_NEUTRALS)
			unit:AddNewModifier(spawner, nil, "modifier_kill", {Duration = 60})
			unit:AddNewModifier(spawner, nil, "modifier_creep_death", {spawnerID = spawner:entindex()})
			table.insert(spawner.units, unit)
		end
	end
end

function CreepManager:DropLoot(unit)
	local name = unit:GetUnitName()
	local path = "scripts/npc/units/neutrals/"..name..".txt"
	local kvs = LoadKeyValues(path)
	for _,drop in pairs(kvs.DropChances) do
		local chance = drop.chance
		local rarity = drop.rarity
		local rand = RandomInt(1, 100)
		if rand <= chance then
			local actualRarity = self:CalculateRarity(rarity)
			print("[CM] Drop, with rarity: ", actualRarity, rarity, chance)
		end
	end
end

function CreepManager:CalculateRarity(num)
	local fCommon = function(x) return 1/250 * x*x - x + 70 end
	local fUncommon = function(x) return fCommon(x) - 1/250 * x*x + 2/5 * x + 20 end
	local fRare = function(x) return fUncommon(x) + 1/1000 * x*x + 3/20 * x + 10 end
	local fLegendary = function(x) return fRare(x) - 1/500 * x*x + 2/5 * x end
	local fMythical = function(x) return fLegendary(x) + 1/10 * x end
	local fDivine = function(x) return fMythical(x) + 1/1000 * x*x - 1/20 * x end

	local rand = RandomInt(1, 100)
	if rand <= fCommon(num) then return "common" end
	if rand <= fUncommon(num) then return "uncommon" end
	if rand <= fRare(num) then return "rare" end
	if rand <= fLegendary(num) then return "legendary" end
	if rand <= fMythical(num) then return "mythical" end
	if rand <= fDivine(num) then return "divine" end
	print("[CM] Loot rarity error!", rand, num)
	return "common"
end

modifier_creep_death = class({})

function modifier_creep_death:DeclareFunctions()
	local funcs =  {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_creep_death:OnCreated(event)
	if IsClient() then return end
	self.spawner = EntIndexToHScript(event.spawnerID)
end

function modifier_creep_death:OnDeath(event)
	if IsClient() then return end
	if event.unit == self:GetParent() then
		local count
		self.spawner.units, count = RemoveFromTable(self.spawner.units, self:GetParent())
		self.spawner.count = self.spawner.count - count
		CreepManager:DropLoot(self:GetParent())
	end
end

function RemoveFromTable(tab, element)
	local newTable = {}
	local count = 0
	for _,elem in pairs(tab) do
		if not elem == element then
			table.insert(newTable, elem)
		else
			count = count + 1
		end
	end
	return newTable, count
end