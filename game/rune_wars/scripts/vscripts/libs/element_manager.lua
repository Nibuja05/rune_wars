
if not Elements then
	Elements = class({})
end

function Elements:ApplyDamage(damageTable, specialType)
	local damage = damageTable.damage
	local reduction = 0
	local amplification = 0
	if specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_STORM then
		reduction = victim:GetModifierStackCount("modifier_storm_resistance" , self)
		amplification = attacker:GetModifierStackCount("modifier_storm_power", self )	

	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_ORDER then
		reduction = victim:GetModifierStackCount("modifier_order_resistance" , self)
		amplification = attacker:GetModifierStackCount("modifier_order_power", self )

	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_CHAOS then
		reduction = victim:GetModifierStackCount("modifier_chaos_resistance" , self)
		amplification = attacker:GetModifierStackCount("modifier_chaos_power", self )

	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_EARTH then
		reduction = victim:GetModifierStackCount("modifier_earth_resistance" , self)
		amplification = attacker:GetModifierStackCount("modifier_earth_power", self )

	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_FIRE then
		reduction = victim:GetModifierStackCount("modifier_fire_resistance" , self)
		amplification = attacker:GetModifierStackCount("modifier_fire_power", self )

	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_WATER then
		reduction = victim:GetModifierStackCount("modifier_water_resistance" , self)
		amplification = attacker:GetModifierStackCount("modifier_water_power", self )

	end

	damageTable.damage = (amplification - reduction + 100 ) * damage / 100
	ApplyDamage(damageTable)
	if specialType ~= DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_NONE then
		self:ShowDamageNumbers(damageTable.victim, damageTable.damage, specialType)
	end
end

function Elements:ShowDamageNumbers(target, number, specialType)
	local pfx = ""
	local color = Vector(0,0,0)
	if specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_STORM then
		pfx = "storm"
		color = Vector(255, 204, 0)
	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_ORDER then
		pfx = "order"
		color = Vector(240, 230, 140)
	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_CHAOS then
		pfx = "chaos"
		color = Vector(72, 61, 139)
	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_EARTH then
		pfx = "earth"
		color = Vector(205, 133, 63)
	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_FIRE then
		pfx = "fire"
		color = Vector(255, 89, 0)
	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_WATER then
		pfx = "water"
		color = Vector(30, 144, 255)
	elseif specialType == DOTA_EXTRA_ENUMS.SPECIAL_DAMAGE_TYPE_DIVINE then
		pfx = "divine"
		color = Vector(221, 160, 221)
	end

	local pfxPath = string.format("particles/msg/msg_%s.vpcf", pfx)

	number = math.floor(number)
	local digits = 0
	local presymbol = 1
	local postsymbol = 9
	local lifetime = 1.0
	if number ~= nil then
		digits = #tostring(number)
	end
	if presymbol ~= nil then
		digits = digits + 1
	end
	if postsymbol ~= nil then
		digits = digits + 1
	end

	local particle = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target)
	-- ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(0,0,200))
	ParticleManager:SetParticleControl(particle, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
	ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
	ParticleManager:SetParticleControl(particle, 3, color)
	ParticleManager:ReleaseParticleIndex(particle)
end

function Elements:HealUnit(target, source, amount)
	local pfx = "particles/msg_fx/msg_heal.vpcf"
	local particle = ParticleManager:CreateParticle(pfx, PATTACH_ABSORIGIN_FOLLOW, source)

	amount = math.floor(amount)
	local color = Vector(0, 255, 0)
	local digits = 1
	local lifetime = 1.0
	if amount ~= nil then
		digits = #tostring(amount)
	end

	ParticleManager:SetParticleControl(particle, 1, Vector(10, tonumber(amount), 0))
	ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
	ParticleManager:SetParticleControl(particle, 3, color)
	ParticleManager:ReleaseParticleIndex(particle)

	source:Heal(amount, target)
end

