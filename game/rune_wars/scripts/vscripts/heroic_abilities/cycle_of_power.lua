function Leap( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)

	-- Ability variables
	ability.leap_direction = caster:GetForwardVector()
	ability.leap_distance = ability:GetLevelSpecialValueFor("cast_range", ability_level)
	ability.leap_speed = 45
	ability.leap_traveled = 0
	ability.leap_z = 0
	for i=0, 15, 1 do 
		local current_ability = keys.caster:GetAbilityByIndex(i)
		if current_ability ~= nil and current_ability:GetCooldown(current_ability:GetLevel()-1) ~=  0 then
			local remaining_cooldown = current_ability:GetCooldownTimeRemaining()
			if remaining_cooldown ~=  0 and current_ability ~= ability  then
				current_ability:EndCooldown()
				local cooldown_new = remaining_cooldown * (100 - ability:GetLevelSpecialValueFor("active_cooldown_reduction", ability:GetLevel() - 1)) /100
				current_ability:StartCooldown(cooldown_new)
			end
		end
	end
	if caster:HasModifier("modifier_cycle_fire") then
		caster:RemoveModifierByName("modifier_cycle_fire")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_cycle_water", {})
	elseif caster:HasModifier("modifier_cycle_water") then
		caster:RemoveModifierByName("modifier_cycle_water")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_cycle_earth", {})
	elseif caster:HasModifier("modifier_cycle_earth") then
		caster:RemoveModifierByName("modifier_cycle_earth")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_cycle_storm", {})
	elseif caster:HasModifier("modifier_cycle_storm") then
		caster:RemoveModifierByName("modifier_cycle_storm")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_cycle_order", {})
	elseif caster:HasModifier("modifier_cycle_order") then
		caster:RemoveModifierByName("modifier_cycle_order")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_cycle_chaos", {})
	elseif caster:HasModifier("modifier_cycle_chaos") then
		caster:RemoveModifierByName("modifier_cycle_chaos")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_cycle_fire", {})
	end
end

function LeapHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:InterruptMotionControllers(true)
	end
end

function LeapVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	
	if ability.leap_traveled < ability.leap_distance/2 then
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end

function cycle_damage(keys) --requires = caster target is_poison base_damage ad_pct ap_pct per_level self_hp_pct self_max_hp_pct self_mana_pct self_max_mana_pct target_hp_pct target_max_hp_pct target_mana_pct target_max_mana_pct
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local attacker = caster
	local victim = target
	local damage = ability:GetLevelSpecialValueFor("damage_bonus", ability:GetLevel() - 1) + (ability:GetLevelSpecialValueFor("damage_bonus_per_level", ability:GetLevel() - 1) * caster:GetLevel())
	if caster:HasModifier("modifier_cycle_fire") then
		local damage = (damage + caster:GetModifierStackCount("modifier_fire_power", caster) * ability:GetLevelSpecialValueFor("damage_bonus_per_power", ability:GetLevel() - 1)) * (100 + caster:GetModifierStackCount("modifier_fire_power", caster) - target:GetModifierStackCount("modifier_fire_resistance", caster)) / 100
		local specialType = SPECIAL_DAMAGE_TYPE_FIRE
		local damageTable = {
	        damage = damage,
	        attacker = caster,
	        victim = target,
	        damage_type = DAMAGE_TYPE_PURE,
	        ability = self,
	    }
	    
	    Elements:ApplyDamage(damageTable, specialType)
	elseif caster:HasModifier("modifier_cycle_water") then
		local damage = (damage + caster:GetModifierStackCount("modifier_water_power", caster) * ability:GetLevelSpecialValueFor("damage_bonus_per_power", ability:GetLevel() - 1)) * (100 + caster:GetModifierStackCount("modifier_water_power", caster) - target:GetModifierStackCount("modifier_water_resistance", caster)) / 100
		local specialType = SPECIAL_DAMAGE_TYPE_WATER
		local damageTable = {
	        damage = damage,
	        attacker = caster,
	        victim = target,
	        damage_type = DAMAGE_TYPE_PURE,
	        ability = self,
	    }
	    
	    Elements:ApplyDamage(damageTable, specialType)
	elseif caster:HasModifier("modifier_cycle_earth") then
		local damage = (damage + caster:GetModifierStackCount("modifier_earth_power", caster) * ability:GetLevelSpecialValueFor("damage_bonus_per_power", ability:GetLevel() - 1)) * (100 + caster:GetModifierStackCount("modifier_earth_power", caster) - target:GetModifierStackCount("modifier_earth_resistance", caster)) / 100
		local specialType = SPECIAL_DAMAGE_TYPE_EARTH
		local damageTable = {
	        damage = damage,
	        attacker = caster,
	        victim = target,
	        damage_type = DAMAGE_TYPE_PURE,
	        ability = self,
	    }
	    
	    Elements:ApplyDamage(damageTable, specialType)
	elseif caster:HasModifier("modifier_cycle_storm") then
		local damage = (damage + caster:GetModifierStackCount("modifier_storm_power", caster) * ability:GetLevelSpecialValueFor("damage_bonus_per_power", ability:GetLevel() - 1)) * (100 + caster:GetModifierStackCount("modifier_storm_power", caster) - target:GetModifierStackCount("modifier_storm_resistance", caster)) / 100
		local specialType = SPECIAL_DAMAGE_TYPE_STORM
		local damageTable = {
	        damage = damage,
	        attacker = caster,
	        victim = target,
	        damage_type = DAMAGE_TYPE_PURE,
	        ability = self,
	    }
	    Elements:ApplyDamage(damageTable, specialType)
	elseif caster:HasModifier("modifier_cycle_order") then
		local damage = (damage + caster:GetModifierStackCount("modifier_order_power", caster) * ability:GetLevelSpecialValueFor("damage_bonus_per_power", ability:GetLevel() - 1)) * (100 + caster:GetModifierStackCount("modifier_order_power", caster) - target:GetModifierStackCount("modifier_order_resistance", caster)) / 100
		local specialType = SPECIAL_DAMAGE_TYPE_ORDER
		local damageTable = {
	        damage = damage,
	        attacker = caster,
	        victim = target,
	        damage_type = DAMAGE_TYPE_PURE,
	        ability = self,
	    }
	    Elements:ApplyDamage(damageTable, specialType)
	elseif caster:HasModifier("modifier_cycle_chaos") then
		local damage = (damage + caster:GetModifierStackCount("modifier_chaos_power", caster) * ability:GetLevelSpecialValueFor("damage_bonus_per_power", ability:GetLevel() - 1)) * (100 + caster:GetModifierStackCount("modifier_chaos_power", caster) - target:GetModifierStackCount("modifier_chaos_resistance", caster)) / 100
		local specialType = SPECIAL_DAMAGE_TYPE_CHAOS
		local damageTable = {
	        damage = damage,
	        attacker = caster,
	        victim = target,
	        damage_type = DAMAGE_TYPE_PURE,
	        ability = self,
	    }
	    Elements:ApplyDamage(damageTable, specialType)
	end
end
