
POPUP_SYMBOL_PRE_PLUS = 0
POPUP_SYMBOL_PRE_MINUS = 1
POPUP_SYMBOL_PRE_SADFACE = 2
POPUP_SYMBOL_PRE_BROKENARROW = 3
POPUP_SYMBOL_PRE_SHADES = 4
POPUP_SYMBOL_PRE_MISS = 5
POPUP_SYMBOL_PRE_EVADE = 6
POPUP_SYMBOL_PRE_DENY = 7
POPUP_SYMBOL_PRE_ARROW = 8

POPUP_SYMBOL_POST_EXCLAMATION = 0
POPUP_SYMBOL_POST_POINTZERO = 1
POPUP_SYMBOL_POST_MEDAL = 2
POPUP_SYMBOL_POST_DROP = 3
POPUP_SYMBOL_POST_LIGHTNING = 4
POPUP_SYMBOL_POST_SKULL = 5
POPUP_SYMBOL_POST_EYE = 6
POPUP_SYMBOL_POST_SHIELD = 7
POPUP_SYMBOL_POST_POINTFIVE = 8



-- e.g. when healed by an ability
function PopupHealing(target, amount)
    PopupNumbers(target, "heal", Vector(0, 255, 0), 1.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

-- e.g. the popup you get when you suddenly take a large portion of your health pool in damage at once
function PopupDamage(target, amount)
    PopupNumbers(target, "damage", Vector(255, 0, 0), 1.0, amount, nil, POPUP_SYMBOL_POST_DROP)
end

-- e.g. when dealing critical damage
function PopupCriticalDamage(target, amount)
    PopupNumbers(target, "crit", Vector(255, 0, 0), 1.0, amount, nil, POPUP_SYMBOL_POST_LIGHTNING)
end

-- e.g. when taking damage over time from a poison type spell
function PopupDamageOverTime(target, amount)
    PopupNumbers(target, "poison", Vector(215, 50, 248), 1.0, amount, nil, POPUP_SYMBOL_POST_EYE)
end

-- e.g. when blocking damage with a stout shield
function PopupDamageBlock(target, amount)
    PopupNumbers(target, "block", Vector(255, 255, 255), 1.0, amount, POPUP_SYMBOL_PRE_MINUS, nil)
end

-- e.g. when last-hitting a creep
function PopupGoldGain(target, amount)
    PopupNumbers(target, "gold", Vector(255, 200, 33), 1.0, amount, POPUP_SYMBOL_PRE_PLUS, nil)
end

-- e.g. when missing uphill
function PopupMiss(target)
    PopupNumbers(target, "miss", Vector(255, 0, 0), 1.0, nil, POPUP_SYMBOL_PRE_MISS, nil)
end

-- Customizable version.
function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
    local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()

    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end


function dealdamage(keys) --requires = caster target is_poison base_damage ad_pct ap_pct per_level self_hp_pct self_max_hp_pct self_mana_pct self_max_mana_pct target_hp_pct target_max_hp_pct target_mana_pct target_max_mana_pct
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local is_spell = keys.is_spell
	local is_poison = keys.is_poison
	local base_damage = keys.base_damage 
	local ad_dmg = caster:GetModifierStackCount( "modifier_attack_damage", ability ) * keys.ad_pct / 100
	local ap_dmg = caster:GetModifierStackCount( "modifier_ability_power", ability ) * keys.ap_pct / 100
	local lvl_dmg = keys.per_level * (caster:GetLevel() - 1)
	local self_hp = keys.self_hp_pct * caster:GetHealth() / 100
	local self_max_hp = keys.self_max_hp_pct * caster:GetMaxHealth() / 100
	local self_mana = keys.self_mana_pct * caster:GetMana() / 100
	local self_max_mana = keys.self_max_mana_pct * caster:GetMaxMana() / 100
	local target_hp = keys.target_hp_pct * target:GetHealth() / 100
	local target_max_hp = keys.target_max_hp_pct * target:GetMaxHealth() / 100
	local target_mana = keys.target_mana_pct * target:GetMana() / 100
	local target_max_mana = keys.target_max_mana_pct * target:GetMaxMana() / 100


	local damage = ( base_damage + ad_dmg + ap_dmg + lvl_dmg + self_hp + self_max_hp + self_max_mana + self_mana + target_hp + target_max_hp + target_mana + target_max_mana )
	local indicator = RandomInt(damage, damage)

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = damage

	ApplyDamage(damage_table)

	if caster:HasModifier("modifier_spell_lifesteal_item") then
		local ls_amount = 0
		if target:IsRealHero() then
			local ls_amount = 20
		else
			local ls_amount = 5
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_lifesteal_visual_spell", {duration = 0.25})
		local hp_gain = ls_amount * damage / 100
		caster:Heal(hp_gain, caster)
	end
end

function workonmana(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local is_poison = keys.is_poison
	local base_damage = keys.base_damage 
	local ad_dmg = caster:GetModifierStackCount( "modifier_attack_damage", ability ) * keys.ad_pct / 100
	local ap_dmg = caster:GetModifierStackCount( "modifier_ability_power", ability ) * keys.ap_pct / 100
	local lvl_dmg = keys.per_level * (caster:GetLevel() - 1)
	local self_hp = keys.self_hp_pct * caster:GetHealth() / 100
	local self_max_hp = keys.self_max_hp_pct * caster:GetMaxHealth() / 100
	local self_mana = keys.self_mana_pct * caster:GetMana() / 100
	local self_max_mana = keys.self_max_mana_pct * caster:GetMaxMana() / 100
	local target_hp = keys.target_hp_pct * target:GetHealth() / 100
	local target_max_hp = keys.target_max_hp_pct * target:GetMaxHealth() / 100
	local target_mana = keys.target_mana_pct * target:GetMana() / 100
	local target_max_mana = keys.target_max_mana_pct * target:GetMaxMana() / 100


	local mana_bonus = ( base_damage + ad_dmg + ap_dmg + lvl_dmg + self_hp + self_max_hp + self_max_mana + self_mana + target_hp + target_max_hp + target_mana + target_max_mana )
	local new_mana = mana_bonus + target:GetMana()
	target:SetMana(new_mana)

	local popup_mana = RandomInt(mana_bonus, mana_bonus)

	if popup_mana > 0	then 
		PopupNumbers(target, "heal", Vector(0, 0, 255), 1.5, popup_mana, POPUP_SYMBOL_PRE_PLUS, nil)
	end

	if popup_mana < 0 	then 
		PopupNumbers(target, "heal", Vector(0, 0, 255), 1.5, popup_mana, POPUP_SYMBOL_PRE_MINUS, nil)
	end

end

function workonhp(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local is_poison = keys.is_poison
	local base_damage = keys.base_damage 
	local ad_dmg = caster:GetModifierStackCount( "modifier_attack_damage", ability ) * keys.ad_pct / 100
	local ap_dmg = caster:GetModifierStackCount( "modifier_ability_power", ability ) * keys.ap_pct / 100
	local lvl_dmg = keys.per_level * (caster:GetLevel() - 1)
	local self_hp = keys.self_hp_pct * caster:GetHealth() / 100
	local self_max_hp = keys.self_max_hp_pct * caster:GetMaxHealth() / 100
	local self_mana = keys.self_mana_pct * caster:GetMana() / 100
	local self_max_mana = keys.self_max_mana_pct * caster:GetMaxMana() / 100
	local target_hp = keys.target_hp_pct * target:GetHealth() / 100
	local target_max_hp = keys.target_max_hp_pct * target:GetMaxHealth() / 100
	local target_mana = keys.target_mana_pct * target:GetMana() / 100
	local target_max_mana = keys.target_max_mana_pct * target:GetMaxMana() / 100


	local hp_bonus = ( base_damage + ad_dmg + ap_dmg + lvl_dmg + self_hp + self_max_hp + self_max_mana + self_mana + target_hp + target_max_hp + target_mana + target_max_mana )
	local indicator = RandomInt(hp_bonus, hp_bonus)
	caster:Heal(hp_bonus, target)

 
	PopupNumbers(target, "heal", Vector(0,255, 0), 2.0, indicator, POPUP_SYMBOL_PRE_PLUS, nil)


end

function OutOfCombatHeal(keys)
	local caster = keys.caster
	if caster:GetHealth() < caster:GetMaxHealth() 	then
    	PopupNumbers(caster, "heal", Vector(0, 255, 0), 2, heal_amount, POPUP_SYMBOL_PRE_PLUS, nil)
    end
end

function OutOfCombatMana(keys)
	local caster = keys.caster
	if caster:GetMana() < caster:GetMaxMana() 	then
    	PopupNumbers(caster, "heal", Vector(0, 0, 255), 2, mana_amount, POPUP_SYMBOL_PRE_PLUS, nil)
    end
end

