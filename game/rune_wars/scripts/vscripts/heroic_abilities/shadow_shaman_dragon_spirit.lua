shadow_shaman_dragon_spirit = class({})
LinkLuaModifier("modifier_shadow_shaman_dragon_spirit_attack", "heroic_abilities/shadow_shaman_dragon_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_shaman_dragon_spirit_movement", "heroic_abilities/shadow_shaman_dragon_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shadow_shaman_dragon_spirit_debuff", "heroic_abilities/shadow_shaman_dragon_spirit", LUA_MODIFIER_MOTION_NONE)

function shadow_shaman_dragon_spirit:OnUpgrade()
	local caster = self:GetCaster()
	self.snake = CreateUnitByName(
		"shaman_spirit_dragon", -- szUnitName
		caster:GetOrigin(), -- vLocation,
		false, -- bFindClearSpace,
		caster, -- hNPCOwner,
		caster:GetOwner(), -- hUnitOwner,
		caster:GetTeamNumber() -- iTeamNumber
	)

	self.snake:AddNewModifier(caster, self, "modifier_shadow_shaman_dragon_spirit_attack", {})
	self.snake:AddNewModifier(caster, self, "modifier_shadow_shaman_dragon_spirit_movement", {})
end

function shadow_shaman_dragon_spirit:OnProjectileHit( hTarget, vLocation )
	if hTarget == nil then return end
	
	self.snake:PerformAttack(
		hTarget,-- hTarget,
		true,-- bUseCastAttackOrb,
		true,-- bProcessProcs,
		true,-- bSkipCooldown,
		false,-- bIgnoreInvis,
		true,-- bUseProjectile,
		false,-- bFakeAttack,
		true-- bNeverMiss
	)
	self.snake:StartGesture( ACT_DOTA_ATTACK )
	
	return true
end


-- Modifiers --

modifier_shadow_shaman_dragon_spirit_attack = class({})
modifier_shadow_shaman_dragon_spirit_movement = class({})
modifier_shadow_shaman_dragon_spirit_debuff = class({})

function modifier_shadow_shaman_dragon_spirit_attack:OnCreated()
	local think_interval = self:GetAbility():GetSpecialValueFor("think_interval")
	self.duration = self:GetAbility():GetSpecialValueFor("duration")
	self.base_damage = self:GetAbility():GetSpecialValueFor("base_damage")
	self.per_level = self:GetAbility():GetSpecialValueFor("per_level")


	local projectile_name = "models/development/invisiblebox.vmdl"
	local projectile_distance = "280"
	local projectile_start_radius = "120"
	local projectile_end_radius = "120"
	self.projectile_speed = "3000"
	self.projectile_info = {
		Source = self:GetCaster(),
		Ability = self:GetAbility(),
		
		bDeleteOnHit = true,
		
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		
		EffectName = projectile_name,
		fDistance = projectile_distance,
		fStartRadius = projectile_start_radius,
		fEndRadius = projectile_end_radius,
		
		bHasFrontalCone = true,
		bReplaceExisting = false,
		
		bProvidesVision = false,
	}

	if IsServer() then
		self:StartIntervalThink(think_interval)
	end
end

function modifier_shadow_shaman_dragon_spirit_attack:OnIntervalThink()
	if IsServer() then
		local projectile_direction = self:GetCaster():GetForwardVector()
		self.projectile_info.vVelocity = projectile_direction * self.projectile_speed
		self.projectile_info.vSpawnOrigin = self:GetParent():GetOrigin()
		self.projectile_info.fExpireTime = GameRules:GetGameTime() + 10.0

		ProjectileManager:CreateLinearProjectile(self.projectile_info)
	end
end

function modifier_shadow_shaman_dragon_spirit_attack:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_shadow_shaman_dragon_spirit_attack:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_shaman_dragon_spirit_debuff", { duration = self.duration })
			
			local damageTable = {
				damage = self.base_damage + (self.per_level * self:GetAbility():GetLevel()),
				attacker = self:GetParent(),
				victim = params.target,
				damage_type = DAMAGE_TYPE_PURE,
				ability = self:GetAbility(),
			}
			local specialDamageType = DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_FIRE
			Elements:ApplyDamage(damageTable, specialDamageType)
		end
	end
end

function modifier_shadow_shaman_dragon_spirit_attack:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}

	return state
end

function modifier_shadow_shaman_dragon_spirit_attack:GetEffectName()
	return "particles/econ/courier/courier_beetlejaw_gold/courier_beetlejaw_gold_ambient_soft_smoke.vpcf"
end

function modifier_shadow_shaman_dragon_spirit_attack:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

--||

function modifier_shadow_shaman_dragon_spirit_movement:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.03)
	end
end

function modifier_shadow_shaman_dragon_spirit_movement:OnIntervalThink()
	if IsServer() then
		local forward_Vector = self:GetCaster():GetForwardVector()
		local origin = self:GetCaster():GetAbsOrigin()
		local distance = -30
		local position = origin + forward_Vector * distance

		self:GetParent():SetAbsOrigin(position + Vector(0, 0, 70))
		self:GetParent():SetForwardVector(forward_Vector)
	end
end

--||

function modifier_shadow_shaman_dragon_spirit_debuff:OnCreated()
	self.damage_reduction_pct = self:GetAbility():GetSpecialValueFor("damage_reduction_pct")
end

function modifier_shadow_shaman_dragon_spirit_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end

function modifier_shadow_shaman_dragon_spirit_debuff:GetModifierBaseDamageOutgoing_Percentage()
	return -self.damage_reduction_pct
end

function modifier_shadow_shaman_dragon_spirit_debuff:GetEffectName()
	return "particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_target_slowparent.vpcf"
end

function modifier_shadow_shaman_dragon_spirit_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
	
--[[
	"shadow_shadow_shaman_dragon_spirit"
	{
		// General
		//-------------------------------------------------------------------------------------------------------------
		"BaseClass"				"ability_datadriven"
		"AbilityBehavior"		"DOTA_ABILITY_BEHAVIOR_PASSIVE"
		"AbilityTextureName"	"120px-Dragon_Slave_icon_alt1"
		"AbilityUnitDamageType"			"DAMAGE_TYPE_MAGICAL"	
		"SpecialDamageType"		"SPECIAL_DAMAGE_TYPE_FIRE"
		"AbilityCastRange"			"400"
		// Precache
		//-------------------------------------------------------------------------------------------------------------
		"precache"
		 {
		  "soundfile"   "soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts"
		  "particle"	"particles/econ/courier/courier_beetlejaw_gold/courier_beetlejaw_gold_ambient_soft_smoke.vpcf"
		 
		 }
	
		// Stats
		//-------------------------------------------------------------------------------------------------------------
		"MaxLevel"		"1"
			
		// Special
		//-------------------------------------------------------------------------------------------------------------
		"AbilitySpecial"
		{
			"01"
			{
				"var_type"				"FIELD_INTEGER"
				"base_damage"		"14"
			}
			"02"
			{
				"var_type"				"FIELD_INTEGER"
				"per_level"		"3"
			}
			"03"
			{
				"var_type"				"FIELD_INTEGER"
				"dmg_reduction"		"10"
			}
			"04"
			{
				"var_type"				"FIELD_INTEGER"
				"duration"		"3"
			}
		}
		"OnCreated"
		{
			"RunScript"
			{
				"ScriptFile"	"libs/hero_stats.lua"
				"Function"		"LevelUpAbility"
			}
		}
		"OnProjectileHitUnit"
		{
			"DeleteOnHit"	"1"
			"RunScript"
			{
				"ScriptFile"	"heroic_abilities/shadow_shaman_dragon_spirit.lua"
				"Function"		"dragon_attack"
				"target"		"TARGET"
			}
		}
	
		"Modifiers"
		{
			"modifier_spirit_guide"
			{
				"Passive"	"1"
				"IsHidden"	"1"
				"ThinkInterval"  "0.03"
				"OnIntervalThink"
				{
					"RunScript"
					{
						"ScriptFile"	"heroic_abilities/shadow_shaman_dragon_spirit.lua"
						"Function"		"move"
					}
	
				}
	
				"OnCreated"
				{
					"SpawnUnit"
					{
						"UnitName"	"shaman_spirit_dragon"
						"UnitCount"	"1"
						"SpawnRadius"	"1"
						"Target"		"CASTER"
			
						"OnSpawn"
						{
							"ApplyModifier"
							{
								"ModifierName"	"modifier_shadow_shaman_dragon_spirit_attack"
								"Target"		"TARGET"
							}
						}
					}
				}
				"OnDeath"
				{
					"RunScript"
					{
						"ScriptFile"	"heroic_abilities/shadow_shaman_dragon_spirit.lua"
						"Function"		"Kill"
					}
				}
			}
			"modifier_shadow_shaman_dragon_spirit_attack"
			{
				"Passive"	"0"
				"IsHidden"	"1"
				"EffectName"	"particles/econ/courier/courier_beetlejaw_gold/courier_beetlejaw_gold_ambient_soft_smoke.vpcf"
				"EffectAttachType"	"follow_origin"
				"ThinkInterval"  "1.4"
				"OnIntervalThink"
				{
					"LinearProjectile"
					{
						"Target"      	"CASTER"
					    "EffectName"  	"models/development/invisiblebox.vmdl"
					    "MoveSpeed"   	"3000"
					    "StartRadius"   "120"
					    "StartPosition" "attach_origin"
					    "EndRadius"     "120"
					    "FixedDistance" "280"
					    "TargetTeams"   "DOTA_UNIT_TARGET_TEAM_ENEMY"
					    "TargetTypes"   "DOTA_UNIT_TARGET_BASIC | DOTA_UNIT_TARGET_HERO"
					    "TargetFlags"   "DOTA_UNIT_TARGET_FLAG_NONE"
					    "HasFrontalCone"    "1"
					    "ProvidesVision"	"0"
					    "VisionRadius"	"0"
					}
				}
				
				"OnAttackLanded"
				{
					"RunScript"
				  	{
						"ScriptFile"	"libs/generic_hero_events.lua"
						"Function"		"dealdamage"
						"caster"		"CASTER"
						"target" 	"TARGET"
						"is_spell"		"0"
				   		"is_poison"		"0"
				   		"base_damage"		"%base_damage"
				   		"ad_pct"		"0"
				   		"ap_pct"		"0"
				   		"per_level"		"%per_level"
				   		"self_hp_pct"		"0"
				   		"self_max_hp_pct"		"0"
				   		"self_mana_pct"		"0"
				  		"self_max_mana_pct"		"0"
				   		"target_hp_pct"		"0"
				   		"target_max_hp_pct"		"0"
				   		"target_mana_pct"		"0"
				   		"target_max_mana_pct"		"0"			   		
				 	}
					"ApplyModifier"
					{
						"ModifierName"	"modifier_shaman_spirit_guide_curse"
						"Target"		"TARGET"
					}
				}
	
				"States"
				{
					"MODIFIER_STATE_NO_UNIT_COLLISION"	"MODIFIER_STATE_VALUE_ENABLED"
					"MODIFIER_STATE_NOT_ON_MINIMAP"	"MODIFIER_STATE_VALUE_ENABLED"
					"MODIFIER_STATE_UNSELECTABLE"	"MODIFIER_STATE_VALUE_ENABLED"
					"MODIFIER_STATE_NO_HEALTH_BAR"		   "MODIFIER_STATE_VALUE_ENABLED"
					"MODIFIER_STATE_INVULNERABLE"			"MODIFIER_STATE_VALUE_ENABLED"
				}	
			}
			"modifier_shaman_spirit_guide_curse"
			{
				"IsDeBuff"		"1"
				"IsPurgable"	"1"
				"Duration"		"3"
	
				"EffectName"	"particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_target_slowparent.vpcf"
				"EffectAttachType"	"follow_hitloc"
	
				"Properties"
				{
					"MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE"	"-10"
				}
			}
			"modifier_shaman_spirit_attack"
			{
				"IsPurgable"	"0"
				"Duration"		"0.3"
				"OverrideAnimation"		"ACT_DOTA_ATTACK"
			}	
		}
	
	}
}
























function Kill( keys )
	local caster_owner = keys.caster:GetPlayerOwner() 
	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, 10000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do 
		if nearby_ally:HasModifier("modifier_shadow_shaman_dragon_spirit_attack") then
			print("Snake seems dead")
			local target_owner = nearby_ally:GetPlayerOwner() 

			if caster_owner == target_owner then
				nearby_ally:ForceKill(true)
			end		
		end
	end	
end

function move( keys )

	local fv = keys.caster:GetForwardVector()
	local origin = keys.caster:GetAbsOrigin()
	local distance = -30


	local position = origin + fv * distance

	local caster_owner = keys.caster:GetPlayerOwner() 
	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, 10000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do  
		if nearby_ally:HasModifier("modifier_shadow_shaman_dragon_spirit_attack") then
			local target_owner = nearby_ally:GetPlayerOwner() 
			if caster_owner == target_owner then

				local final_position = Vector(position.x, position.y, position.z + 70)
				nearby_ally:SetAbsOrigin(final_position)
				nearby_ally:SetForwardVector(fv)
			end		
		end
	end	
end


function dragon_attack(keys)
	local ability = keys.ability
	local caster_owner = keys.caster:GetPlayerOwner() 
	local target = keys.target
	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, 10000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do  
		if nearby_ally:HasModifier("modifier_shadow_shaman_dragon_spirit_attack") then
			local target_owner = nearby_ally:GetPlayerOwner() 
			if caster_owner == target_owner then
				ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_shaman_spirit_attack", {})
				nearby_ally:PerformAttack(target, true, true, true, false, true, false, true)
			end		
		end
	end	
end
	

]]