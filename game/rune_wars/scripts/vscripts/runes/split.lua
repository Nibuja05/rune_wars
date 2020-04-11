
split = class({})

function split:GetReferenceItem()
	return "item_ability_rune_uncommon_split"
end

function split:GetAdditionalFunctions()
	local funcs = {
		"OnProjectileHitFinishExtra",
		"OnSpellStart",
	}
	return funcs
end

function split:ModifyValuesConstant()
	local values = {
		manaCost = "100",
	}
	return values
end

function split:OnSpellStart()
	print("SpellStart!")
end

function split:OnProjectileHitFinishExtra(vLocation, extraData)
	local splitCount = 0
	local runeName = "split"
	local varName = "SplitCount"..runeName
	if extraData[varName] then
		splitCount = extraData[varName]
	end

	local maxSplit = self:GetSpecialRuneValueFor("split_count", runeName)
	if splitCount >= maxSplit then
		-- print("Can't split more than "..tostring(maxSplit).." times!")
		return
	end

	local newData = extraData
	newData[varName] = splitCount + 1
	local direction1 = RotateVector2D(extraData.direction, math.rad(-45))
	local direction2 = RotateVector2D(extraData.direction, math.rad(45))
	local newDistance = extraData.distance * 0.75
	self:DoLinearProjectile(vLocation, direction1, extraData.speed, newDistance, extraData.width, extraData.visionRadius, newData)
	self:DoLinearProjectile(vLocation, direction2, extraData.speed, newDistance, extraData.width, extraData.visionRadius, newData)
end

function RotateVector2D(v, theta)
    local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
    local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
    return Vector(xp,yp,v.z):Normalized()
end