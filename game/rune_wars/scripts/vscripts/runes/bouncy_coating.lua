
bouncy_coating = class({})

function bouncy_coating:GetReferenceItem()
	return "item_ability_rune_rare_bouncy_coating"
end

function bouncy_coating:GetAdditionalFunctions()
	local funcs = {
		"OnBombHit",
	}
	return funcs
end

function bouncy_coating:ModifyValuesPercentage()
	local values = {
		manaCost = "2",
	}
	return values
end

function bouncy_coating:OnBombHit(vLocation, extraData)
	local bounceCount = 0
	local runeName = "bouncy_coating"
	if extraData["bomb_bounces"] then
		bounceCount = extraData["bomb_bounces"]
	else
		extraData.orig_speed = extraData.speed
	end

	local maxBounce = self:GetSpecialRuneValueFor("bounce_count", runeName)
	local minDistance = self:GetSpecialRuneValueFor("min_bounce_distance", runeName)
	if bounceCount >= maxBounce then
		return
	end

	local newData = extraData
	newData["bomb_bounces"] = bounceCount + 1
	local direction = (vLocation - extraData.start):Normalized()
	local distance = (extraData.start - vLocation):Length2D()
	local newDistance = distance / 2
	if newDistance < minDistance then newDistance = minDistance end
	local newLoc = vLocation + direction * newDistance
	newLoc = GetGroundPosition(newLoc, extraData.target)

	self:FireBomb(vLocation, extraData.target, newLoc, extraData.orig_speed / 2, extraData.visionRadius, extraData)
end