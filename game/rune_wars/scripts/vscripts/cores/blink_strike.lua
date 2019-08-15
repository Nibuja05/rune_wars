
blink_strike = class({})

function blink_strike:GetReferenceItem()
	return "item_ability_core_common_blink_strike"
end

function blink_strike:GetFunctions()
	local funcs = {
		"OnSpellStart",
	}
	return funcs
end

function blink_strike:GetAbilityTable()
	local abilityTable = {
		Behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET,
		Castrange = "%range",
		Cooldown = "%cooldown",
		Manacost	= "%manacost",
		Texture = "120px-Backstab_icon",
		Targettype = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
		Targetflags = DOTA_UNIT_TARGET_FLAG_NONE,
		Targetteam = DOTA_UNIT_TARGET_TEAM_ENEMY + DOTA_UNIT_TARGET_TEAM_FRIENDLY,
		Dispel = DOTA_EXTRA_ENUMS.DOTA_ABILITY_DISPEL_TYPE_NONE,
		Spellimmunity = DOTA_EXTRA_ENUMS.SPELL_IMMUNITY_NONE,
		Damagetype = DAMAGE_TYPE_MAGICAL,
		Title = "Blink Strike",
		Description = "Teleports behind of targeted unit, deals damage if target is an enemy.",
		Lore = "Basic Lore :(",
	}
	return abilityTable
end

function blink_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target == caster then
		caster:Interrupt()
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", caster:GetPlayerOwner())
		FireGameEvent('custom_error_show', {player_ID = caster:GetPlayerID(), _error = "Ability Can't Target Self"})
		self:RefundManaCost()
		self:EndCooldown()
	else
		local fv = target:GetForwardVector()
		local origin = target:GetAbsOrigin()
		local distance = 70
		local particleName = "particles/core_abilities/blink_strike/storm/blink_start.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(particle)

		local position = origin + caster:GetForwardVector() * distance
		FindClearSpaceForUnit(caster, position, false)
		caster:SetForwardVector(fv)

		if caster:GetTeam() == target:GetTeam() then
		else
			self:DealDamage(self:GetSpecialValueFor("damage"), caster, target, self:GetAbilitySpecialDamageType())
			local order = 
			{
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			}

			ExecuteOrderFromTable(order)
		end
		local particleName = "particles/core_abilities/blink_strike/storm/blink_end.vpcf"
		local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(particle)
	end
end