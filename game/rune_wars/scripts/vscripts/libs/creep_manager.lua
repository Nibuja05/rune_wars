
LinkLuaModifier("modifier_custom_neutrals", "libs/creep_manager.lua", LUA_MODIFIER_MOTION_NONE)

AREA_STATE_NONE = 1
AREA_STATE_NORMAL = 2
AREA_STATE_EMPTY = 4

if not CreepManager then
	CreepManager = class({})
end

ListenToGameEvent("game_rules_state_change", function()
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		CreepManager:Init()
	elseif state == DOTA_GAMERULES_STATE_PRE_GAME then
		CreepManager:InitFilters()
	end
end, nil)

function CreepManager:Init()
	self.started = true
	print("[CM] Initializing CreepManager...")
	ListenToGameEvent('npc_spawned ', Dynamic_Wrap(self, 'OnNPCSpawned'), self)
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 20)
	self.startTime = nil
	self.unitKVs = {}
	self:PreloadKVs()
end

function CreepManager:InitFilters()
	local mode = GameRules:GetGameModeEntity()
	mode:SetDamageFilter(Dynamic_Wrap(self, 'DamageFilter'), self)
	if not self.initAreas and IsServer() then
		-- print("Init Areas!")
		self.initAreas = true
		self.areas = {}
		self:InitAreas()
	end
end

function CreepManager:PreloadKVs()
	print("[CM] Loading unit KVs...")
	local path = "scripts/npc/npc_units_custom.txt"
	local kvs = LoadKeyValues(path)
	for name, unitData in pairs(kvs) do
		self.unitKVs[name] = {}
		self.unitKVs[name].drops = {}
		self.unitKVs[name].resistances = {SPECIAL_DAMAGE_TYPE_FIRE = 0, SPECIAL_DAMAGE_TYPE_WATER = 0, SPECIAL_DAMAGE_TYPE_EARTH = 0, SPECIAL_DAMAGE_TYPE_STORM = 0, SPECIAL_DAMAGE_TYPE_ORDER = 0, SPECIAL_DAMAGE_TYPE_CHAOS = 0}
		self.unitKVs[name].attackType = DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_NONE
		for key, vals in pairs(unitData) do
			if key == "DropChances" then
				self.unitKVs[name].drops = vals
			end
			if key == "Resistances" then
				self.unitKVs[name].resistances = vals
			end
			if key == "AttackType" then
				self.unitKVs[name].attackType = DOTA_EXTRA_ENUMS[vals]
			end
		end
	end
	self.areaKVs = {}
	local path = "scripts/data/units/area_data.txt"
	local kvs = LoadKeyValues(path)
	for name, areaData in pairs(kvs) do
		self.areaKVs[name] = {}
		self.areaKVs[name].name = areaData.DisplayName
		self.areaKVs[name].stages = areaData.Stages
	end
end

function CreepManager:InitAreas()
	for i=1,9 do
		local area = Entities:FindByName(nil, "neutral_area_0"..tostring(i))
		if not area then break end
		local areaSpawner = Entities:FindAllByName("neutral_area_0"..tostring(i).."_spawner")
		self.areas[i] = {}
		self.areas[i].area = area
		self.areas[i].spawner = areaSpawner
		self.areas[i].state = AREA_STATE_NONE
		self.areas[i].evolution = 0

		area.linkedIndex = i
	end
end

function EnterArea(trigger)
	local area = trigger.caller
	local hero = trigger.activator
	-- print(hero:GetName())
end

function LeaveArea(trigger)
	-- print("Leave", trigger)
end

function CreepManager:OnNPCSpawned(event)
	-- print("[CM] Something spawned!!")
end

function CreepManager:OnThink(event)
	-- if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local time = GameRules:GetGameTime()
		if not self.startTime then self.startTime = time end
		local interval = 30
		if (time - self.startTime) % interval < 1 then
			-- print("[CM] Spawn Neutrals!")
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
	if not self.areas then return end
	for i, areaTable in pairs(self.areas) do
		self:SpawnCreeps(areaTable, "kobolds")
	end
end

function CreepManager:SpawnCreeps(area, spawnType)
	-- initial tests
	-- print("Spawn Creeps in area with the type", spawnType)
	if not area.count then area.count = 0 end
	if not area.units then area.units = {} end
	-- print(area.count)
	if area.count == 0 then
		area.state = AREA_STATE_EMPTY
	end

	if area.state == AREA_STATE_NORMAL then return end
	if not self.areaKVs[spawnType] then return end

	local stage = self:GetStage(area.evolution)
	local areaTable = self.areaKVs[spawnType].stages[tostring(stage)]
	local count = RandomInt(areaTable.MinCount, areaTable.MaxCount)
	local bossChance = RandomInt(1, 100)
	if bossChance <= tonumber(areaTable.BossChance) then
		-- print("Spawn Boss!")
	end

	local unitTable = {}
	local curVal = 0
	for _,unitData in pairs(areaTable.Units) do
		local chance = tonumber(unitData.Chance)
		unitTable[chance + curVal] = unitData.Name
		curVal = curVal + chance
	end

	area.count = count

	local spawner = ShuffleTable(area.spawner)
	local spawnerCount = GetTableLength(spawner)
	while count > 0 do
		local index = (count % spawnerCount) + 1
		count = count - 1
		local chance = RandomInt(1, 100)
		for unitChance,unitName in pairs(unitTable) do
			if chance <= tonumber(unitChance) then
				self:SpawnNeutral(unitName, spawner[index], area)
				break
			end
		end
	end
	area.state = AREA_STATE_NORMAL
end

function CreepManager:GetStage(points)
	if points < 10000 then
		return 1
	end
	return 2
end

function CreepManager:SpawnNeutral(name, spawner, area)
	local newLoc = spawner:GetAbsOrigin() + RandomVector(RandomInt(1, 500))
	local unit = CreateUnitByName(name, newLoc, true, nil, nil, DOTA_TEAM_NEUTRALS)
	table.insert(area.units, unit)
	-- unit:AddNewModifier(spawner, nil, "modifier_kill", {Duration = 60})
	unit:AddNewModifier(spawner, nil, "modifier_custom_neutrals", {areaID = area.area:entindex()})

	local netTable = CustomNetTables:GetTableValue("neutrals", tostring(unit:entindex()))
	if not netTable then 
		netTable = {}
	end
	netTable.attackType = self.unitKVs[name].attackType
	CustomNetTables:SetTableValue("neutrals", tostring(unit:entindex()), netTable)
	ability = unit:AddAbility("neutral_elemental_attack_"..GetElementName(self.unitKVs[name].attackType))
	ability:SetLevel(1)

	-- print(area.area:IsTouching(unit))
	-- self:TestUnitLocInArea(spawner:GetAbsOrigin(), unit, area.area)
end

function CreepManager:TestUnitLocInArea(origLoc, unit, area)
	if not area:IsTouching(unit) then
		local newLoc = origLoc + RandomVector(RandomInt(1, 500))
		unit:SetAbsOrigin(newLoc)
		self:TestUnitLocInArea(unit, area)
	end
	return
end

function CreepManager:DamageFilter(event)
	if event.entindex_inflictor_const == nil then
		if event.entindex_attacker_const then
			attacker = EntIndexToHScript(event.entindex_attacker_const)
			if attacker:HasModifier("modifier_elemental_attack") then
				local modifier = attacker:FindModifierByName("modifier_elemental_attack")
				local ability = attacker:FindAbilityByName("neutral_elemental_attack_"..GetElementName(modifier:GetDamageType()))
				if not ability then return true end
				damageTable = {
					attacker = attacker,
					victim = EntIndexToHScript(event.entindex_victim_const),
					damage = event.damage,
					ability = ability,
					damage_flags = event.damage_flags,
					damage_type = DAMAGE_TYPE_MAGICAL,
				}
				Elements:ApplyDamage(damageTable, modifier:GetDamageType())
				return false
			end
		end
	end
	return true
end

function CreepManager:DropLoot(unit)
	local name = unit:GetUnitName()
	local kvs = self.unitKVs[name]
	if kvs then
		for _,drop in pairs(kvs.drops) do
			local chance = drop.chance
			local rarity = drop.rarity
			local rand = RandomInt(1, 100)
			if rand <= chance then
				local actualRarity = self:CalculateRarity(rarity)
				-- print("[CM] Drop, with rarity: ", actualRarity, rarity, chance)
			end
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

modifier_custom_neutrals = class({})

function modifier_custom_neutrals:DeclareFunctions()
	local funcs =  {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_custom_neutrals:CheckState()
	if self:GetStackCount() > 1 then
		local state = {
			[MODIFIER_STATE_BLIND] = true,
			[MODIFIER_STATE_DISARMED] = true,
		}
		return state
	end
	return {}
end

function modifier_custom_neutrals:OnCreated(event)
	if IsClient() then return end
	local area = EntIndexToHScript(event.areaID)
	self.areaTable = CreepManager.areas[area.linkedIndex]
	self.startLoc = self:GetParent():GetAbsOrigin()
	self.startTime = GameRules:GetGameTime()
	self.aggro = false
	self:StartIntervalThink(0.25)
end

function modifier_custom_neutrals:OnIntervalThink()
	local curLoc = self:GetParent():GetAbsOrigin()
	local distance = (curLoc - self.startLoc):Length2D()
	if distance > 400 then
		if not self.aggro then
			print("Start aggro timer!")
			self.aggro = true
			self:StartIntervalThink(4)
			return
		else
			print("Order back to start loc")
			self.aggro = false
			self.ret = true
			self:SetStackCount(2)
			local newOrder = {
				UnitIndex = self:GetParent():entindex(), 
				OrderType = DOTA_UNIT_ORDER_TAUNT,
				Position = self.startLoc, --Optional.  Only used when targeting the ground
				Queue = 0 --Optional.  Used for queueing up abilities
			}
			ExecuteOrderFromTable(newOrder)
			return
		end
	elseif self.aggro then
		print("Resetting aggro timer, back in range")
		self.aggro = false
	end
	if distance < 50 then
		self.ret = false
		self:SetStackCount(0)
	end
end

function modifier_custom_neutrals:OnDeath(event)
	if IsClient() then return end
	if event.unit == self:GetParent() then
		local count
		self.areaTable.units = RemoveFromTable(self.areaTable.units, self:GetParent())
		self.areaTable.count = self.areaTable.count - 1
		CreepManager:DropLoot(self:GetParent())
	end
end