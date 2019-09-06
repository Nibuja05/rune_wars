
cascade = class({})

function cascade:GetReferenceItem()
	return "item_ability_rune_rare_cascade"
end

function cascade:GetAdditionalFunctions()
	local funcs = {
		"OnProjectileHitUnitExtra",
	}
	return funcs
end

function cascade:OnProjectileHitUnitExtra(hTarget, extraData)
	local cascadeCount = 0
	local runeName = "cascade"
	local varName = "CascadeCount".."_"..runeName
	if extraData[varName] then
		cascadeCount = extraData[varName]
	end

	local maxCascade = self:GetSpecialRuneValueFor("cascade_count", runeName)
	if cascadeCount >= maxCascade then
		return
	end

	local newData = {}
	newData[varName] = cascadeCount + 1

	local caster = self:GetCaster()
	local targetLoc = hTarget:GetAbsOrigin()
	local radius = self:GetSpecialRuneValueFor("cascade_radius", runeName)
	-- local radius = 200
	local targetTeam = self:GetAbilityTargetTeam()
	local targetType = self:GetAbilityTargetType()
	local targetFlags = self:GetAbilityTargetFlags()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), targetLoc, nil, radius, targetTeam, targetType, targetFlags, FIND_CLOSEST, false)
	for _,enemy in pairs(enemies) do
		if enemy ~= hTarget then
			self:DoTrackingProjectile(targetLoc, hTarget, enemy, extraData.speed, extraData.visionRadius, newData)
		end
	end
end