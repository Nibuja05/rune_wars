# Runes

*Runes are built very similar to cores, so every rune needs a separate item file and a Lua equivalent. Here is an in-depth explenation of how runes are created correctly.*

## KV File

The KV files for runes have 3 major fields that are necessary for it to function, these are:

- `RuneName` - where the name of the Lua file is specified
- `KeyRequirements` - where a key is specified that is needed on the ability for this rune to function. The keys are under `extra_enums` as usual and start with `SPECIAL_ABILITY_KEY_`. If the rune works for every ability core, this field can be omitted.
- `SpecialDamageType` - specifies if and which element type is added to the ability. If the ability is not able to change the elemental type of the ability, `SPECIAL_DAMAGE_TYPE_NONE` needs to be added.

## Lua File

The Lua files follow a very similar pattern like the core Lua files, however they are a bit easier to make. There are two functions that are necessary for it to function:

- `GetReferenceItem` - which return the name of the item this Lua file belongs to. Example:
 ```lua
function your_rune_name:GetReferenceItem()
    return "item_ability_rune_rare_cascade"
end
```
- `GetAdditionalFunctions` - which is very similiar to the core version. Just return every function you want to be executed on the ability. Example:
```lua
function your_rune_name:GetAdditionalFunctions()
	local funcs = {
		"OnProjectileHitUnitExtra",
	}
	return funcs
end
```

### Modify Values

Runes can also modify all values of the ability. This can either be additive or multiplicative. To modify a value one or oth of following two functions can be added to the rune:

- `ModifyValuesConstant()` - returns a table with the names of the values to be modified and the additional values
- `ModifyValuesPercentage()` - returns a table with the names of the values to be modified and the multiplicative values

The tables are in the following format:
```lua
local values = {
	cooldown = "-2",
	damage = "50",
}
```

### Custom events

The rest of the file can be filled with your functions as you like. Be aware that runes feature a ton of unique events that are called on every ability. A proper explenation about these events follows:

- `OnProjectileHitUnit(hTarget)` - gets called whenever a projectile (tracking/linear) hits a unit.
- `OnProjectileFinish(vLocation)` - gets called when a projectile gets destroyed (linear only).
- `OnProjectileHitUnitExtra(hTarget, extraData)` - gets called whenever a projectile (tracking/linear) hits a unit. Contains additional informations about the projectile:
	- `start` (Vector): location where projectile started
	- `direction` (Vector): direction of projectile (linear only)
	- `target` (Entity): targeted unit (tracking only)
	- `source` (Entity): source unit (tracking only)
	- `speed` (Number): speed of projectile
	- `distance` (Number): maximum travel distance (linear only)
	- `width` (Number): collision width (linear only)
	- `visionRadius` (Number): projectile vision radius
- `OnProjectileHitFinishExtra(vLocation, extraData)` - gets called when a projectile gets destroyed (linear only). Contains same additional data as described above.
- `OnAttackStart(eventData)` - gets called when an attack of the ability owner is about to start. Usual event paramater as in modifier events.
- `OnAttack(eventData)` - gets called when the ability owner attacks. Usual event paramater as in modifier events.
- `OnAttackLanded(eventData)` - gets called when the ability owner attack lands. Usual event paramater as in modifier events.
- `OnTakeDamage(eventData)` - gets called when the ability owner takes damage. Usual event paramater as in modifier events.
- `OnDealDamage(eventData)` - gets called when the ability owner deals damage (after all reductions). Usual event paramater as in modifier events.
- `OnDealDamageCustom(eventData)` - gets called when the ability owner deals damage with this ability. Custom event parameter:
	- `damage` (Number): damage before reductions
	- `victim` (Entity): unit that damage is dealt to
	- `specialDamageType` (`DOTA_EXTRA_ENUMS`): special damage type of this attack
- `OnAttacked(eventData)` - gets called when the ability owner gets attacked by normal attacks. Usual event paramater as in modifier events.
- `OnDeath(eventData)` - gets called when a unit dies through any source of damage from the ability owner. Usual event paramater as in modifier events.
- `OnKilled(eventData)` - gets called when a unit dies through damage of this ability. Event parameter as in `OnDeath` event.

## Additional Informations

The tooltips for the rune items are utterly important, as they are also displayed in the description of the ability!
