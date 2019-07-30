// Find HUD Elements
var base = $.GetContextPanel().GetParent().GetParent().GetParent();
var tooltipManager = base.FindChildTraverse('Tooltips');
var abilityPanels = [];

var rainbow = [];
var rainbowStart = 0;

var RAINBOW_COLOR_TITLE = true;
var RAINBOW_COLOR_DESC = false;
var RAINBOW_COLOR_LORE = false;
var RAINBOW_COLOR_ATTR = false;
var RAINBOW_COLOR_ATTR_EXTRA = false;
var RAINBOW_DENSITY = 20;

function InitializeTooltips() {

	//Init Rainbow Maker
	GenerateColor(RAINBOW_DENSITY);
	RainbowInc();

	$.Msg("Rainbow Init Complete!");
}

function RecolorText() {

	if (RAINBOW_COLOR_TITLE) {
		if (GetAbilityLabelFromName("Title")) {
			GetAbilityLabelFromName("Title").text = "#DOTA_AbilityTooltip_Name";
			var text = GetAbilityLabelFromName("Title").text;
			text = Rainbowize(text);
			GetAbilityLabelFromName("Title").text = text;
			lastTitle = ClearColors(text);
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

function GetAbilityLabelFromName(name) {
	x = tooltipManager.FindChildTraverse('DOTAAbilityTooltip');
	x = x.FindChildrenWithClassTraverse('TooltipRow');
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
	rainbowStart += 1;
	if (rainbowStart > (rainbow.length - 1)) {rainbowStart = 0};
	$.Schedule(0.1, RainbowInc);
}

(function () {
	GameEvents.Subscribe( "init_tooltips", InitializeTooltips );
})();