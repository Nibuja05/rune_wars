function lethal_rythm( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target:HasModifier( "modifier_rune_lethal_rythm_stacker" ) then
		if not caster:HasModifier("modifier_rune_lethal_rythm_active") then
			local current_stack = target:GetModifierStackCount( "modifier_rune_lethal_rythm_stacker", ability )
			if current_stack == 2 then
				ability:ApplyDataDrivenModifier( caster, caster, "modifier_rune_lethal_rythm_active", { Duration = 3 } )
				local attack_speed = ((caster:GetLevel() - 1) * 3) + 35
				caster:SetModifierStackCount( "modifier_rune_lethal_rythm_active", ability, attack_speed )
			else
				ability:ApplyDataDrivenModifier( caster, target, "modifier_rune_lethal_rythm_stacker", { Duration = 2 } )
				target:SetModifierStackCount( "modifier_rune_lethal_rythm_stacker", ability, current_stack + 1 )
			end
		end
	else
		if target:IsRealHero() then
			ability:ApplyDataDrivenModifier( caster, target, "modifier_rune_lethal_rythm_stacker", { Duration = 2 } )
			target:SetModifierStackCount( "modifier_rune_lethal_rythm_stacker", ability, 1 )
		end
		
		
	end
end

function level_based_stacks( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_rune_bonus_health") then
		local hp_bonus = ((caster:GetLevel() - 1) * 19) + 39
		caster:SetModifierStackCount("modifier_rune_bonus_health", ability, hp_bonus )
	end
		if caster:HasModifier("modifier_rune_bonus_mana") then
		local mana_bonus = ((caster:GetLevel() - 1) * 15) + 30
		caster:SetModifierStackCount("modifier_rune_bonus_mana", ability, mana_bonus )
	end
	if caster:HasModifier("modifier_rune_bonus_damage") then
		local mana_bonus = ((caster:GetLevel() - 1)* 5) + 25
		caster:SetModifierStackCount("modifier_rune_bonus_damage", ability, mana_bonus )
	end
	if caster:HasModifier("modifier_rune_bonus_as") then
		local mana_bonus = ((caster:GetLevel() - 1)* 2) + 22
		caster:SetModifierStackCount("modifier_rune_bonus_as", ability, mana_bonus )
	end
	if caster:HasModifier("modifier_rune_bonus_physical_res") then
		local mana_bonus = ((caster:GetLevel() - 1) * 4)  + 20
		caster:SetModifierStackCount("modifier_rune_bonus_physical_res", ability, mana_bonus )
	end

	
	if caster:HasModifier("modifier_rune_bonus_magic_damage") then
		local mana_bonus = ((caster:GetLevel() - 1) * 3)  + 40
		caster:SetModifierStackCount("modifier_rune_bonus_magic_damage", ability, mana_bonus )
	end
	if caster:HasModifier("modifier_rune_bonus_magic_res") then
		local mana_bonus = ((caster:GetLevel() - 1) * 4)  + 20
		caster:SetModifierStackCount("modifier_rune_bonus_magic_res", ability, mana_bonus )
	end

end