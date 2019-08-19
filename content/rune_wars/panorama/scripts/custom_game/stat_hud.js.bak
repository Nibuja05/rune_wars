
$.Msg("Custom Stat Hud loading!!!")

// Find HUD Elements
var base = $.GetContextPanel().GetParent().GetParent().GetParent();
var x = base.FindChildTraverse('HUDElements');
x = x.FindChildTraverse('lower_hud');
x = x.FindChildTraverse('center_with_stats');
x = x.FindChildTraverse('center_block');
var stats = x.FindChildTraverse('stats_container');
var tooltipManager = base.FindChildTraverse('Tooltips');

// ============================================================================================
// Init
// ============================================================================================

function AdjustStatHud() {
	CreateSmallAttributes();
	CreateStatTooltip();
	CustomNetTables.SubscribeNetTableListener("element_resist", UpdateStats);
}

// ============================================================================================
// Update
// ============================================================================================

function UpdateStats(tableName, tableKey, table) {
	var elementSort = {}
	var pattern = /(\w+)?([A-Z]\w+)/;
	for (var name in table) {
		var value = table[name];
		var match = pattern.exec(name);
		if (!elementSort[match[1]]) {
			elementSort[match[1]] = {}
		}
		elementSort[match[1]][match[2]] = value;
	}
	for (var key in elementSort) {
		var entry = elementSort[key];
		// UpdateAttributs(key, entry["Power"], entry["Resistance"]);
		// UpdateSmallAttributes(key, entry["Power"], entry["Resistance"]);
	}
}

function UpdateAttributs(name, power, resist) {
	var statPanel = GetTooltipStatPanel();
	var attributes = statPanel.FindChildTraverse('AttributesContainer');
	var attributePanel = attributes.FindChildTraverse(name + "Container");
	$.Msg(attributePanel);
}

function UpdateSmallAttributes(name, power, resist) {
	var attributePanel = $("#Small" + name + "Container");
	$.Msg(attributePanel);
}

// ============================================================================================
// Create
// ============================================================================================

function CreateStatTooltip() {
	var statPanel = GetTooltipStatPanel();
	if (statPanel) {
		$.Msg("Adjust Stat Tooltip!");
		var attackDefense = statPanel.FindChildTraverse('AttackDefenseContainer');
		attackDefense.style.height = "140px";
		var attack = attackDefense.FindChildTraverse('AttackContainer');
		attack.FindChildTraverse('AttackRangeRow').RemoveAndDeleteChildren();
		attack.FindChildTraverse('SpellAmpRow').RemoveAndDeleteChildren();;
		var defense = attackDefense.FindChildTraverse('DefenseContainer');
		defense.FindChildTraverse('ArmorRow').RemoveAndDeleteChildren();
		defense.FindChildTraverse('MagicResistRow').RemoveAndDeleteChildren();

		var attributes = statPanel.FindChildTraverse('AttributesContainer');
		var strength = attributes.FindChildTraverse('StrengthContainer');
		strength.AddClass("Hidden")
		strength.style.height = "0px";
		var agility = attributes.FindChildTraverse('AgilityContainer');
		agility.AddClass("Hidden")
		agility.style.height = "0px";
		var intel = attributes.FindChildTraverse('IntelligenceContainer');
		intel.AddClass("Hidden")
		intel.style.height = "0px";
		attributes.style.height = "450px";

		CreateNewAttributePanel(attributes, "Fire");
		CreateNewAttributePanel(attributes, "Water");
		CreateNewAttributePanel(attributes, "Earth");
		CreateNewAttributePanel(attributes, "Storm");
		CreateNewAttributePanel(attributes, "Order");
		CreateNewAttributePanel(attributes, "Chaos");
	} else {
		$.Schedule(0.1, CreateStatTooltip)
	}
}

function GetTooltipStatPanel() {
	var x = tooltipManager.FindChildTraverse('DOTAHUDDamageArmorTooltip');
	if (x == undefined || x == null) {return null}
	x = x.FindChildrenWithClassTraverse('TooltipRow');
	return x[0].FindChildTraverse('Contents');
}

function CreateNewAttributePanel(parent, name) {
	if (parent.FindChildTraverse(name + "Container")) {
		var oldAttr = parent.FindChildTraverse(name + "Container");
		oldAttr.DeleteAsync(0);
	}
	var newAttr = $.CreatePanel("Panel", $.GetContextPanel(), name + "Container");
	newAttr.SetParent(parent);
	newAttr.AddClass('LeftRightFlow');
	newAttr.AddClass('AttributeRow');
	newAttr.style.marginLeft = "6px";
	newAttr.style.marginBottom = "6px";
	newAttr.style.backgroundColor = "gradient( linear, 90% 0%, 0% 0%, from(#000), to(" + GetElementColor(name) + "))";
	var newIcon = $.CreatePanel("Panel", newAttr, name + "Icon");
	newIcon.AddClass('AttributeIcon');
	var imageName = 'url("file://{images}/custom_game/' + name.toLowerCase() + '.png")';
	newIcon.style.backgroundImage = imageName;
	var newDetails = $.CreatePanel("Panel", newAttr, name + "DetailsContainer");
	newDetails.AddClass('AttributeDetails');
	newDetails.AddClass('TopBottomFlow');
	var newAttributeValues = $.CreatePanel("Panel", $.GetContextPanel(), "AttributeValues");
	newAttributeValues.SetParent(newDetails);
	newAttributeValues.AddClass('LeftRightFlow');

	var newAttributeText = $.CreatePanel("Label", $.GetContextPanel(), "Base" + name + "Label");
	newAttributeText.SetParent(newAttributeValues);
	newAttributeText.AddClass('BaseAttributeValue');
	newAttributeText.text = name + ":";
	var newAttributeBonus = $.CreatePanel("Label", $.GetContextPanel(), "Bonus" + name + "Label");
	newAttributeBonus.SetParent(newAttributeValues);
	newAttributeBonus.AddClass('BonusAttributeValue');
	newAttributeBonus.text = "10 / 0";
	var newAttributeExtra = $.CreatePanel("Label", $.GetContextPanel(), "Extra" + name + "Label");
	newAttributeExtra.SetParent(newAttributeValues);
	newAttributeExtra.AddClass('AttributeGain');
	newAttributeExtra.text = "( Additional Information )";

	var newAttributeDetails = $.CreatePanel("Label", $.GetContextPanel(), name + "Details");
	newAttributeDetails.SetParent(newDetails);
	newAttributeDetails.AddClass('StatBreakdownLabel');
	newAttributeDetails.text = "= 10% Bonus Damage with " + name + " and 0% Defense against it.";
}

function CreateSmallAttributes() {
	var oldAttr = stats.FindChildTraverse('stragiint');
	oldAttr.AddClass("Hidden")
	oldAttr.style.height = "0px";
	if (stats.FindChildTraverse("ElementContainer")) {
		var oldElem = stats.FindChildTraverse("ElementContainer");
		oldElem.DeleteAsync(0);
	}
	var elementPanel = $.CreatePanel("Panel", $.GetContextPanel(), "ElementContainer");
	elementPanel.SetParent(stats);
	elementPanel.hittest = true;
	elementPanel.style.width = "fit-children";
	elementPanel.style.height = "70px";
	elementPanel.style.verticalAlign = "bottom";
	elementPanel.style.horizontalAlign = "right";
	elementPanel.style.marginRight = "2px";
	elementPanel.style.marginBottom = "5px";
	elementPanel.style.flowChildren = "right";
	var leftSide = $.CreatePanel("Panel", $.GetContextPanel(), "LeftElementContainer");
	leftSide.SetParent(elementPanel);
	leftSide.style.width = "fit-children";
	leftSide.style.height = "70px";
	leftSide.style.marginLeft = "0px";
	leftSide.style.flowChildren = "down";
	CreateNewSmallAttributePanel(leftSide, "Fire");
	CreateNewSmallAttributePanel(leftSide, "Water");
	CreateNewSmallAttributePanel(leftSide, "Earth");

	var rightSide = $.CreatePanel("Panel", $.GetContextPanel(), "RightElementContainer");
	rightSide.SetParent(elementPanel);
	rightSide.style.width = "fit-children";
	rightSide.style.height = "70px";
	rightSide.style.marginLeft = "0px";
	rightSide.style.flowChildren = "down";
	CreateNewSmallAttributePanel(rightSide, "Storm");
	CreateNewSmallAttributePanel(rightSide, "Order");
	CreateNewSmallAttributePanel(rightSide, "Chaos");
}

function CreateNewSmallAttributePanel(parent, name) {
	var container = $.CreatePanel("Panel", $.GetContextPanel(), "Small" + name + "Container");
	container.SetParent(parent);
	container.style.width = parent.style.width;
	container.style.height = "20px";
	container.style.marginTop = "2px";
	container.style.flowChildren = "left";

	$.Msg(container.style);

	var smallIcon = $.CreatePanel("Panel", $.GetContextPanel(), "Small" + name + "Icon");
	smallIcon.SetParent(container);
	var imageName = 'url("file://{images}/custom_game/' + name.toLowerCase() + '_small.png")';
	smallIcon.style.width = "20px";
	smallIcon.style.height = "20px";
	smallIcon.style.backgroundImage = imageName;

	var smallLabel = $.CreatePanel("Label", $.GetContextPanel(), "Small" + name + "Label");
	smallLabel.SetParent(container);
	smallLabel.style.height = container.style.height;
	smallLabel.style.width = "fit-children";
	smallLabel.text = "100/100";
	smallLabel.AddClass("MonoNumbersFont");
	smallLabel.style.fontSize = "13px";
	smallLabel.style.textShadow = "0px 0px 4px 4 #00000088";
	smallLabel.style.color = "#ccc";
	smallLabel.style.marginTop = "6px";	
}

function GetElementColor(elementName) {
	switch(elementName) {
		case 'Fire':
			return "#540404";
		case 'Water':
			return "#041354";
		case 'Earth':
			return "#543304";
		case 'Storm':
			return "#545404";
		case 'Order':
			return "#afaf64";
		case 'Chaos':
			return "#4b004b";
		default:
			return "#000000";
	}
}

(function () {
	AdjustStatHud();
	GameEvents.Subscribe( "init_stat_tooltips", AdjustStatHud);
})();