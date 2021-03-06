-- Generated from template

if GameMode == nil then
	_G.GameMode = class({})
end

require('libs/generic_ability_manager')
require('libs/timers')
require('libs/extra_enums')
-- require('libs/filters')
require('libs/ability_item_manager')
require('libs/ability_aspect_manager')
require('libs/element_manager')
require('libs/util')
require('libs/generic_ability')
require('libs/rune_builder')
-- require('libs/hero_stats')
require('libs/creep_manager')
require('libs/selection')

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = GameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function GameMode:InitGameMode()
	print( "Rune Wars is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCSpawned'), self)

	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(ItemManager, "OnItemAddedToInventory"), ItemManager)

	-- self:StartEventTest() --Spams console!
end

function GameMode:OnNPCSpawned(event)
	local npc = EntIndexToHScript(event.entindex)

	if npc:IsRealHero() then
		local playerID = npc:GetPlayerID()
		local player = PlayerResource:GetPlayer(playerID)
		CustomGameEventManager:Send_ServerToPlayer(player, "init_tooltips", {})
		GenericAbility:InitHero(npc)
	end
	for i=0,12 do
		local ability = npc:GetAbilityByIndex(i)
		if ability then
			if ability:GetLevel() < 1 then
				if ability:IsInnate() then
					ability:SetLevel(1)
				end
			end
		end
	end
end

-- Evaluate the state of the game
function GameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function CDOTABaseAbility:IsInnate()
	return false
end
