
LinkLuaModifier("modifier_column_stun", "cores/column_of_destruction.lua", LUA_MODIFIER_MOTION_NONE)
column_of_destruction = class({})

function column_of_destruction:GetReferenceItem()
	return "item_ability_core_common_column_of_destruction"
end

function column_of_destruction:GetFunctions()
	local funcs = {
		"PlayEffect",
		"OnSpellStart",
		"DelayedAction",
	}
	return funcs
end


function column_of_destruction:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE,
		Castrange = "%range",
		Cooldown = "%cooldown",
		Manacost	= "%manacost",
		Aoeradius = "%radius",
		Duration = "%duration",
		Texture = "120px-Bellows_of_Creation_Echo_Stomp_icon",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_MAGICAL,
		Title = "Column of Destruction",
		Description = "After a short delay stuns all enemies inside the targeted area while dealing damage.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function column_of_destruction:PlayEffect(loc, optVal)
	local particle = ParticleManager:CreateParticle("particles/econ/items/lina/lina_ti7/light_strike_array_pre_ti7.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, loc)
	ParticleManager:SetParticleControl(particle, 1, Vector(1, 1, optVal/500))
	ParticleManager:ReleaseParticleIndex(particle)
end

function column_of_destruction:DelayedAction(caster, loc, radius, targetTeam,targetType, targetFlags, duration, delay)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), loc, nil, radius, targetTeam, targetType, targetFlags, FIND_CLOSEST, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_stunned", {Duration = duration})
		self:DealDamage(self:GetSpecialValueFor("damage"), caster, enemy, self:GetAbilitySpecialDamageType())
	end
end
function column_of_destruction:OnSpellStart()
	local caster = self:GetCaster()
	local loc = self:GetCursorPosition()

	local radius = self:GetSpecialValueFor("radius")
	local targetTeam = self:GetAbilityTargetTeam()
	local targetType = self:GetAbilityTargetType()
	local targetFlags = self:GetAbilityTargetFlags()
	local duration = self:GetSpecialValueFor("duration")
	local delay = self:GetSpecialValueFor("delay")
	self:PlayEffect(loc, radius)
	

	Timers:CreateTimer(delay, function()
		self:DelayedAction(caster, loc, radius, targetTeam, targetType, targetFlags, duration, delay)
		end)	

	
end