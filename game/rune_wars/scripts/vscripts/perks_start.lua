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
		local health_gain = caster:GetModifierStackCount("modifier_rune_base_hp", ability)  * (caster:GetLevel() - 1) * 14/100
		caster:SetModifierStackCount("modifier_rune_bonus_health", ability, health_gain )
	end
	if caster:HasModifier("modifier_rune_bonus_mana") then
		local mana_gain = caster:GetModifierStackCount("modifier_rune_base_mana", ability) * (caster:GetLevel() - 1) * 10/100
		caster:SetModifierStackCount("modifier_rune_bonus_mana", ability, mana_gain )
	end
	if caster:HasModifier("modifier_rune_bonus_damage") then
		local bonus_damage = (caster:GetLevel() - 1)* 7.8 * 100
		caster:SetModifierStackCount("modifier_rune_bonus_damage", ability, bonus_damage )
	end
	if caster:HasModifier("modifier_rune_bonus_as") then
		local bonus_as = (caster:GetLevel() - 1)* 3
		caster:SetModifierStackCount("modifier_rune_bonus_as", ability, bonus_as )
	end
	if caster:HasModifier("modifier_rune_bonus_hp_regen") then
		local hp_regen = caster:GetMaxHealth() * 0.8
		caster:SetModifierStackCount("modifier_rune_bonus_hp_regen", ability, hp_regen )
	end
	if caster:HasModifier("modifier_rune_bonus_mana_regen") then
		local mana_regen = caster:GetMaxMana() * 0.6
		caster:SetModifierStackCount("modifier_rune_bonus_mana_regen", ability, mana_regen )
	end
	caster:CalculateStatBonus()
end

function set_base_stat( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_rune_base_hp") then
		caster:SetModifierStackCount("modifier_rune_base_hp", ability, caster:GetMaxHealth() )
	end
	if caster:HasModifier("modifier_rune_base_mana") then
		caster:SetModifierStackCount("modifier_rune_base_mana", ability, caster:GetMaxMana() )
	end
end