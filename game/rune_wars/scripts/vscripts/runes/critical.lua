
critical = class({})

function critical:GetReferenceItem()
	return "item_ability_rune_common_critical"
end

function critical:GetAdditionalFunctions()
	local funcs = {
		"OnDealDamageCustom",
	}
	return funcs
end

function critical:ModifyValuesConstant()
	local values = {
		cooldown = "2",
	}
	return values
end

function critical:ModifyValuesPercentage()
	local values = {
		manaCost = "0.5",
		DMG = "1.2",
	}
	return values
end

function critical:ModifyValuesGlobal()
	return "1.3"
end

function critical:OnDealDamageCustom(eventData)
	local damage = eventData.damage
	local chance = self:GetSpecialRuneValueFor("crit_chance", "critical")
	local damageMult = self:GetSpecialRuneValueFor("crit_mult", "critical") / 100

	if RandomInt(0, 100) <= chance then
		
		local target = eventData.victim
		local targetLoc = target:GetAbsOrigin()
		local particle = ParticleManager:CreateParticle("particles/runes/critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", targetLoc, false)
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", targetLoc, false)
		ParticleManager:SetParticleControl(particle, 3, self:GetCaster():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle)

		return damage * damageMult
	end
end