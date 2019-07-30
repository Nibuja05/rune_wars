var CONTINUE_PROCESSING_EVENT = false;

var DOTA_ABILITY_DISPEL_TYPE_NONE = 0;
var DOTA_ABILITY_DISPEL_TYPE_NO = 1;
var DOTA_ABILITY_DISPEL_TYPE_YES = 2;
var DOTA_ABILITY_DISPEL_TYPE_STRONG = 4;

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

// var rainbow = ["#9400D3", "#4B0082", "#0000FF", "#00FF00", "#00FF00", "#FF7F00", "#FF0000"];
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
		abilityPanel = GetAbilityPanelFromIndex(index);
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
				SetPanelEvents(abilityPanel, 0)
				break;
			case 1:
				SetPanelEvents(abilityPanel, 1)
				break;
			case 2:
				SetPanelEvents(abilityPanel, 2)
				break;
			case 3:
				SetPanelEvents(abilityPanel, 3)
				break;
			case 4:
				SetPanelEvents(abilityPanel, 4)
				break;
			case 5:
				SetPanelEvents(abilityPanel, 5)
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

	$.Msg("SHOW: " + shown)
	if (shown) {
		if (lastIndex !== undefined) {
			var abilityPanel = abilityPanels[lastIndex];
			$.DispatchEvent("DOTAHideAbilityTooltip", abilityPanel);
			ChangeTooltip(lastIndex, true);
		}
	}

	$.Msg("Panorama Init Complete!");
}

function SetPanelEvents(abilityPanel, index) {
	abilityPanel.SetPanelEvent("onmouseover", function(){ ChangeTooltip(index, true); });
	abilityPanel.SetPanelEvent("onmouseout", function(){ $.Schedule(1 / 6, ChangeTooltipEnd);});
}

function GetAbilityPanelFromIndex(index) {
	x = abilities.FindChildTraverse("Ability" + index);
	if (x !== null) {
		x = x.FindChildTraverse('ButtonAndLevel');
		return  x.FindChildTraverse('ButtonWithLevelUpTab');
	}
	return null;
}

// Finished Init
$.Msg("Panorama Loaded!");

function OnAbilityToolTipChanged() {
	if (lastIndex) {
		ChangeTooltip(lastIndex, false);
	}
}

// Other Functions here
function ChangeTooltip(index, show) {
	var mainSelected = Players.GetLocalPlayerPortraitUnit();
	var table = CustomNetTables.GetTableValue("generic_ability", "" + mainSelected)["abilities"];
	var abilityTable = [];

	var name = "";
	var title = "Name";
	var description = "Description";
	var lore = "Lore";
	var extra = "Extra";
	var abilityTargetType = 0;
	var abilityTargetTeam = 0;
	var abilityTargetFlags = 0;
	var abilityDamageType = 0;
	var abilityDispelType = 0;
	var abilitySpellImmunityType = 0;
	var abilityBehavior = 0;

	if (table[index.toString(10)] !== undefined) {

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
	} else {
		ResetAbilityTooltip();
		return;
	}

	// title = Rainbowize(title);
	// var attributeText = GenerateAttributeText(abilityTable, Entities.GetAbilityByName(mainSelected, name))
	
	var ability = Entities.GetAbilityByName(mainSelected, name);
	$.Msg(ability);
	var level = Abilities.GetLevel(ability);
	var cooldown = GenerateCooldownText(abilityTable, level);
	var manaCost = GenerateManaCostText(abilityTable, level);
	var attributes = GenerateAttributeText(abilityTable, level);

	var dispelType = GenerateAbilityTargetText("Dispel", abilityDispelType);
	var castType = GenerateAbilityTargetText("Cast", abilityBehavior);
	var targetType = GenerateAbilityTargetText("Target", abilityTargetTeam, abilityTargetType);
	var damageType = GenerateAbilityTargetText("Damage", abilityDamageType);
	var spellImmunity = GenerateAbilityTargetText("Spellimmunity", abilitySpellImmunityType);

	GetAbilityLabelFromName("Title").text = title;
	GetAbilityLabelFromName("Description").text = description;
	GetAbilityLabelFromName("Lore").text = lore;
	GetAbilityLabelFromName("Extra").text = extra;
	GetAbilityLabelFromName("ExtraAttributes").text = attributes;
	GetAbilityLabelFromName("Cooldown").text = cooldown;
	GetAbilityLabelFromName("ManaCost").text = manaCost;
	GetAbilityLabelFromName("Level").text = "Level " + level;

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

	// TODO:
	// On Level up an ability, make it refresh the tooltip!

	reset = false;
	$.Schedule(1 / 5, AllowReset);
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
			$.Msg(val);
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

function GenerateAttributeText(abilityTable, level) {
	var attributes = [];
	if (abilityTable["attributes"] !== undefined) {attributes = abilityTable["attributes"];};
	var lines = [];
	for (var i = 0; i <= Object.keys(attributes).length; i++) {
		var attr = attributes[i.toString(10)];
		if (attr !== undefined) {
			var values = MarkValueForLevel(attr["Val"], level);
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

function GenerateCooldownText(abilityTable, level) {
	var cooldown = "0";
	if (abilityTable["cooldown"] !== undefined) {cooldown = abilityTable["cooldown"];};
	cooldown = MarkValueForLevel(cooldown, level);
	return cooldown;
}

function GenerateManaCostText(abilityTable, level) {
	var manaCost = "0";
	if (abilityTable["manaCost"] !== undefined) {manaCost = abilityTable["manaCost"];};
	manaCost = MarkValueForLevel(manaCost, level);
	return manaCost;
}

function MarkValueForLevel(values, level) {
	var valArr = values.split(" ");
	var newText = "";
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
		if (GetAbilityLabelFromName("Description")) {
			// GetAbilityLabelFromName("Title").text = "#DOTA_AbilityTooltip_Name";
			var text = GetAbilityLabelFromName("Description").text;
			text = Rainbowize(text);
			GetAbilityLabelFromName("Description").text = text;
		}
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
	reset = true;
}

function ChangeTooltipEnd() {
	if (reset) {
		ResetAbilityTooltip();
	}
}

function ResetAbilityTooltip() {
	shown = false;
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
}

function GetAbilityPanelFromName(name) {
	x = tooltipManager.FindChildTraverse('DOTAAbilityTooltip');
	x = x.FindChildrenWithClassTraverse('TooltipRow');
	x = x[0].FindChildTraverse('Contents');
	var abilityTooltip = x.FindChildTraverse('AbilityDetails');

	switch (name) {
		case "Core":
			return x.FindChildTraverse('AbilityCoreDetails');
	}
	return null;
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
		case "ExtraAttributes":
			x = x.FindChildTraverse('AbilityCoreDetails');
			return x.FindChildTraverse('AbilityExtraAttributes');
		case "Description":
			x = x.FindChildTraverse('AbilityCoreDetails');
			x = x.FindChildTraverse('AbilityDescriptionOuterContainer');
			x = x.FindChildTraverse('AbilityDescriptionContainer');
			return x.Children()[0];
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