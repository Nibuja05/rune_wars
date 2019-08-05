
$.Msg("Custom Stat Hud loading!!!")

// Find HUD Elements
var base = $.GetContextPanel().GetParent().GetParent().GetParent();
var x = base.FindChildTraverse('HUDElements');
x = x.FindChildTraverse('lower_hud');
x = x.FindChildTraverse('center_with_stats');
x = x.FindChildTraverse('center_block');
var stats = x.FindChildTraverse('stats_container');
var tooltipManager = base.FindChildTraverse('Tooltips');

function GetStatPanel() {
	var x = tooltipManager.FindChildTraverse('DOTAHUDDamageArmorTooltip');
	if (x == undefined || x == null) {return null}
	x = x.FindChildrenWithClassTraverse('TooltipRow');
	return x[0].FindChildTraverse('Contents');
}

function AdjustStatTooltip() {
	var statPanel = GetStatPanel();
	$.Msg("Adjust!");
	if (statPanel) {
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
	}
	var oldAttr = stats.FindChildTraverse('stragiint');
	oldAttr.AddClass("Hidden")
	oldAttr.style.height = "0px";
	if (stats.FindChildTraverse("ElementContainer")) {
		var oldElem = stats.FindChildTraverse("ElementContainer");
		oldElem.DeleteAsync(0);
	}
	var elementPanel = $.CreatePanel("Panel", stats, "ElementContainer");
	elementPanel.hittest = true;
	elementPanel.style.width = "fit-children";
	elementPanel.style.height = "70px";
	elementPanel.style.verticalAlign = "bottom";
	elementPanel.style.horizontalAlign = "right";
	elementPanel.style.marginRight = "2px";
	elementPanel.style.marginBottom = "5px";
	elementPanel.style.flowChildren = "right";
	var leftSide = $.CreatePanel("Panel", elementPanel, "LeftElementContainer");
	leftSide.style.width = "55px";
	leftSide.style.height = "70px";
	leftSide.style.marginLeft = "0px";
	leftSide.style.flowChildren = "down";
	CreateNewSmallAttributePanel(leftSide, "Fire");
	CreateNewSmallAttributePanel(leftSide, "Water");
	CreateNewSmallAttributePanel(leftSide, "Earth");

	var rightSide = $.CreatePanel("Panel", elementPanel, "RightElementContainer");
	rightSide.style.width = "55px";
	rightSide.style.height = "70px";
	rightSide.style.marginLeft = "0px";
	rightSide.style.flowChildren = "down";
	CreateNewSmallAttributePanel(rightSide, "Storm");
	CreateNewSmallAttributePanel(rightSide, "Order");
	CreateNewSmallAttributePanel(rightSide, "Chaos");
}

function CreateNewAttributePanel(parent, name) {
	if (parent.FindChildTraverse(name + "Container")) {
		var oldAttr = parent.FindChildTraverse(name + "Container");
		oldAttr.DeleteAsync(0);
	}
	var newAttr = $.CreatePanel("Panel", parent, name + "Container");
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
	var newAttributeValues = $.CreatePanel("Panel", newDetails, "AttributeValues");
	newAttributeValues.AddClass('LeftRightFlow');

	var newAttributeText = $.CreatePanel("Label", newAttributeValues, "Base" + name + "Label");
	newAttributeText.AddClass('BaseAttributeValue');
	newAttributeText.text = name + ":";
	var newAttributeBonus = $.CreatePanel("Label", newAttributeValues, "Bonus" + name + "Label");
	newAttributeBonus.AddClass('BonusAttributeValue');
	newAttributeBonus.text = "10 / 0";
	var newAttributeExtra = $.CreatePanel("Label", newAttributeValues, "Extra" + name + "Label");
	newAttributeExtra.AddClass('AttributeGain');
	newAttributeExtra.text = "( Additional Information )";

	var newAttributeDetails = $.CreatePanel("Label", newDetails, name + "Details");
	newAttributeDetails.AddClass('StatBreakdownLabel');
	newAttributeDetails.text = "= 10% Bonus Damage with " + name + " and 0% Defense against it.";
}

function CreateNewSmallAttributePanel(parent, name) {
	var container = $.CreatePanel("Panel", parent, "Small" + name + "Container");
	container.style.width = parent.style.width;
	container.style.height = "20px";
	container.style.marginTop = "2px";
	container.style.flowChildren = "right";

	var smallLabel = $.CreatePanel("Label", container, "Small" + name + "Label");
	smallLabel.style.height = container.style.height;
	smallLabel.style.width = "35px";
	smallLabel.text = "10/10";
	smallLabel.AddClass("MonoNumbersFont");
	smallLabel.style.fontSize = "15px";
	smallLabel.style.textShadow = "0px 0px 4px 4 #00000088";
	smallLabel.style.color = "#ccc";
	smallLabel.style.marginTop = "2px";
	// smallLabel.style.verticalAlign = "left";
	

	var smallIcon = $.CreatePanel("Panel", container, "Small" + name + "Icon");
	var imageName = 'url("file://{images}/custom_game/' + name.toLowerCase() + '_small.png")';
	// smallIcon.style.backgroundColor = "blue";
	smallIcon.style.width = "20px";
	smallIcon.style.height = "20px";
	smallIcon.style.backgroundImage = imageName;

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
	GameEvents.Subscribe( "init_stat_tooltips", AdjustStatTooltip );
})();