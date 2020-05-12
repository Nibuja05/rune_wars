LinkLuaModifier("modifier_invis_dummy", "libs/general_modifiers.lua", LUA_MODIFIER_MOTION_NONE)

modifier_invis_dummy = class({})

function modifier_invis_dummy:IsHidden()
	return true
end

function modifier_invis_dummy:IsDebuff()
	return false
end

function modifier_invis_dummy:IsPurgable()
	return false
end

function modifier_invis_dummy:CheckState()
	local state = {
	 				[MODIFIER_STATE_UNSELECTABLE] = true,
					[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
					[MODIFIER_STATE_NO_HEALTH_BAR] = true,
					[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
					[MODIFIER_STATE_ATTACK_IMMUNE] = true,
					[MODIFIER_STATE_MAGIC_IMMUNE] = true,
					[MODIFIER_STATE_INVISIBLE] = true,
					[MODIFIER_STATE_DISARMED] = true,
					[MODIFIER_STATE_ROOTED] = true,
				}
	 return state
end