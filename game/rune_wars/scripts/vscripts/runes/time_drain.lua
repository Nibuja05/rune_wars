
time_drain = class({})

function time_drain:GetReferenceItem()
	return "item_ability_rune_uncommon_time_drain"
end

function time_drain:GetAdditionalFunctions()
	local funcs = {
		"OnKilled",
	}
	return funcs
end

function time_drain:OnKilled(eventData)
	local caster = self:GetCaster()
	
	for i=0,2 do
		local ability = caster:GetAbilityByIndex(i)
		local curCooldown = ability:GetCooldownTimeRemaining()
		local reduction = self:GetSpecialRuneValueFor("cooldown_reduction", "time_drain")
		local newCooldown = curCooldown - ability:GetCooldown(ability:GetLevel()) * (reduction / 100)
		ability:EndCooldown()
		ability:StartCooldown(newCooldown)
	end
end