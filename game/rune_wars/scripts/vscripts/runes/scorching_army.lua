
LinkLuaModifier("modifier_scorching_army_aura", "runes/scorching_army.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_scorching_army_debuff", "runes/scorching_army.lua", LUA_MODIFIER_MOTION_NONE)

scorching_army = class({})

function scorching_army:GetReferenceItem()
	return "item_ability_rune_common_scorching_army"
end

function scorching_army:GetAdditionalFunctions()
	local funcs = {
		"GetSummonModifiers",
	}
	return funcs
end

function scorching_army:GetSummonModifiers()
	local values = {
		{
			name = "modifier_scorching_army_aura",
		},
	}
	return values
end

modifier_scorching_army_aura = class({})

function modifier_scorching_army_aura:IsDebuff()
	return false
end

function modifier_scorching_army_aura:IsPurgable()
	return false
end

function modifier_scorching_army_aura:IsHidden()
	return false
end

function modifier_scorching_army_aura:OnCreated(event)
	if IsClient() then return end
	self.radius = self:GetAbility():GetSpecialRuneValueFor("radius", "scorching_army")
end

function modifier_scorching_army_aura:IsAura()
	return true 
end

function modifier_scorching_army_aura:GetModifierAura()
	return "modifier_scorching_army_debuff"
end

function modifier_scorching_army_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_scorching_army_aura:GetAuraSearchFlags()
	return DOTA_DAMAGE_FLAG_NONE
end

function modifier_scorching_army_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_scorching_army_aura:GetAuraRadius()
	return self.radius
end

function modifier_scorching_army_aura:GetAuraDuration()
	return 0.5
end

modifier_scorching_army_debuff = class({})

function modifier_scorching_army_debuff:IsPurgable()
	return false
end

function modifier_scorching_army_debuff:IsHidden()
	return false
end

function modifier_scorching_army_debuff:IsDebuff()
	return true
end

function modifier_scorching_army_debuff:OnCreated(event)
	if IsClient() then return end
	self.interval = 0.5
	self.damage = self:GetAbility():GetSpecialRuneValueFor("damage_per_second", "scorching_army") * self.interval
	self:StartIntervalThink(self.interval)
end

function modifier_scorching_army_debuff:OnIntervalThink()
	if IsClient() then return end
	local ability = self:GetAbility()
	local attacker = self:GetAuraOwner()
	if not attacker or not IsValidEntity(attacker) or not attacker:IsAlive() then return end
	ability:DealDamage(self.damage, self:GetAuraOwner(), self:GetParent(), DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_FIRE)
end