var CONTINUE_PROCESSING_EVENT = false;

var DOTA_ABILITY_DISPEL_TYPE_NONE = 0;
var DOTA_ABILITY_DISPEL_TYPE_NO = 1;
var DOTA_ABILITY_DISPEL_TYPE_YES = 2;
var DOTA_ABILITY_DISPEL_TYPE_STRONG = 4;

var SPECIAL_KEY_ENUMS = {
	SPECIAL_ABILITY_KEY_UNIT: 0,
	SPECIAL_ABILITY_KEY_SELF: 1,
	SPECIAL_ABILITY_KEY_POINT: 2,
	SPECIAL_ABILITY_KEY_PASSIVE: 4,
	SPECIAL_ABILITY_KEY_LINEAR_PROJECTILE: 8,
	SPECIAL_ABILITY_KEY_TRACKING_PROJECTILE: 16,
	SPECIAL_ABILITY_KEY_SINGLE_TARGET: 32,
	SPECIAL_ABILITY_KEY_MULTI_TARGET: 64,
	SPECIAL_ABILITY_KEY_AOE: 128,
	SPECIAL_ABILITY_KEY_SUMMON: 256,
	SPECIAL_ABILITY_KEY_DAMAGE: 512,
	SPECIAL_ABILITY_KEY_HEAL: 1024,
	SPECIAL_ABILITY_KEY_BUFF: 2048,
	SPECIAL_ABILITY_KEY_EFFECTIVE: 4096,
	SPECIAL_ABILITY_KEY_DURATION: 8192,
	SPECIAL_ABILITY_KEY_DEBUFF: 16384,
	SPECIAL_ABILITY_KEY_BOMB: 32768
}

// need to change them, so it works properly
SPELL_IMMUNITY_ENEMIES_YES	= 4;
SPELL_IMMUNITY_ENEMIES_NO = 8;

// Find HUD Elements
var base = $.GetContextPanel().GetParent().GetParent().GetParent();
var x = base.FindChildTraverse('HUDElements');
x = x.FindChildTraverse('lower_hud');
x = x.FindChildTraverse('center_with_stats');
x = x.FindChildTraverse('center_block');
x = x.FindChildTraverse('AbilitiesAndStatBranch');
var abilities = x.FindChildTraverse('abilities');
var tooltipManager = base.FindChildTraverse('Tooltips');
var abilityPanels = [];

var reset = false;
var shown = false;
var started = false;
var open = false;
var altDown = false;
var resetSchedule;

var rainbow = [];
var rainbowStart = 0;
var lastIndex;

var RAINBOW_COLOR_TITLE = false;
var RAINBOW_COLOR_DESC = false;
var RAINBOW_COLOR_LORE = false;
var RAINBOW_COLOR_ATTR = false;
var RAINBOW_COLOR_ATTR_EXTRA = false;
var RAINBOW_DENSITY = 40;

function InitializeTooltips() {
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	Players.GetLocalPlayerPortraitUnit();
	for (var index = 0; index < 6; index++) {
		var abilityPanel = GetAbilityPanelFromIndex(index);
		var abilityLevelUpPanel = GetAbilityLevelUpPanelFromIndex(index);
		var ability = Entities.GetAbility(mainSelected, index);
		var abilityName = Abilities.GetAbilityName(ability);
		if (abilityName.indexOf("generic_ability") < 0) {
			if (abilityPanel !== null) {
				abilityPanel.SetPanelEvent(
					"onmouseover", 
					function(){
						ResetAbilityTooltip();
					}
				);
			}
			continue;
		};
		$.Msg("Adding Tooltip for index " + index)
		switch (index) {
			case 0:
				SetPanelEvents(abilityPanel, abilityLevelUpPanel, 0);
				break;
			case 1:
				SetPanelEvents(abilityPanel, abilityLevelUpPanel, 1);
				break;
			case 2:
				SetPanelEvents(abilityPanel, abilityLevelUpPanel, 2);
				break;
			case 3:
				SetPanelEvents(abilityPanel, abilityLevelUpPanel, 3);
				break;
			case 4:
				SetPanelEvents(abilityPanel, abilityLevelUpPanel, 4);
				break;
			case 5:
				SetPanelEvents(abilityPanel, abilityLevelUpPanel, 5);
				break;
			case 6:
				
				break;
		}
		abilityPanels[index] = abilityPanel;
	}

	CustomNetTables.SubscribeNetTableListener("generic_ability", OnAbilityToolTipChanged);

	//Init Rainbow Maker
	GenerateColor(RAINBOW_DENSITY);
	if (!started) {RainbowInc();};

	// $.Msg("SHOW: " + shown)
	if (shown) {
		if (lastIndex !== undefined) {
			var hideAbilityPanel = abilityPanels[lastIndex];
			$.DispatchEvent("DOTAHideAbilityTooltip", hideAbilityPanel);
			ChangeTooltip(lastIndex, true);
		}
	}

	// CheckCustomTooltipOpen();
	
	CheckAltOption();

	$.Msg("Panorama Init Complete!");
}

function CheckAltOption() {
	if (GameUI.IsAltDown() && altDown == false) {
		altDown = true;
		if (lastIndex !== undefined && shown == true) {
			ChangeTooltip(lastIndex, true);
		}
	} else if(!GameUI.IsAltDown() && altDown == true) {
		altDown = false;
		if (lastIndex !== undefined && shown == true) {
			ChangeTooltip(lastIndex, true);
		}
	}
	$.Schedule(1/50, CheckAltOption);
}

function TestShop(arg) {
	$.Msg("Test shop toggle");
	$.Msg(arg);
}

function SetPanelEvents(abilityPanel, abilityLevelUpPanel, index) {
	abilityPanel.SetPanelEvent("onmouseover", function(){ ChangeTooltip(index, true); });
	abilityPanel.SetPanelEvent("onmouseout", function(){ $.Schedule(1 / 6, ChangeTooltipEnd);});

	abilityLevelUpPanel.SetPanelEvent("onmouseover", function(){ ChangeTooltip(index, true); });
	// abilityLevelUpPanel.SetPanelEvent("onmouseout", function(){ $.Schedule(1 / 6, ChangeTooltipEndLevelUp);});
	abilityLevelUpPanel.SetPanelEvent("onmouseout", ChangeTooltipEndLevelUp);
	// abilityPanel.SetPanelEvent("onmouseout", ChangeTooltipEnd);
}

function GetAbilityPanelFromIndex(index) {
	x = abilities.FindChildTraverse("Ability" + index);
	if (x !== null) {
		x = x.FindChildTraverse('ButtonAndLevel');
		x = x.FindChildTraverse('ButtonWithLevelUpTab');
		return x.FindChildTraverse('ButtonWell');
		// return  x.FindChildTraverse('ButtonWithLevelUpTab');
	}
	return null;
}

function GetAbilityLevelUpPanelFromIndex(index) {
	x = abilities.FindChildTraverse("Ability" + index);
	if (x !== null) {
		x = x.FindChildTraverse('ButtonAndLevel');
		x = x.FindChildTraverse('ButtonWithLevelUpTab');
		return x.FindChildTraverse('LevelUpTab');
		// return  x.FindChildTraverse('ButtonWithLevelUpTab');
	}
	return null;
}

// Finished Init
$.Msg("Panorama Loaded!");

function OnAbilityToolTipChanged() {
	if (lastIndex) {
		// ChangeTooltip(lastIndex, false);
	}
}

// Other Functions here
function ChangeTooltip(index, show) {
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var table = CustomNetTables.GetTableValue("generic_ability", "" + mainSelected)["abilities"];
	var abilityTable = [];

	// $.Msg("Change Tooltip!");

	var name = "";
	var title = "Name";
	var description = "Description";
	var lore = "Lore";
	var extra = "";
	var abilityTargetType = 0;
	var abilityTargetTeam = 0;
	var abilityTargetFlags = 0;
	var abilityDamageType = 0;
	var abilityDispelType = 0;
	var abilitySpellImmunityType = 0;
	var abilityBehavior = 0;

	if (!(table[index.toString(10)] !== undefined)) {
		ResetAbilityTooltip();
		return;
	}

	lastIndex = index;
	shown = true;
	var abilityPanel = abilityPanels[index];
	if (show) {
		$.DispatchEvent("DOTAShowAbilityTooltipForLevel", abilityPanel, "generic_ability_layout", 1);
	}

	abilityTable = table[index.toString(10)];

	if (abilityTable["name"] !== undefined) {name = abilityTable["name"]};
	if (abilityTable["title"] !== undefined) {title = abilityTable["title"]};
	if (abilityTable["description"] !== undefined) {description = abilityTable["description"]};
	if (abilityTable["lore"] !== undefined) {lore = abilityTable["lore"]};
	if (abilityTable["extra"] !== undefined) {extra = abilityTable["extra"]};
	if (abilityTable["targetType"] !== undefined) {abilityTargetType = abilityTable["targetType"]};
	if (abilityTable["targetTeam"] !== undefined) {abilityTargetTeam = abilityTable["targetTeam"]};
	if (abilityTable["targetFlags"] !== undefined) {abilityTargetFlags = abilityTable["targetFlags"]};
	if (abilityTable["damageType"] !== undefined) {abilityDamageType = abilityTable["damageType"]};
	if (abilityTable["dispelType"] !== undefined) {abilityDispelType = abilityTable["dispelType"]};
	if (abilityTable["spellImmunity"] !== undefined) {abilitySpellImmunityType = abilityTable["spellImmunity"]};
	if (abilityTable["behavior"] !== undefined) {abilityBehavior = abilityTable["behavior"]};

	// title = Rainbowize(title);
	// var attributeText = GenerateAttributeText(abilityTable, Entities.GetAbilityByName(mainSelected, name))
	
	var ability = Entities.GetAbilityByName(mainSelected, name);
	var level = Abilities.GetLevel(ability);
	var cooldown = GenerateCooldownText(abilityTable);
	var manaCost = GenerateManaCostText(abilityTable);
	var attributes = GenerateAttributeText(abilityTable);

	var dispelType = GenerateAbilityTargetText("Dispel", abilityDispelType);
	var castType = GenerateAbilityTargetText("Cast", abilityBehavior);
	var targetType = GenerateAbilityTargetText("Target", abilityTargetTeam, abilityTargetType);
	var damageType = GenerateAbilityTargetText("Damage", abilityDamageType);
	var spellImmunity = GenerateAbilityTargetText("Spellimmunity", abilitySpellImmunityType);

	GetAbilityLabelFromName("Title").text = title;
	// GetAbilityLabelFromName("Description").text = description;
	GetAbilityLabelFromName("Lore").text = lore;
	GetAbilityLabelFromName("Extra").text = extra;

	// TODO: Make the extra Panel hidden when no extra Text is given.
	// Currently, only hides it for about one second.
	// -> refreshing timer maybe?
	// if(extra == "") {
	// 	var abilityTooltipPanel = GetAbilityTooltipPanel();
	// 	abilityTooltipPanel.RemoveClass("ShowExtraDescription");
	// }
	GetAbilityLabelFromName("ExtraAttributes").text = attributes;
	
	var cooldownValue = abilityTable["cooldown"];
	if (cooldownValue !== "0") {
		GetAbilityLabelFromName("Cooldown").RemoveClass("Hidden");
		GetAbilityLabelFromName("Cooldown").text = cooldown;
	} else {
		GetAbilityLabelFromName("Cooldown").AddClass("Hidden");
	}
	var manaCostValue = abilityTable["manaCost"];
	if (manaCostValue !== "0") {
		GetAbilityLabelFromName("ManaCost").RemoveClass("Hidden");
		GetAbilityLabelFromName("ManaCost").text = manaCost;
	} else {
		GetAbilityLabelFromName("ManaCost").AddClass("Hidden");
	}
	// GetAbilityLabelFromName("Level").text = "Level " + level;
	GetAbilityLabelFromName("Level").text = "Level " + Entities.GetLevel(mainSelected);

	var descriptionPanel = GetAbilityLabelFromName("Description");
	descriptionPanel.RemoveAndDeleteChildren();
	var abilityDescriptionLabel = $.CreatePanel("Label", $.GetContextPanel(), "");
	abilityDescriptionLabel.SetParent(descriptionPanel);
	abilityDescriptionLabel.text = description;
	GenerateAbilityRuneLabels(descriptionPanel, abilityTable);

	if (castType == "") {
		GetAbilityLabelFromName("CastType").AddClass("Hidden");
	} else {
		GetAbilityLabelFromName("CastType").text = castType;
	}
	if (targetType == "") {
		GetAbilityLabelFromName("TargetType").AddClass("Hidden");
	} else {
		// GetAbilityLabelFromName("TargetType").text = targetType;
		// GetAbilityLabelFromName("TargetType").AddClass("Hidden");
	}
	if (damageType == "") {
		GetAbilityLabelFromName("DamageType").AddClass("Hidden");
	} else {
		GetAbilityLabelFromName("DamageType").text = damageType;
	}
	if (spellImmunity == "") {
		GetAbilityLabelFromName("SpellImmunityType").AddClass("Hidden");
	} else {
		GetAbilityLabelFromName("SpellImmunityType").text = spellImmunity;
	}
	if (dispelType == "") {
		GetAbilityLabelFromName("DispelType").AddClass("Hidden");
	} else {
		GetAbilityLabelFromName("DispelType").text = dispelType;
	}

	var abilityKeys = GetAbilityLabelFromName("SpecialKeys");
	if (abilityKeys == null) {
		var abilityTarget = tooltipManager.FindChildTraverse('AbilityTarget');
		abilityKeys = $.CreatePanel("Label", $.GetContextPanel(), "AbilitySpecialKeys");
		abilityKeys.html = true;
		abilityKeys.SetParent(abilityTarget);
	}
	if (abilityTable["behavior"] !== undefined) {
		var keys = abilityTable["specialkeys"];
		var specialKeys = GetSpecialKeys(keys);
		var specialKeyNames = [];
		for (var i = 0; i < specialKeys.length; i++) {
			var key = specialKeys[i];
			specialKeyNames.push("<i>" + GetKeyName(key) + "</i>");
		}
		abilityKeys.text = "KEYS: " + specialKeyNames.join(" | ");
	} else {
		abilityKeys.DeleteAsync(0);
	}

	// TODO:
	// On Level up an ability, make it refresh the tooltip!

	reset = false;
	if (resetSchedule) {
		$.CancelScheduled(resetSchedule, {});
	}
	resetSchedule = $.Schedule(1 / 6, AllowReset);
}

function GetSpecialKeys(keys) {
	var selected = [];
	for (var flag in SPECIAL_KEY_ENUMS) {
		var val = SPECIAL_KEY_ENUMS[flag];
		if ((keys & val) === val) selected.push(flag);
	}
	return selected;
}

function GenerateAbilityRuneLabels(descriptionPanel, abilityTable) {
	var runes = abilityTable["runes"];
	if (!runes) { return; }
	Object.keys(runes).forEach(function(key) {
		var runeName = runes[key];
		var text = $.Localize("DOTA_Tooltip_ability_" + runeName + "_Description");
		var headerPattern = /<h1>(.*?)<\/h1>/;
		var header = headerPattern.exec(text);
		var mainText = text.substring(header[0].length)

		var abilityRuneContainer = $.CreatePanel("Panel", $.GetContextPanel(), "RuneContainer");
		abilityRuneContainer.SetParent(descriptionPanel);
		abilityRuneContainer.style.flowChildren = "none";

		var abilityRuneDescriptionContainer = $.CreatePanel("Panel", $.GetContextPanel(), "RuneDescriptionContainer");
		abilityRuneDescriptionContainer.SetParent(abilityRuneContainer);
		abilityRuneDescriptionContainer.style.flowChildren = "down";

		var abilityRuneHeaderLabel = $.CreatePanel("Label", $.GetContextPanel(), "");
		abilityRuneHeaderLabel.SetParent(abilityRuneDescriptionContainer);
		abilityRuneHeaderLabel.AddClass("Header");
		abilityRuneHeaderLabel.style.textShadow = "2px 2px 0px 1.0 #00000090";
		// abilityRuneHeaderLabel.text = $.Localize("DOTA_Tooltip_ability_" + runeName);
		abilityRuneHeaderLabel.text = header[1];

		var abilityRuneLabel = $.CreatePanel("Label", $.GetContextPanel(), "");
		abilityRuneLabel.SetParent(abilityRuneDescriptionContainer);
		abilityRuneLabel.style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #1c262f ), to( #1b262f ) )";
		abilityRuneLabel.style.textShadow = "2px 2px 0px 1.0 #00000090";
		abilityRuneLabel.html = true;
		abilityRuneLabel.text = "<font color='#626d7b'>" + mainText + "</font>";

		if (GameUI.IsAltDown()) {
			var runeAttributes = GenerateRuneAttributeText(abilityTable, runeName);
			abilityRuneLabel.text = "<font color='#626d7b'>" + mainText + "</font>" + "<br><br>" + runeAttributes;
		}
	});
	// for (var i = 1; i <= Object.keys(runes).length; i++) {
	// 	var runeName = runes[i.toString(10)];
	// 	var abilityRuneHeaderLabel = $.CreatePanel("Label", $.GetContextPanel(), "");
	// 	abilityRuneHeaderLabel.SetParent(descriptionPanel);
	// 	abilityRuneHeaderLabel.AddClass("Header");
	// 	abilityRuneHeaderLabel.text = $.Localize("DOTA_Tooltip_ability_" + runeName);

	// 	var abilityRuneLabel = $.CreatePanel("Label", $.GetContextPanel(), "");
	// 	abilityRuneLabel.SetParent(descriptionPanel);
	// 	abilityRuneLabel.style.backgroundColor = "gradient( linear, 0% 0%, 0% 100%, from( #1c262f ), to( #1b262f ) )";
	// 	abilityRuneLabel.text = $.Localize("DOTA_Tooltip_ability_" + runeName + "_Description");
	// }
}

function GenerateAbilityTargetText(type, val, opt) {
	switch (type) {
		case "Dispel":
			return GetAbilityTargetString("Dispel", val);
		case "Cast":
			return GetAbilityTargetString("Cat", val);
		case "Target":
			return GetAbilityTargetString("Target", val, opt);
		case "Damage":
			return GetAbilityTargetString("Damage", val);
		case "Spellimmunity":
			return GetAbilityTargetString("Spellimmunity", val);

	}
	return "";
}

function GetAbilityTargetString(key, val, opt) {
	var text = "";
	var title = "";
	switch(key) {
		case "Dispel":
			title = $.Localize("#DOTA_AbilityTooltip_DispelType_Custom");
			if (val & DOTA_ABILITY_DISPEL_TYPE_NO) {
				text += $.Localize("DOTA_AbilityTooltip_DispelType_Custom_No");
			} else if (val & DOTA_ABILITY_DISPEL_TYPE_YES) {
				text += $.Localize("DOTA_AbilityTooltip_DispelType_Custom_Yes");
			} else if (val & DOTA_ABILITY_DISPEL_TYPE_STRONG) {
				text += $.Localize("DOTA_AbilityTooltip_DispelType_Custom_Strong");
			}
			if (text !== "") {
				text = title + text;
			}
			break;
		case "Cast":
			title = $.Localize("#DOTA_AbilityTooltip_CastType_Custom");
			if (val & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_PASSIVE) {
				text += $.Localize("#DOTA_AbilityTooltip_CastType_Custom_Passive");
			}
			if(val & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_AURA) {
				text += $.Localize("#DOTA_AbilityTooltip_CastType_Custom_Aura");
			}
			if(val & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_NO_TARGET) {
				text += $.Localize("#DOTA_AbilityTooltip_CastType_Custom_None");
			} else if(val & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) {
				text += $.Localize("#DOTA_AbilityTooltip_CastType_Custom_Unit");
			} else if(val & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_POINT) {
				text += $.Localize("#DOTA_AbilityTooltip_CastType_Custom_Point");
			}
			if(val & DOTA_ABILITY_BEHAVIOR.DOTA_ABILITY_BEHAVIOR_CHANNELLED) {
				text += $.Localize("#DOTA_AbilityTooltip_CastType_Custom_Channel");
			}
			if (text !== "") {
				text = title + text;
			}
			break;
		case "Target":
			title = $.Localize("#DOTA_AbilityTooltip_TargetType_Custom");
			if (opt & DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_FRIENDLY) {
				text += $.Localize("DOTA_AbilityTooltip_TargetType_Custom_Allied") + " ";
			} else if(opt & DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_ENEMY) {
				text += $.Localize("#DOTA_AbilityTooltip_TargetType_Custom_Enemy") + " ";
			}
			if (opt & DOTA_UNIT_TARGET_TEAM.DOTA_UNIT_TARGET_TEAM_BOTH) {
				text = "";
			}
			if (val & DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO) {
				text += $.Localize("#DOTA_AbilityTooltip_TargetType_Custom_Hero");
			} else if(val & DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_HERO) {
				text += $.Localize("#DOTA_AbilityTooltip_TargetType_Custom_Building");
			} else if(val & DOTA_UNIT_TARGET_TYPE.DOTA_UNIT_TARGET_NONE){
				text = "";
			} else {
				text += $.Localize("#DOTA_AbilityTooltip_TargetType_Custom_Unit");
			}
			if (text !== "") {
				text = title + text;
			}
			break;
		case "Damage":
			title = $.Localize("#DOTA_AbilityTooltip_DamageType_Custom");
			if (val & DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL) {
				text += $.Localize("#DOTA_AbilityTooltip_DamageType_Custom_Magical");
			} else if(val & DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL) {
				text += $.Localize("#DOTA_AbilityTooltip_DamageType_Custom_Physical");
			} else if(val & DAMAGE_TYPES.DAMAGE_TYPE_PURE) {
				text += $.Localize("#DOTA_AbilityTooltip_DamageType_Custom_Pure");
			} else if(val & DAMAGE_TYPES.DAMAGE_TYPE_NONE) {
				text = "";
			}
			if (text !== "") {
				text = title + text;
			}
			break;
		case "Spellimmunity":
			title = $.Localize("#DOTA_AbilityTooltip_SpellImmunityType_Custom");
			if ((val & SPELL_IMMUNITY_TYPES.SPELL_IMMUNITY_ALLIES_YES) || (val & SPELL_IMMUNITY_ENEMIES_YES)) {
				text += $.Localize("#DOTA_AbilityTooltip_SpellImmunityType_Custom_Yes");
			} else if ((val & SPELL_IMMUNITY_TYPES.SPELL_IMMUNITY_ALLIES_NO) || (val & SPELL_IMMUNITY_ENEMIES_NO)){
				text += $.Localize("#DOTA_AbilityTooltip_SpellImmunityType_Custom_No");
			}
			if (text !== "") {
				text = title + text;
			}
			break;
	}
	return text;
}

function GetKeyName(key) {
	switch (key) {
		case "SPECIAL_ABILITY_KEY_UNIT":
			return "Unit Target";
		case "SPECIAL_ABILITY_KEY_SELF":
			return "Self Target";
		case "SPECIAL_ABILITY_KEY_POINT":
			return "Point Target";
		case "SPECIAL_ABILITY_KEY_PASSIVE":
			return "Passive";
		case "SPECIAL_ABILITY_KEY_LINEAR_PROJECTILE":
			return "Linear Projectile";
		case "SPECIAL_ABILITY_KEY_TRACKING_PROJECTILE":
			return "Tracking Projectile";
		case "SPECIAL_ABILITY_KEY_SINGLE_TARGET":
			return "Single Target";
		case "SPECIAL_ABILITY_KEY_MULTI_TARGET":
			return "Multiple Targets";
		case "SPECIAL_ABILITY_KEY_AOE":
			return "AoE";
		case "SPECIAL_ABILITY_KEY_SUMMON":
			return "Summon";
		case "SPECIAL_ABILITY_KEY_DAMAGE":
			return "Damage";
		case "SPECIAL_ABILITY_KEY_HEAL":
			return "Heal";
		case "SPECIAL_ABILITY_KEY_BUFF":
			return "Buff";
		case "SPECIAL_ABILITY_KEY_DURATION":
			return "Has Duration";
		case "SPECIAL_ABILITY_KEY_DEBUFF":
			return "Debuff";
		case "SPECIAL_ABILITY_KEY_BOMB":
			return "Bomb";	
	}
	return "";
}

function GenerateAttributeText(abilityTable) {
	var attributes = [];
	if (abilityTable["attributes"] !== undefined) {attributes = abilityTable["attributes"];};
	var lines = [];
	for (var i = 0; i <= Object.keys(attributes).length; i++) {
		var attr = attributes[i.toString(10)];
		if (attr !== undefined) {
			var valName = "Val";
			if (GameUI.IsAltDown()) {valName = "ActualVal"}
			// var values = MarkValueForLevel(attr[valName], level);
			var values = ShowValuesWithGrow(attr[valName], attr["Grow"])
			lines.push(attr["Key"] + ": <font color='#4b535e'>" + values + "</font>");
		}
	}
	var newText = "";
	for (var i = 0; i < lines.length; i++) {
		newText += lines[i];
		if (!(i == lines.length - 1)) {
			newText += "<br>";
		}
	}
	return newText;
}

function GenerateCooldownText(abilityTable) {
	var cooldown = "0";
	// if (!(abilityTable.actualValues)) {return ""}
	// if (abilityTable["cooldown"] !== undefined) {cooldown = abilityTable.actualValues.cooldown;};
	if (abilityTable["cooldown"] !== undefined) {cooldown = abilityTable.cooldown;};
	cooldown = ReplaceRelativeString(abilityTable, cooldown);
	// cooldown = MarkValueForLevel(cooldown, level);
	cooldown = ShowValuesWithGrow(cooldown)
	return cooldown;
}

function GenerateManaCostText(abilityTable) {
	var manaCost = "0";
	// if (!(abilityTable.actualValues)) {return ""}
	// if (abilityTable["manaCost"] !== undefined) {manaCost = abilityTable.actualValues.manaCost;};
	if (abilityTable["manaCost"] !== undefined) {manaCost = abilityTable.manaCost;};
	manaCost = ReplaceRelativeString(abilityTable, manaCost);
	// manaCost = MarkValueForLevel(manaCost, level);
	manaCost = ShowValuesWithGrow(manaCost)
	return manaCost;
}

function GenerateRuneAttributeText(abilityTable, runeName) {
	var attributes = [];
	var pattern = /.*ability_rune_\w+?_(\w+)/;
	var shortRuneName = runeName.match(pattern)[1];
	if (!abilityTable.runeAttributes[shortRuneName]) {return ""; };
	if (abilityTable["attributes"] !== undefined) {attributes = abilityTable.runeAttributes[shortRuneName];};
	var lines = [];
	for (var i = 0; i <= Object.keys(attributes).length; i++) {
		var attr = attributes[i.toString(10)];
		if (attr !== undefined) {
			var valName = "Val";
			var values = MarkValueForLevel(attr[valName], 1);
			lines.push(attr["Key"] + ": <font color='#4b535e'>" + values + "</font>");
		}
	}
	var newText = "";
	for (var i = 0; i < lines.length; i++) {
		newText += lines[i];
		if (!(i == lines.length - 1)) {
			newText += "<br>";
		}
	}
	return newText;
}

function MarkValueForLevel(values, level) {
	var valArr = values.split(" ");
	var newText = "";
	for (var i = 0; i < valArr.length; i++) {
		valArr[i] = ShortenNumber(valArr[i]);
	}
	if (valArr.length >= level) {
		valArr[level - 1] = "<font color='#ffffff'><b>" + valArr[level - 1] + "</b></font>"
		for (var i = 0; i < valArr.length; i++) {
			newText += valArr[i] + " / ";
		}
		newText = newText.substring(0, newText.length - 3);
	} else {
		newText = "<font color='#ffffff'><b>" + values + "</b></font>";
	}
	return newText;
}

function ShowValuesWithGrow(value, grow) {
	var val = ShortenNumber(value);
	growText = "";
	if (grow !== undefined) {
		if (grow !== "0") {
			growText = " (";
			if (Number(grow) > 0) {
				growText += "+" + grow
			} else {
				growText += grow
			}
			growText += ")"
		}
	}
	return "<font color='#ffffff'><b>" + val + "</b></font>" + growText;
}

function ShortenNumber(number) {
  number = number.toString(10);
  var index = number.indexOf(".");
  if (index > 0) {
	number = parseFloat(number).toFixed(3);
	var lastChar = "";
	do {
	  lastChar = number.substring(number.length - 1, number.length);
	  if (lastChar == "0" || lastChar == ".") {
		number = number.substring(0, number.length - 1);
	  }
	} while (lastChar == "0")
  }
  return number;
}

function ReplaceRelativeString(abilityTable, str) {
  if (str.indexOf("%") >= 0) {
	var pattern = /\w+/i;
	var newStr = str.match(pattern);
	if (newStr) {
	  var attribute = FindAttribute(abilityTable, newStr);
	  if (attribute) {
		str = attribute.ActualVal;
	  } else {
		str = "";
	  }
	}
  }
  return str;
}

function FindAttribute(tab, attrName) {
  var attr;
  Object.keys(tab.attributes).forEach(function(key) {
	var attribute = tab.attributes[key];
	var name = attribute["Name"];
	if (name == attrName) {
	  attr = attribute;
	}
  });
  return attr;
}

function RecolorText() {
	if (RAINBOW_COLOR_TITLE) {
		var title = GetAbilityLabelFromName("Title")
		if (title) {
			var oldText = title.text
			title.text = "#DOTA_AbilityTooltip_Name";
			var text = title.text;
			if (text = "GENERIC ABILITY LAYOUT") {
				text = oldText;
			}
			text = Rainbowize(text);
			title.text = text;
		}
	}
	if (RAINBOW_COLOR_DESC) {
		// if (GetAbilityLabelFromName("Description")) {
		// 	// GetAbilityLabelFromName("Title").text = "#DOTA_AbilityTooltip_Name";
		// 	var text = GetAbilityLabelFromName("Description").text;
		// 	text = Rainbowize(text);
		// 	GetAbilityLabelFromName("Description").text = text;
		// }
	}
	if (RAINBOW_COLOR_LORE) {
		if (GetAbilityLabelFromName("Lore")) {
			GetAbilityLabelFromName("Lore").text = "#DOTA_AbilityTooltip_Lore";
			var text = GetAbilityLabelFromName("Lore").text;
			text = Rainbowize(text);
			GetAbilityLabelFromName("Lore").text = text;
		}
	}
	if (RAINBOW_COLOR_ATTR) {
		if (GetAbilityLabelFromName("Attributes")) {
			GetAbilityLabelFromName("Attributes").text = "#DOTA_AbilityTooltip_Attributes";
			var text = GetAbilityLabelFromName("Attributes").text;
			text = Rainbowize(text);
			GetAbilityLabelFromName("Attributes").text = text;
		}
	}
	if (RAINBOW_COLOR_ATTR_EXTRA) {
		if (GetAbilityLabelFromName("ExtraAttributes")) {
			GetAbilityLabelFromName("ExtraAttributes").text = "#DOTA_AbilityTooltip_ExtraAttributes";
			var text = GetAbilityLabelFromName("ExtraAttributes").text;
			text = Rainbowize(text);
			GetAbilityLabelFromName("ExtraAttributes").text = text;
		}
	}
}

function AllowReset() {
	resetSchedule = undefined;
	reset = true;
}

function ChangeTooltipEnd() {
	if (reset) {
		ResetAbilityTooltip();
	}
}

function ChangeTooltipEndLevelUp() {
	if (lastIndex !== undefined) {
		var hideAbilityPanel = abilityPanels[lastIndex];
		$.DispatchEvent("DOTAHideAbilityTooltip", hideAbilityPanel);
	}
	$.Schedule(1 / 6, ChangeTooltipEnd);
}

// function CheckCustomTooltipOpen() {
// 	if (!shown) {
// 		$.Msg("Check .. Reset");
// 		ResetAbilityTooltip(true);
// 		// $.Schedule(1, CheckCustomTooltipOpen);
// 	} else {
// 		$.Msg("Check .. No Reset");
// 		// $.Schedule(1, CheckCustomTooltipOpen);
// 	}
// }

function ResetAbilityTooltip() {
	// $.Msg("Reset!");
	shown = false;
	if (!GetAbilityLabelFromName("Title")) {
		return;
	}
	GetAbilityLabelFromName("Title").text = "#DOTA_AbilityTooltip_Name";
	GetAbilityLabelFromName("Level").text = "#DOTA_AbilityTooltip_Level";
	GetAbilityLabelFromName("CastType").text = "#DOTA_AbilityTooltip_CastType";
	GetAbilityLabelFromName("TargetType").text = "#DOTA_AbilityTooltip_TargetType";
	GetAbilityLabelFromName("DamageType").text = "#DOTA_AbilityTooltip_DamageType";
	GetAbilityLabelFromName("SpellImmunityType").text = "#DOTA_AbilityTooltip_SpellImmunityType";
	GetAbilityLabelFromName("DispelType").text = "#DOTA_AbilityTooltip_DispelType";
	GetAbilityLabelFromName("ExtraAttributes").text = "#DOTA_AbilityTooltip_ExtraAttributes";
	GetAbilityLabelFromName("Attributes").text = "#DOTA_AbilityTooltip_Attributes"
	// GetAbilityLabelFromName("Description").text = "#DOTA_AbilityTooltip_Description";
	GetAbilityLabelFromName("Lore").text = "#DOTA_AbilityTooltip_Lore";
	GetAbilityLabelFromName("Extra").text = "#DOTA_AbilityTooltip_ExtraDescription";
	GetAbilityLabelFromName("Cooldown").text = "#DOTA_AbilityTooltip_Cooldown";
	GetAbilityLabelFromName("ManaCost").text = "#DOTA_AbilityTooltip_ManaCost";

	var specialKeys = GetAbilityLabelFromName("SpecialKeys");
	if (specialKeys != null) {
		specialKeys.DeleteAsync(0);
	}
}

function GetAbilityTooltipPanel() {
	x = tooltipManager.FindChildTraverse('DOTAAbilityTooltip');
	x = x.FindChildrenWithClassTraverse('TooltipRow');
	x = x[0].FindChildTraverse('Contents');
	var abilityTooltip = x.FindChildTraverse('AbilityDetails');

	return abilityTooltip;
	// switch (name) {
	// 	case "Core":
	// 		return x.FindChildTraverse('AbilityCoreDetails');
	// }
	// return null;
}

function GetAbilityLabelFromName(name) {
	x = tooltipManager.FindChildTraverse('DOTAAbilityTooltip');
	if (!x) {return null};
	x = x.FindChildrenWithClassTraverse('TooltipRow');
	if (!x) {return null};
	x = x[0].FindChildTraverse('Contents');
	var abilityTooltip = x.FindChildTraverse('AbilityDetails');

	switch (name) {
		case "Title":
			x = x.FindChildTraverse('Header');
			x = x.FindChildTraverse('HeaderLabels');
			x = x.FindChildTraverse('AbilityHeader');
			return x.FindChildTraverse('AbilityName');
		case "Level":
			x = x.FindChildTraverse('Header');
			x = x.FindChildTraverse('HeaderLabels');
			x = x.FindChildTraverse('AbilityHeader');
			return x.FindChildTraverse('AbilityLevel');
		case "CastType":
			x = x.FindChildTraverse('AbilityTarget');
			x = x.FindChildTraverse('AbilityTopRowContainer');
			return x.FindChildTraverse('AbilityCastType');
		case "TargetType":
			x = x.FindChildTraverse('AbilityTarget');
			return x.FindChildTraverse('AbilityTargetType');
		case "DamageType":
			x = x.FindChildTraverse('AbilityTarget');
			return x.FindChildTraverse('AbilityDamageType');
		case "SpellImmunityType":
			x = x.FindChildTraverse('AbilityTarget');
			return x.FindChildTraverse('AbilitySpellImmunityType');
		case "DispelType":
			x = x.FindChildTraverse('AbilityTarget');
			return x.FindChildTraverse('AbilityDispelType');
		case "SpecialKeys":
			x = x.FindChildTraverse('AbilityTarget');
			return x.FindChildTraverse('AbilitySpecialKeys');
		case "ExtraAttributes":
			x = x.FindChildTraverse('AbilityCoreDetails');
			return x.FindChildTraverse('AbilityExtraAttributes');
		case "Description":
			x = x.FindChildTraverse('AbilityCoreDetails');
			x = x.FindChildTraverse('AbilityDescriptionOuterContainer');
			x = x.FindChildTraverse('AbilityDescriptionContainer');
			return x;
			// return x.Children()[0];
		case "Lore":
			x = x.FindChildTraverse('AbilityCoreDetails');
			return x.FindChildTraverse('AbilityLore');
		case "Extra":
			x = x.FindChildTraverse('AbilityCoreDetails');
			return x.FindChildTraverse('AbilityExtraDescription');
		case "Attributes":
			x = x.FindChildTraverse('AbilityCoreDetails');
			return x.FindChildTraverse('AbilityAttributes');
		case "Cooldown":
			x = x.FindChildTraverse('AbilityCoreDetails');
			x = x.FindChildTraverse('AbilityCosts');
			return x.FindChildTraverse('AbilityCooldown');
		case "ManaCost":
			x = x.FindChildTraverse('AbilityCoreDetails');
			x = x.FindChildTraverse('AbilityCosts');
			return x.FindChildTraverse('AbilityManaCost');
	}
	return null;
}

function Rainbowize(text) {
	text = ClearColors(text);
	var newText = "";
	for (var i = 0; i < text.length; i++) {
		newText += ColorChar(text, i);
	}
	return newText;
}

function ColorChar(text, index) {
	var char = text.charAt(index);
	return "<font color='" + GetColor(index) + "'>" + char + "</font>";
}

function ClearColors(text) {
	var reg = /<font color=\'#([0-9]|[a-f])*\'>(.*?)<\/font>/gi;
	//var reg = new RegExp("<font color=\'#([0-9]|[a-f])*\'>(.*?)<\/font>", "gi");
	return text.replace(reg, "$2");
}

function GetColor(index) {
	return rainbow[(index + rainbowStart) % rainbow.length];
}

function SinToHex(i, phase, size) {
	var sin = Math.sin(Math.PI / size * 2 * i + phase);
	var int = Math.floor(sin * 127) + 128;
	var hex = int.toString(16);

	return hex.length === 1 ? "0" + hex : hex;
}

function GenerateColor(size) {
	$.Msg("Generating new Rainbow Color Palette")
	var tempRainbow = new Array(size);

	for (var i=0; i<size; i++) {
		var red   = SinToHex(i, 0 * Math.PI * 2/3, size); // 0   deg
		var blue  = SinToHex(i, 1 * Math.PI * 2/3, size); // 120 deg
		var green = SinToHex(i, 2 * Math.PI * 2/3, size); // 240 deg
	
		tempRainbow[i] = "#"+ red + green + blue;
	}
	rainbow = tempRainbow
}

function RainbowInc() {
	RecolorText();
	started = true;
	rainbowStart += 1;
	if (rainbowStart > (rainbow.length - 1)) {rainbowStart = 0};
	$.Schedule(0.1, RainbowInc);
}

(function () {
	GameEvents.Subscribe( "init_tooltips", InitializeTooltips );
})();