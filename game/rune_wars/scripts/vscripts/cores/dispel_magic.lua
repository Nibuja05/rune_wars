
LinkLuaModifier("modifier_dispel_magic_buff", "cores/dispel_magic.lua", LUA_MODIFIER_MOTION_NONE)
dispel_magic = class({})

function dispel_magic:GetReferenceItem()
	return "item_ability_core_common_dispel_magic"
end

function dispel_magic:GetFunctions()
	local funcs = {
		"OnSpellStart",
	}
	return funcs
end

function dispel_magic:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET,
		Cooldown = "%cooldown",
		Manacost = "%manacost",
		Texture = "120px-Arsenal_of_the_Demonic_Vessel_Aphotic_Shield_icon",
		Targettype = DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_ALLIES_YES,
		Damagetype = DAMAGE_TYPE_NONE,
		Title = "Dispel Magic",
		Description = "Removes most negative effects from your hero while increasing Chaos Damage Resistance.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function dispel_magic:OnSpellStart()
	local caster = self:GetCaster()

	local RemovePositiveBuffs = false
	local RemoveDebuffs = true
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = true
	local RemoveExceptions = false
	caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
	local duration = self:GetSpecialValueFor("duration")
	caster:AddNewModifier(caster, self, "modifier_dispel_magic_buff", {Duration = duration})

end


modifier_dispel_magic_buff = class({})

function modifier_dispel_magic_buff:IsHidden()
	return false
end

function modifier_dispel_magic_buff:IsDebuff()
	return true
end

function modifier_dispel_magic_buff:IsPurgable()
	return true
end

function modifier_dispel_magic_buff:GetEffectName()
	return "particles/core_abilities/dispel_magic/dispel_magic_chaos/dispel_magic_shield.vpcf"
end

function modifier_dispel_magic_buff:GetEffectAttachType()
	return "follow_hitloc"
end
function modifier_dispel_magic_buff:GetAttributes()
	return "MODIFIER_ATTRIBUTE_MULTIPLE"
end

function modifier_dispel_magic_buff:OnCreated(event)
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		self.bonus_resistance = ability:GetSpecialValueFor("bonus_resistance")
		local buff_old_chaos_resistance = caster:GetModifierStackCount("modifier_chaos_resistance", self)
		caster:SetModifierStackCount( "modifier_chaos_resistance", ability, buff_old_chaos_resistance + self.bonus_resistance )
	end
end



function modifier_dispel_magic_buff:OnDestroy()
	if IsServer() then
		local ability = self:GetAbility()
		local caster = self:GetCaster()
		local buff_old_chaos_resistance = caster:GetModifierStackCount("modifier_chaos_resistance", self)
		caster:SetModifierStackCount( "modifier_chaos_resistance", ability, buff_old_chaos_resistance - self.bonus_resistance )

	end
end
