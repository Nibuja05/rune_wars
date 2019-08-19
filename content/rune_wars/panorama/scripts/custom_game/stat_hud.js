
$.Msg("Custom Stat Hud loading!!!")

var attribute_panels = {};
var small_attribute_labels = {};

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
		UpdateAttributs(key, entry["Power"], entry["Resistance"]);
		UpdateSmallAttributes(key, entry["Power"], entry["Resistance"]);
	}
}

function UpdateAttributs(name, power, resist) {
	var statPanel = GetTooltipStatPanel();
	if (statPanel) {
		var details = attribute_panels[name];
		var values = details.FindChildTraverse('AttributeValues');
		var attrText = values.FindChildTraverse('AttributeText');
		attrText.text = name + ": ";
		var attrBonus = values.FindChildTraverse('AttributeBonus');
		attrBonus.text = power + "/" + resist;
		var attrExtra = values.FindChildTraverse('AttributeExtra');
		attrExtra.text = "(Additional Information)";
		var attrDetails = details.FindChildTraverse('AttributeDetails');
		attrDetails.text = "= 10% Bonus Damage with " + name + " and 0% Defense against it.";
	}
}

function UpdateSmallAttributes(name, power, resist) {
	var attributeLabel = small_attribute_labels[name];
	attributeLabel.text = power + "/" + resist;
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
	newAttr.BLoadLayout( "file://{resources}/layout/custom_game/big_stats.xml", false, false );
	newAttr.AddClass(name.toLowerCase() + "_background");

	var icon = newAttr.FindChildTraverse('BigIcon');
	icon.AddClass(name.toLowerCase() + "_icon");

	var details = newAttr.FindChildTraverse('AttributeDetails');
	var values = details.FindChildTraverse('AttributeValues');

	var attrText = values.FindChildTraverse('AttributeText');
	attrText.text = name + ": ";
	var attrBonus = values.FindChildTraverse('AttributeBonus');
	attrBonus.text = "0/0";
	var attrExtra = values.FindChildTraverse('AttributeExtra');
	attrExtra.text = "(Additional Information)";
	var attrDetails = details.FindChildTraverse('AttributeDetails');
	attrDetails.text = "= 10% Bonus Damage with " + name + " and 0% Defense against it.";

	attribute_panels[name] = newAttr;
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
	container.BLoadLayout( "file://{resources}/layout/custom_game/small_stats.xml", false, false );

	var smallIcon = container.FindChildTraverse('SmallIcon');
	smallIcon.AddClass(name.toLowerCase() + "_icon_small");

	var smallLabel = container.FindChildTraverse('SmallLabel');
	smallLabel.text = "0/0";

	small_attribute_labels[name] = smallLabel;
}

(function () {
	AdjustStatHud();
	GameEvents.Subscribe( "init_stat_tooltips", AdjustStatHud);
})();