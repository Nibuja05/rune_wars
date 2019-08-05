function Kill( keys )
	local caster_owner = keys.caster:GetPlayerOwner() 
	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, 10000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do 
		if nearby_ally:HasModifier("modifier_shaman_spirit_guide_stats") then
			print("[AS] Snake seems dead")
			local target_owner = nearby_ally:GetPlayerOwner() 

			if caster_owner == target_owner then
				nearby_ally:ForceKill(true)
			end		
		end
	end	
end

function move( keys )

	local fv = keys.caster:GetForwardVector()
	local origin = keys.caster:GetAbsOrigin()
	local distance = -35


	local position = origin + fv * distance

	local caster_owner = keys.caster:GetPlayerOwner() 
	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, 10000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do  
		if nearby_ally:HasModifier("modifier_shaman_spirit_guide_stats") then
			local target_owner = nearby_ally:GetPlayerOwner() 
			if caster_owner == target_owner then

				local final_position = Vector(position.x, position.y, position.z + 90)
				nearby_ally:SetAbsOrigin(final_position)
				nearby_ally:SetForwardVector(fv)
			end		
		end
	end	
end


function dragon_attack(keys)
	local ability = keys.ability
	local caster_owner = keys.caster:GetPlayerOwner() 
	local target = keys.target
	local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, 10000,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		
	for i, nearby_ally in ipairs(nearby_allied_units) do  
		if nearby_ally:HasModifier("modifier_shaman_spirit_guide_stats") then
			local target_owner = nearby_ally:GetPlayerOwner() 
			if caster_owner == target_owner then
				ability:ApplyDataDrivenModifier(keys.caster, nearby_ally, "modifier_shaman_spirit_attack", {})
				nearby_ally:PerformAttack(target, true, true, true, false, true, false, true)
			end		
		end
	end	
end
	

