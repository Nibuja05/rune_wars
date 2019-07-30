-- Generated from template

if GameMode == nil then
	_G.GameMode = class({})
end

require('libs/generic_ability_manager')
require('libs/timers')
require('libs/extra_enums')
require('libs/ability_item_manager')
require('libs/ability_aspect_manager')
require('libs/element_manager')
require('libs/util')
require('libs/generic_ability')

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
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCSpawned'), self)
	-- self:StartEventTest() --Spams console!
end

function GameMode:OnNPCSpawned(event)
 	local npc = EntIndexToHScript(event.entindex)

 	print(DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ALLIES_NO)

 	if npc:IsRealHero() then
 		local playerID = npc:GetPlayerID()
		local player = PlayerResource:GetPlayer(playerID)
	  	CustomGameEventManager:Send_ServerToPlayer(player, "init_tooltips", {})
	  	GenericAbility:InitHero(npc)
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