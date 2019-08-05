

function add_stat( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_cooldown_reduction_datadriven"
	local ad = keys.ad_bonus
	local ap = keys.ap_bonus
	local crit = keys.crit_bonus
	local lifesteal_atk = keys.lifesteal_atk
	local cdr = keys.cdr
	local ar_pen_flat = keys.ar_pen_flat
	local mr_pen = keys.mr_pen
	local ar_pen_pct = keys.ar_pen_pct
	

	local current_stack = caster:GetModifierStackCount( "modifier_attack_damage", ability )
	caster:SetModifierStackCount( "modifier_attack_damage", ability, current_stack + ad )

	local current_stack = caster:GetModifierStackCount( "modifier_ability_power", ability )
	caster:SetModifierStackCount( "modifier_ability_power", ability, current_stack + ap )

	local current_stack = caster:GetModifierStackCount( "modifier_lifesteal_attack", ability )
	caster:SetModifierStackCount( "modifier_lifesteal_attack", ability, current_stack + lifesteal_atk )

	local current_stack = caster:GetModifierStackCount( "modifier_critical_strike", ability )
	caster:SetModifierStackCount( "modifier_critical_strike", ability, current_stack + crit )

	local current_stack = caster:GetModifierStackCount( "modifier_cooldown_reduction_datadriven", ability )
	caster:SetModifierStackCount( "modifier_cooldown_reduction_datadriven", ability, current_stack + cdr )

	local current_stack = caster:GetModifierStackCount( "modifier_armor_pen_flat", ability )
	caster:SetModifierStackCount( "modifier_armor_pen_flat", ability, current_stack + ar_pen_flat )

	local current_stack = caster:GetModifierStackCount( "modifier_magic_pen_flat", ability )
	caster:SetModifierStackCount( "modifier_magic_pen_flat", ability, current_stack + mr_pen )

	local current_stack = caster:GetModifierStackCount( "modifier_armor_pen_pct", ability )
	caster:SetModifierStackCount( "modifier_armor_pen_pct", ability, current_stack + ar_pen_pct )
end

function remove_stat( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_cooldown_reduction_datadriven"
	local ad = keys.ad_bonus
	local ap = keys.ap_bonus
	local crit = keys.crit_bonus
	local lifesteal_atk = keys.lifesteal_atk
	local cdr = keys.cdr
	local ar_pen_flat = keys.ar_pen_flat
	local mr_pen = keys.mr_pen
	local ar_pen_pct = keys.ar_pen_pct
	

	local current_stack = caster:GetModifierStackCount( "modifier_attack_damage", ability )
	caster:SetModifierStackCount( "modifier_attack_damage", ability, current_stack - ad )

	local current_stack = caster:GetModifierStackCount( "modifier_ability_power", ability )
	caster:SetModifierStackCount( "modifier_ability_power", ability, current_stack - ap )

	local current_stack = caster:GetModifierStackCount( "modifier_lifesteal_attack", ability )
	caster:SetModifierStackCount( "modifier_lifesteal_attack", ability, current_stack - lifesteal_atk )

	local current_stack = caster:GetModifierStackCount( "modifier_critical_strike", ability )
	caster:SetModifierStackCount( "modifier_critical_strike", ability, current_stack - crit )

	local current_stack = caster:GetModifierStackCount( "modifier_cooldown_reduction_datadriven", ability )
	caster:SetModifierStackCount( "modifier_cooldown_reduction_datadriven", ability, current_stack - cdr )

	local current_stack = caster:GetModifierStackCount( "modifier_armor_pen_flat", ability )
	caster:SetModifierStackCount( "modifier_armor_pen_flat", ability, current_stack - ar_pen_flat )

	local current_stack = caster:GetModifierStackCount( "modifier_magic_pen_flat", ability )
	caster:SetModifierStackCount( "modifier_magic_pen_flat", ability, current_stack - mr_pen )

	local current_stack = caster:GetModifierStackCount( "modifier_armor_pen_pct", ability )
	caster:SetModifierStackCount( "modifier_armor_pen_pct", ability, current_stack - ar_pen_pct )
end

function lifesteal( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifierName = "modifier_lifesteal_attack"

	
	-- Check if unit already have stack
	if caster:HasModifier( modifierName ) then
		local ls_amount = caster:GetModifierStackCount( modifierName, ability )
		if ls_amount > 0 then
			local amount = keys.amount * ls_amount / 100
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_lifesteal_visual", {duration = 0.25})
			caster:Heal(amount, caster)
		end
	end
end

function dual_lifesteal( keys )
	-- Variables
	local attacker = keys.attacker
	local ability = keys.ability
	local modifierName = "modifier_lifesteal_dual"

	
	-- Check if unit already have stack
	if attacker:HasModifier( modifierName ) then
		local ls_amount = attacker:GetModifierStackCount( modifierName, ability )
		if ls_amount > 0 then
			local amount = keys.amount * ls_amount / 100
			ability:ApplyDataDrivenModifier(attacker, attacker, "modifier_lifesteal_visual_spell", {duration = 0.25})
			caster:Heal(amount, attacker)
		end
	end
end

function perform_critical_strike(keys)
	local attacker = keys.attacker
	local ability = keys.ability
	local modifierName = "modifier_critical_strike"
	local chance = attacker:GetModifierStackCount( modifierName, ability )

	if RandomFloat(0, 100) < chance then
		ability:ApplyDataDrivenModifier(attacker, attacker, "modifier_crit_bonus", {duration = 2})
	end
end

function reduce_cooldowns(keys)
	local caster = keys.caster
	local current_stack = caster:GetModifierStackCount( "modifier_cooldown_reduction_datadriven", caster )

	for i=0, 15, 1 do  
		local current_ability = caster:GetAbilityByIndex(i)
		if current_ability ~= nil then
			local level = current_ability:GetLevel()-1
			if current_ability:GetCooldown(level) - current_ability:GetCooldownTimeRemaining() < 0.03 and current_ability:GetCooldownTimeRemaining() > 0 then
				if not current_ability:IsPassive()  then
					if current_stack > 40 then
						local current_stack = 40
					end
					current_ability:EndCooldown()
					local cooldown_new = current_ability:GetCooldown(level) * (100 - current_stack) / 100
					current_ability:StartCooldown(cooldown_new)
				end
			end
			
		end
	end
end

function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = 1

	this_ability:SetLevel(this_abilityLevel)
end