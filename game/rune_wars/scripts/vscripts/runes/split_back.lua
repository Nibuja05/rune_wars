
split_back = class({})

function split_back:GetReferenceItem()
	return "item_ability_rune_uncommon_split"
end

function split_back:GetAdditionalFunctions()
	local funcs = {
		"OnProjectileHitFinishExtra",
	}
	return funcs
end

function split_back:OnProjectileHitFinishExtra(vLocation, extraData)
	local splitCount = 0
	local runeName = "split_back"
	local varName = "SplitCount"..runeName
	if extraData[varName] then
		splitCount = extraData[varName]
	end

	local maxSplit = self:GetSpecialRuneValueFor("split_count", runeName)
	if splitCount >= maxSplit then
		-- print("Can't split_back more than "..tostring(maxSplit).." times!")
		return
	end

	local newData = extraData
	newData[varName] = splitCount + 1
	local direction1 = RotateVector2D(extraData.direction, math.rad(-135))
	local direction2 = RotateVector2D(extraData.direction, math.rad(135))
	local newDistance = extraData.distance * 0.75
	self:DoLinearProjectile(vLocation, direction1, extraData.speed, newDistance, extraData.width, extraData.visionRadius, newData)
	self:DoLinearProjectile(vLocation, direction2, extraData.speed, newDistance, extraData.width, extraData.visionRadius, newData)
end

function RotateVector2D(v, theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end