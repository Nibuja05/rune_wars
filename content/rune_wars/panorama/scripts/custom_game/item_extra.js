
// var DOTA_ITEM_STASH_MIN = 9;
// var DOTA_ITEM_STASH_MAX = 15;

// var base = $.GetContextPanel().GetParent().GetParent().GetParent();
// // var tooltipManager = base.FindChildTraverse('Tooltips');

// var itemLabel;

// $.Msg("item extra loaded!");

// function InitializeItemTooltips() {
// 	$.Msg("Init Item Tooltips!")

// 	FindItemLabel();
// 	FindAllItemPanels();
// }

// function FindItemLabel() {
// 	if (itemLabel) {
// 		$.Msg("Found the item Label!");
// 		CheckTooltipOpen();
// 		return;
// 	}
// 	itemLabel = FindDroppedItemTooltip();
// 	$.Schedule(1 / 20, FindItemLabel);
// }

// function CheckTooltipOpen() {
// 	if (itemLabel.BAscendantHasClass("TooltipVisible")) {
// 		CheckItemName();
// 	}
// 	$.Schedule(1/50, CheckTooltipOpen);
// }

// function CheckItemName() {
// 	var itemID = FindItemID();
// 	var netTable = CustomNetTables.GetTableValue("item_extras", itemID.toString());

// 	var itemName = $.Localize("DOTA_Tooltip_ability_" + Abilities.GetAbilityName(itemID));
// 	if (netTable) {
// 		var rarity = netTable[itemID].rarity;
// 		itemLabel.text = ColorText(itemName, GetRarityColor(rarity));
// 	} else {
// 		itemLabel.text = itemName;
// 	}
// }

// function FindDroppedItemTooltip() {

// 	var x = base.FindChildTraverse('DOTADroppedItemTooltip');
// 	if (!x) { return undefined; }
// 	x = x.FindChildrenWithClassTraverse('TooltipRow');
// 	if (!x[0]) { return undefined; }
// 	x = x[0].FindChildTraverse('Contents');	
// 	if (!x) { return undefined; }
// 	return x.FindChildTraverse('ItemName');
// }

// function FindItemID() {
// 	var cursor = GameUI.GetCursorPosition();
// 	var entities = GameUI.FindScreenEntities(cursor);
// 	if(!entities[0]) { return -1; }
// 	var entity = GetClosestEntity(entities);
// 	var entityIndex = entity.entityIndex;
// 	var droppedID = Entities.GetContainedItem(entityIndex);
// 	// WHY???
// 	droppedID &= ~0xFFFFC000;
// 	return droppedID;
// }

// function GetClosestEntity(entities) {
// 	var cursor = GameUI.GetCursorPosition();
// 	var worldPosition = GameUI.GetScreenWorldPosition(cursor);
// 	var minDistance = 10000;
// 	var minEntity = undefined;
// 	for (var i = 0; i < entities.length; i++) {
// 		var loc = Entities.GetAbsOrigin(entities[i].entityIndex);
// 		var distance = Game.Length2D(loc, worldPosition);
// 		if (distance < minDistance) {
// 			minDistance = distance;
// 			minEntity = entities[i];
// 		}
// 	}
// 	return minEntity;
// }

// function ColorText(text, color) {
// 	return "<font color='" + color + "'>" + text + "</font>";
// }

// function GetRarityColor(rarity) {
// 	switch(rarity) {
// 		case 'common':
// 			return "#FFFFFF";
// 		case 'uncommon':
// 			return "#1EFF00";
// 		case 'rare':
// 			return "#0070DD";
// 		case 'legendary':
// 			return "#FF8000";
// 	}
// }

// function GetElementColor(element) {
// 	switch(element) {
// 		case "Water":
// 			return "#33A9C2";
// 		case "Earth":
// 			return "#91621F";
// 		case "Fire":
// 			return "#CF0000";
// 		case "Storm":
// 			return "#CBCB0A";
// 		case "Order":
// 			return "#CFCF76";
// 		case "Chaos":
// 			return "#A017E6";
// 	}
// 	return "#FFFFFF"
// }

// function GetElementName(elementID) {
// 	switch(elementID) {
// 		case 0:
// 			return "None";
// 		case 1:
// 			return "Water";
// 		case 2:
// 			return "Earth";
// 		case 4:
// 			return "Fire";
// 		case 8:
// 			return "Storm";
// 		case 16:
// 			return "Order";
// 		case 32:
// 			return "Chaos";
// 	}
// 	return "None";
// }

// function FindAllItemPanels() {
// 	for (var i = 0; i < DOTA_ITEM_STASH_MAX; i++) {
// 		var parentPanel = FindItemPanelByIndex(i);
// 		var itemPanel = parentPanel.FindChildTraverse("ItemImage");
// 		BindPanelHover(itemPanel);
// 	}
// 	// var customUIPanel = base.FindChildTraverse("CustomUIContainer_Hud");
// 	// var runeItemPanels = customUIPanel.FindChildrenWithClassTraverse("custom_item_slot");
// 	// for (var i = 0; i < runeItemPanels.length; i++) {
// 	// 	var itemPanel = runeItemPanels[i];
// 	// 	BindPanelHover(itemPanel);
// 	// }
// }

// function BindPanelHover(itemPanel) {
// 	itemPanel.SetPanelEvent("onmouseover", function () { $.Schedule(1/200, function() { CheckItemTooltip(itemPanel); }); });
//    	itemPanel.SetPanelEvent("onmouseout", function() { CheckItemTooltipEnd(itemPanel); });
// }

// function FindItemPanelByIndex(index) {
// 	var inventory = base.FindChildTraverse("inventory_items");
// 	if (index >= DOTA_ITEM_STASH_MIN) {
// 		inventory = base.FindChildTraverse("stash_row");
// 		index -= DOTA_ITEM_STASH_MIN;
// 	}
// 	return inventory.FindChildTraverse("inventory_slot_" + index);
// }

// function CheckItemTooltip(hoverPanel) {

// 	var itemTooltip = GetItemTooltip();
// 	if (!itemTooltip) { $.Msg("No Tooltip!"); return; }
// 	if (!itemTooltip.BHasClass("TooltipVisible")) { return; }

// 	var itemID = hoverPanel.contextEntityIndex;
// 	var itemNameLabel = itemTooltip.FindChildTraverse('AbilityName');
// 	var itemName = itemNameLabel.text;

// 	var netTable = CustomNetTables.GetTableValue("item_extras", itemID.toString());
// 	if (netTable) {
// 		var rarity = netTable[itemID].rarity;
// 		itemNameLabel.text = ColorText(itemName, GetRarityColor(rarity));

// 		var realItemName = hoverPanel.itemname;
// 		var damageType = "Element: ";
// 		if (realItemName.indexOf("ability_core") >= 0) {
// 			var elementName = GetElementName(netTable[itemID].specialDamageType);
// 			damageType += elementName;
// 			CreateSubtitle(itemTooltip, damageType, GetElementColor(elementName));
// 		}
// 	} else {

// 		itemNameLabel.text = itemName;
// 		DeleteSubtitle(itemTooltip);
// 	}

// }

// function CreateSubtitle(itemTooltip, text, color) {
// 	DeleteSubtitle(itemTooltip);

// 	var itemSubtitleLabel = $.CreatePanel("Label", $.GetContextPanel(), "ItemCustomSubtitle");
// 	itemSubtitleLabel.style.fontSize = "17px";
// 	itemSubtitleLabel.style.fontWeight = "bold";
// 	itemSubtitleLabel.style.color = color;
// 	itemSubtitleLabel.style.marginLeft = "4px";
// 	itemSubtitleLabel.style.marginTop = "3px";
// 	itemSubtitleLabel.text = text;
// 	itemSubtitleLabel.html = true;
// 	var parent = itemTooltip.FindChildTraverse("HeaderLabels");
// 	itemSubtitleLabel.SetParent(parent);
// }

// function DeleteSubtitle(itemTooltip) {
// 	var subtitle = itemTooltip.FindChildTraverse("ItemCustomSubtitle");
// 	if (subtitle) {
// 		subtitle.DeleteAsync(0);
// 	}
// }

// function CheckItemTooltipEnd() {
// 	var itemTooltip = GetItemTooltip();
// 	if (!itemTooltip) { $.Msg("No Tooltip!"); return; }

// 	var itemNameLabel = itemTooltip.FindChildTraverse('AbilityName');
// 	itemNameLabel.text = "#DOTA_AbilityTooltip_Name";

// 	DeleteSubtitle(itemTooltip);
// }

// function GetItemTooltip() {
// 	var tooltip = base.FindChildTraverse("DOTAAbilityTooltip");
// 	if (!tooltip) { return undefined; }
// 	if (!tooltip.BHasClass("IsItem")) { return undefined; }
// 	return tooltip;
// }

// function UpdateInventory() {
// 	$.Schedule(1/50, function() {
// 		FindAllItemPanels();
// 		CheckItemTooltipEnd();
// 	});
// }

// (function () {
// 	InitializeItemTooltips();
// 	// GameEvents.Subscribe( "init_item_tooltips", InitializeItemTooltips );
// 	// 
// 	GameEvents.Subscribe( "dota_inventory_changed", UpdateInventory );
// 	GameEvents.Subscribe( "dota_inventory_item_changed", UpdateInventory );
// 	GameEvents.Subscribe( "m_event_dota_inventory_changed_query_unit", UpdateInventory );
// 	GameEvents.Subscribe( "m_event_keybind_changed", UpdateInventory );
// 	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateInventory );
// 	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateInventory )
// })();