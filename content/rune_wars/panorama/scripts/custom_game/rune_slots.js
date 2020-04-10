
$.Msg("Rune Slots!");

// local enums
var CONSUME_EVENT = true;
var CONTINUE_PROCESSING_EVENT = false;

var m_ItemIds = {};
var m_lastSlot = -1;
var m_curUnitID = -1;
var m_runesOpen = false;
var m_origOpen = false;
var DOTA_ITEM_STASH_MIN = 9;
var DOTA_ITEM_STASH_MAX = 15;

var hud_loaded = false;

// Find HUD Elements
var base = $.GetContextPanel().GetParent().GetParent().GetParent();
var x = base.FindChildTraverse('HUDElements');
var lower = x.FindChildTraverse('lower_hud');
var x = x.FindChildTraverse('minimap_container');
var glyphScanContainer = x.FindChildTraverse('GlyphScanContainer');
var x = x.FindChildTraverse('minimap_block');
var minimap = x.FindChildTraverse('minimap');

var x = lower.FindChildTraverse('center_with_stats');
var x = x.FindChildTraverse('center_block');
var x = x.FindChildTraverse('inventory');
var x = x.FindChildTraverse('inventory_items');
var x = x.FindChildTraverse('InventoryContainer');
var inventory = x.FindChildTraverse('inventory_list_container');

var x = lower.FindChildTraverse('shop_launcher_block');
var x = x.FindChildTraverse('stash');
var stash = x.FindChildTraverse('stash_row');

function ReplaceButtons() {
	var scanButton = glyphScanContainer.FindChildTraverse('RadarButton');
	scanButton.AddClass("Hidden");
	scanButton.style.height = "0px";
	var glyphButton = glyphScanContainer.FindChildTraverse('glyph');
	glyphButton.AddClass("Hidden");
	glyphButton.style.height = "0px";

	if (glyphScanContainer.FindChildTraverse('new_rune_button')) {
		glyphScanContainer.FindChildTraverse('new_rune_button').DeleteAsync(0);
	}
	var newRuneButton = $.CreatePanel("Button", $.GetContextPanel(), "new_rune_button");
	newRuneButton.BLoadLayoutSnippet("new_rune_button");
	newRuneButton.SetPanelEvent("onactivate","ToggleRunesHUD()");
	newRuneButton.SetPanelEvent("onmouseover","RuneButtonEnter()");
	newRuneButton.SetPanelEvent("onmouseout","RuneButtonLeave()");
	newRuneButton.AddClass("new_rune_button_default");
	newRuneButton.SetParent(glyphScanContainer);

	var newPerkButton = $.CreatePanel("Button", $.GetContextPanel(), "new_perk_button");
	newPerkButton.BLoadLayoutSnippet("new_perk_button");
	newPerkButton.SetPanelEvent("onactivate","InitRuneSlots()");
	newPerkButton.AddClass("new_rune_button_default");
	newPerkButton.SetParent(glyphScanContainer);

	PositionContextPanel();
}

// ============================================================================================
// Direct HUD Functions
// ============================================================================================

function PositionContextPanel() {
	var margin = minimap.actuallayoutheight + 35;
	if (minimap.BAscendantHasClass("MinimapExtraLarge")) {
		margin += 10;
	}
	$.GetContextPanel().style.marginBottom = margin + "px";
}

function RuneButtonEnter() {
	var button = glyphScanContainer.FindChildTraverse('new_rune_button');
	button.RemoveClass("new_rune_button_default");
	button.AddClass("new_rune_button_enter");
	button.RemoveClass("new_rune_button_leave");
}

function RuneButtonLeave() {
	var button = glyphScanContainer.FindChildTraverse('new_rune_button');
	button.AddClass("new_rune_button_leave");
	button.RemoveClass("new_rune_button_enter");
}

function SetRuneContainerOpen(element) {
	element.RemoveClass("close_rune_container");
	element.RemoveClass("open_rune_container");
	element.RemoveClass("close_rune_container_hidden");
	element.AddClass("open_rune_container");
}

function SetRuneContainerClosed(element) {
	element.RemoveClass("close_rune_container");
	element.RemoveClass("open_rune_container");
	element.AddClass("close_rune_container");
	$.Schedule(0.5, function() { element.AddClass("close_rune_container_hidden");})
}

function ToggleRunesHUD(forceState) {
	if (forceState == "Open" && m_runesOpen == true) {return;}
	if (forceState == "Close" && m_runesOpen == false) {return;}
	var containerQ = $("#rune_container_q");
	var containerW = $("#rune_container_w");
	var containerE = $("#rune_container_e");
	if (m_runesOpen == false) {
		SetRuneContainerOpen(containerQ);
		SetRuneContainerOpen(containerW);
		SetRuneContainerOpen(containerE);
		m_runesOpen = true;
	} else {
		SetRuneContainerClosed(containerQ);
		SetRuneContainerClosed(containerW);
		SetRuneContainerClosed(containerE);
		m_runesOpen = false;
	}
	PositionContextPanel();
}

function ShowRuneRemoveContainer() {
	var container = $("#rune_remove_container");
	container.RemoveClass('rune_remove_closed');
	container.AddClass('rune_remove_opened');
}

function HideRuneRemoveContainer() {
	var container = $("#rune_remove_container");
	container.RemoveClass('rune_remove_opened');
	container.AddClass('rune_remove_closed');
}

// ============================================================================================
// Init and Event Functions
// ============================================================================================

function InitRuneSlots() {
	if (!hud_loaded) {
		$.Msg("Loading Rune slots...")
		hud_loaded = true;
		ReplaceButtons();
		RegisterDragDropEvents();
		ToggleRunesHUD();
	}
}

function RegisterDragDropEvents() {
	RegisterEventForAllRuneSlots('DragDrop', OnDragDrop);
	RegisterEventForAllRuneSlots('DragEnter', OnDragEnter);
	RegisterEventForAllRuneSlots('DragLeave', OnDragLeave);
	RegisterEventForAllRuneSlots('DragStart', OnDragStart);
	RegisterEventForAllRuneSlots('DragEnd', OnDragEnd);

	TestRegister()
	// RegisterEventForAllRuneSlots('')
	// itemPanel.SetPanelEvent("onmouseover", function () { $.Schedule(1/200, function() { CheckItemTooltip(itemPanel); }); });

	$.RegisterEventHandler('DragDrop', $("#item_remove"), OnDragDrop);
	$.RegisterEventHandler('DragEnter', $("#item_remove"), OnDragEnter);
	$.RegisterEventHandler('DragLeave', $("#item_remove"), OnDragLeave);

}

function RegisterEventForAllRuneSlots(eventName, func) {
	$.RegisterEventHandler( eventName, $("#core_slot_q").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune1_slot_q").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune2_slot_q").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune3_slot_q").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#core_slot_w").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune1_slot_w").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune2_slot_w").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune3_slot_w").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#core_slot_e").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune1_slot_e").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune2_slot_e").FindChildTraverse('new_item_image'), func);
	$.RegisterEventHandler( eventName, $("#rune3_slot_e").FindChildTraverse('new_item_image'), func);
}

function TestRegister(eventName, func) {
	// $.Msg("Register")
	// $("#core_slot_q").SetPanelEvent("onmouseactivate", function() { $.Msg("Click!") });
}

// ============================================================================================
// Drag/Drop Events
// ============================================================================================

function OnDragDrop(targetPanel, draggedPanel) {
	if (!IsValidDropTarget(targetPanel, draggedPanel)) {
		return;
	}
	if (targetPanel.id == "item_remove") {
		MoveItem();
	} else {
		AddItemFromPanel(targetPanel.GetParent(), draggedPanel);
	}	
}

function OnDragEnter(targetPanel, draggedPanel) {
	if (!IsValidDropTarget(targetPanel, draggedPanel)) {
		return;
	}
	if (targetPanel.id == "item_remove") {
		targetPanel.GetParent().AddClass('rune_remove_slot_hover');
	} else {
		targetPanel.GetParent().AddClass('potential_drop_target');
	}
}

function OnDragLeave(targetPanel, draggedPanel) {
	if (targetPanel.id == "item_remove") {
		targetPanel.GetParent().RemoveClass('rune_remove_slot_hover');
	} else {
		targetPanel.GetParent().RemoveClass('potential_drop_target');
	}
}

function OnDragStart(draggedPanel, dragCallbacks) {
	if (draggedPanel.id == "item_remove") {
		return;
	}
	var curSlot = GetSlotNumberFromRuneSlot(draggedPanel.GetParent().id);
	if (m_ItemIds[curSlot] == undefined) {
		return false;
	}
	// var itemImagePanel = draggedPanel.FindChildTraverse('new_item_image');
	var itemName = draggedPanel.itemname;
	var displayPanel = $.CreatePanel( "DOTAItemImage", $.GetContextPanel(), "dragImage" );
	displayPanel.itemname = itemName;
	displayPanel.contextEntityIndex = m_ItemIds[curSlot]["Id"];
	displayPanel.m_contID = -1;
	displayPanel.m_DragCompleted = false;
	displayPanel.SetAttributeInt("IsCustom", 1);

	dragCallbacks.displayPanel = displayPanel;
	dragCallbacks.offsetX = 0;
	dragCallbacks.offsetY = 0;

	m_lastSlot = GetSlotNumberFromRuneSlot(draggedPanel.GetParent().id);

	draggedPanel.GetParent().AddClass("dragging_from");
	ShowRuneRemoveContainer();
	return true;
}

function OnDragEnd(targetPanel, draggedPanel) {
	if (draggedPanel) {
		draggedPanel.DeleteAsync(0);
	}
	var oldPanel = $("#" + GetRuneSlotFromSlotNumber(m_lastSlot));
	if (oldPanel) {
		oldPanel.RemoveClass("dragging_from");
	}
	HideRuneRemoveContainer();

	CheckItemTooltip(targetPanel);
}

// ============================================================================================
// Additional Drag/Drop Functions
// ============================================================================================


// Checks if the the target panel is a valid place to drop
function IsValidDropTarget(targetPanel, draggedPanel) {
	var newItemName = draggedPanel.itemname;
	var oldItemName = targetPanel.itemname;
	// if (oldItemName == null || oldItemName == "" || oldItemName == "none") {
	var itemId = draggedPanel.contextEntityIndex;
	var slot = FindItemSlotById(itemId);
	if (slot !== undefined || draggedPanel.GetAttributeInt("IsCustom", -1) > 0) {
		var pid = Game.GetLocalPlayerID();
		var unit = Players.GetLocalPlayerPortraitUnit()

		if (unit == Players.GetPlayerHeroEntityIndex(pid)) {
			var slotName = targetPanel.GetParent().id;
			if (slotName.indexOf("core") >= 0 && newItemName.indexOf("core") >= 0) {
				return true;
			} else if (slotName.indexOf("rune") >= 0 && newItemName.indexOf("rune") >= 0) {
				return true;
			} else if (slotName.indexOf("remove") >= 0) {
				return true;
			}
		} else {
			$.Msg("Not a valid drop target!")
		}
	}
	return false;
}

function AddItemFromPanel(targetPanel, draggedPanel) {
	var itemId = draggedPanel.contextEntityIndex;
	var itemName = draggedPanel.itemName;
	if (itemName == "" || itemName == undefined) {
		itemName =  Abilities.GetAbilityName(itemId)
		if (itemName == "") {
			return;
		}
	}
	var newSlot = -1;
	var oldSlot = -1;
	if (IsRealInventoryPanel(targetPanel)) {
		newSlot = -1;
	} else {
		// $.Msg("Add Item From Panel to " + targetPanel.id);
		newSlot = GetSlotNumberFromRuneSlot(targetPanel.id);
	}
	if (draggedPanel.GetAttributeInt("IsCustom", -1) > 0) {
		oldSlot = m_lastSlot;
	} else {
		oldSlot = FindItemSlotById(itemId);
	}
	var oldItem = AddItem(itemName, newSlot, itemId);
	if (oldItem !== undefined) {
		oldItem["Slot"] = oldSlot;
		AddItemFromTable(oldItem);
	} else {
		RemoveItem(oldSlot);
	}
	RuneUpdate();
}

function AddItem(name, slot, id) {
	// $.Msg("Add item " + name + "(" + id + ") to slot " + slot);
	var oldItem = m_ItemIds[slot];
	if (slot >= DOTA_ITEM_STASH_MAX) {
		m_ItemIds[slot] = {Name: name, Id: id};
		var slotName = GetRuneSlotFromSlotNumber(slot);
		var slotPanel = $("#" + slotName);
		var imagePanel = slotPanel.FindChildTraverse('new_item_image');
		imagePanel.itemname = name;
	} else {
		if (IsItemInInventorySlot(slot)) {
			RemoveInventoryItemFromSlot(slot);
		}
		AddInventoryItem(name, id, slot);
	}
	return oldItem;
}

function AddItemFromTable(tab) {
	AddItem(tab["Name"], tab["Slot"], tab["Id"]);
}

function RemoveItem(slot) {
	// $.Msg("Remove Item from slot " + slot);
	if (slot >= DOTA_ITEM_STASH_MAX) {
		var slotName = GetRuneSlotFromSlotNumber(slot);
		var slotPanel = $("#" + slotName);
		var imagePanel = slotPanel.FindChildTraverse('new_item_image');
		imagePanel.itemname = "none";
	} else {
		RemoveInventoryItemFromSlot(slot);
	}
	// m_ItemIds[slot] = undefined;
	delete m_ItemIds[slot];
}

function MoveItem() {
	// $.Msg("Move Item!");
	var itemTable = m_ItemIds[m_lastSlot];
	RemoveItem(m_lastSlot);
	AddInventoryItem(itemTable["Name"], itemTable["Id"], -1);
	RuneUpdate();
}

function IsRealInventoryPanel(panel) {
	if (panel.BHasClass('core_slot') || panel.BHasClass('rune_slot')) {
		return false;
	}
	return true;
}

function FindItemSlotById(id) {
	var pid = Game.GetLocalPlayerID();
	var unit = Players.GetLocalPlayerPortraitUnit()
	unit = Entities.IsControllableByPlayer( unit, pid ) ? unit : Players.GetPlayerHeroEntityIndex(pid);

	for (var i = 0; i < DOTA_ITEM_STASH_MAX; i++) {
		var item = Entities.GetItemInSlot(unit, i);
		if (item == id) {
			return i;
		}
	}
	return undefined;
}

function IsItemInInventorySlot(slot) {
	var pid = Game.GetLocalPlayerID();
	var unit = Players.GetLocalPlayerPortraitUnit()
	unit = Entities.IsControllableByPlayer( unit, pid ) ? unit : Players.GetPlayerHeroEntityIndex(pid);
	var item = Entities.GetItemInSlot(unit, slot);
	if (item == undefined || item == null) {
		return false;
	}
	return true;
}

function GetSlotNumberFromPanel(panel) {
	var slotNumber = panel.id.slice(-1);
	if (panel.BHasClass('Stash')) {
		slotNumber += DOTA_ITEM_STASH_MAX;
	}
	return slotNumber;
}

function GetSlotNumberFromRuneSlot(runeSlot) {
	var slotNumber = 0;
	switch(runeSlot) {
		case 'core_slot_q': slotNumber = 0; break;
		case 'rune1_slot_q': slotNumber = 1; break;
		case 'rune2_slot_q': slotNumber = 2; break;
		case 'rune3_slot_q': slotNumber = 3; break;
		case 'core_slot_w': slotNumber = 4; break;
		case 'rune1_slot_w': slotNumber = 5; break;
		case 'rune2_slot_w': slotNumber = 6; break;
		case 'rune3_slot_w': slotNumber = 7; break;
		case 'core_slot_e': slotNumber = 8; break;
		case 'rune1_slot_e': slotNumber = 9; break;
		case 'rune2_slot_e': slotNumber = 10; break;
		case 'rune3_slot_e': slotNumber = 11; break;
	}
	return DOTA_ITEM_STASH_MAX + slotNumber;
}

function GetRuneSlotFromSlotNumber(slotNumber) {
	var runeSlot = "";
	slotNumber -= DOTA_ITEM_STASH_MAX;
	switch(slotNumber) {
		case 0: runeSlot = "core_slot_q"; break;
		case 1: runeSlot = "rune1_slot_q"; break;
		case 2: runeSlot = "rune2_slot_q"; break;
		case 3: runeSlot = "rune3_slot_q"; break;
		case 4: runeSlot = "core_slot_w"; break;
		case 5: runeSlot = "rune1_slot_w"; break;
		case 6: runeSlot = "rune2_slot_w"; break;
		case 7: runeSlot = "rune3_slot_w"; break;
		case 8: runeSlot = "core_slot_e"; break;
		case 9: runeSlot = "rune1_slot_e"; break;
		case 10: runeSlot = "rune2_slot_e"; break;
		case 11: runeSlot = "rune3_slot_e"; break;
	}
	return runeSlot;
}

// ============================================================================================
// Server Send Functions
// ============================================================================================

function RemoveInventoryItemFromSlot(slot) {
	// $.Msg("Sending Server Request to delete item from slot " + slot + "...");
	var pID = Players.GetLocalPlayer();
	GameEvents.SendCustomGameEventToServer("delete_inv_item", {"playerID" : pID, "itemSlot" : slot} );
}

function AddInventoryItem(name, id, slot) {
	// $.Msg("Sending Server Request to add " + name + " to the inventory...");
	var pID = Players.GetLocalPlayer();
	GameEvents.SendCustomGameEventToServer("add_inv_item", {"playerID" : pID, "itemName" : name, "itemID" : id, "itemSlot" : slot} );
}

function RuneUpdate() {
	// $.Msg("Sending Server Information, that the cores/runes have changed...");
	var pID = Players.GetLocalPlayer();
	GameEvents.SendCustomGameEventToServer("update_runes", {"playerID" : pID, "runeTable" : m_ItemIds} );
	UnmarkAllRuneSlots();

	// UpdateInventory();
}

// ============================================================================================
// Requested Functions
// ============================================================================================

function MarkRuneSlot(table) {
	var runeSlot = $("#" + table.slotName);
	if (table.markType == "disabled") {
		runeSlot.AddClass("rune_slot_disabled");
	} else {
		runeSlot.RemoveClass("rune_slot_disabled");
	}
}

function UnmarkAllRuneSlots() {
	var baseChilds = $.GetContextPanel().Children()
	for (var i = 0; i < baseChilds.length; i++) {
		var containerChilds = baseChilds[i].Children();
		for (var j = 0; j < containerChilds.length; j++) {
			containerChilds[j].RemoveClass("rune_slot_disabled")
			containerChilds[j].RemoveClass("potential_drop_target")
		}
	}
}

// ============================================================================================
// Save/Load Function
// ============================================================================================

function SaveCurrentRunes(unitID) {
	var pID = Players.GetLocalPlayer();
	// var units = Players.GetSelectedEntities(pID)
	// var unitID = -1
	// if (units.length > 0) {
	// 	unitID = units[0]
	// } 
	GameEvents.SendCustomGameEventToServer("save_runes", {"playerID" : pID, "unitID" : unitID, "runeTable" : m_ItemIds} );
}

function LoadRunes(table) {
	var pID = Players.GetLocalPlayer();
	var units = Players.GetSelectedEntities(pID)
	var newUnitID = -1
	if (units.length > 0) {
		newUnitID = units[0]
	} 
	if (Entities.IsHero(newUnitID) == false) {
		ToggleRunesHUD("Close");
		return;
	} else {
		if (m_origOpen == true) {
			ToggleRunesHUD("Open");
		}
		m_origOpen = m_runesOpen;
	}
	SaveCurrentRunes(table.unitID);
	Object.keys(m_ItemIds).forEach(function(key) {
		RemoveItem(key);
	});
	UnmarkAllRuneSlots();
	m_ItemIds = table.runeTable;
	Object.keys(m_ItemIds).forEach(function(key) {
		var runeInfo = m_ItemIds[key]
		AddItem(runeInfo["Name"], key, runeInfo["Id"])
	});
	RuneUpdate();
}

// ============================================================================================
// ============================================================================================
//   _____ _    _ ____        __  __  ____  _____  _    _ _      ______   
//  / ____| |  | |  _ \      |  \/  |/ __ \|  __ \| |  | | |    |  ____| _ 
// | (___ | |  | | |_) |_____| \  / | |  | | |  | | |  | | |    | |__   (_)
//  \___ \| |  | |  _ <______| |\/| | |  | | |  | | |  | | |    |  __|    
//  ____) | |__| | |_) |     | |  | | |__| | |__| | |__| | |____| |____  _ 
// |_____/ \____/|____/      |_|  |_|\____/|_____/ \____/|______|______ (_)
//  _____ _                   _______          _ _   _           
// |_   _| |                 |__   __|        | | | (_)          
//   | | | |_ ___ _ __ ___      | | ___   ___ | | |_ _ _ __  ___ 
//   | | | __/ _ \ '_ ` _ \     | |/ _ \ / _ \| | __| | '_ \/ __|
//  _| |_| ||  __/ | | | | |    | | (_) | (_) | | |_| | |_) \__ \
// |_____|\__\___|_| |_| |_|    |_|\___/ \___/|_|\__|_| .__/|___/
//                                                    | |        
//                                                    |_|        
// ============================================================================================
// ============================================================================================


var reset = false;
var resetSchedule;

var itemLabel;

$.Msg("item extra loaded!");

function InitializeItemTooltips() {
	$.Msg("Init Item Tooltips!")

	FindItemLabel();
	FindAllItemPanels();
}

function FindItemLabel() {
	if (itemLabel) {
		$.Msg("Found the item Label!");
		CheckTooltipOpen();
		return;
	}
	itemLabel = FindDroppedItemTooltip();
	$.Schedule(1 / 20, FindItemLabel);
}

function CheckTooltipOpen() {
	if (itemLabel.BAscendantHasClass("TooltipVisible")) {
		CheckItemName();
	}
	$.Schedule(1/50, CheckTooltipOpen);
}

function CheckItemName() {
	var itemID = FindItemID();
	var netTable = CustomNetTables.GetTableValue("item_extras", itemID.toString());

	var itemName = $.Localize("DOTA_Tooltip_ability_" + Abilities.GetAbilityName(itemID));
	if (netTable) {
		var rarity = netTable.rarity;
		itemLabel.text = ColorText(itemName, GetRarityColor(rarity));
	} else {
		itemLabel.text = itemName;
	}
}

function FindDroppedItemTooltip() {

	var x = base.FindChildTraverse('DOTADroppedItemTooltip');
	if (!x) { return undefined; }
	x = x.FindChildrenWithClassTraverse('TooltipRow');
	if (!x[0]) { return undefined; }
	x = x[0].FindChildTraverse('Contents');	
	if (!x) { return undefined; }
	return x.FindChildTraverse('ItemName');
}

function FindItemID() {
	var cursor = GameUI.GetCursorPosition();
	var entities = GameUI.FindScreenEntities(cursor);
	if(!entities[0]) { return -1; }
	var entity = GetClosestEntity(entities);
	var entityIndex = entity.entityIndex;
	var droppedID = Entities.GetContainedItem(entityIndex);
	// WHY???
	droppedID &= ~0xFFFFC000;
	return droppedID;
}

function GetClosestEntity(entities) {
	var cursor = GameUI.GetCursorPosition();
	var worldPosition = GameUI.GetScreenWorldPosition(cursor);
	var minDistance = 10000;
	var minEntity = undefined;
	for (var i = 0; i < entities.length; i++) {
		var loc = Entities.GetAbsOrigin(entities[i].entityIndex);
		var distance = Game.Length2D(loc, worldPosition);
		if (distance < minDistance) {
			minDistance = distance;
			minEntity = entities[i];
		}
	}
	return minEntity;
}

function ColorText(text, color) {
	return "<font color='" + color + "'>" + text + "</font>";
}

function GetRarityColor(rarity) {
	switch(rarity) {
		case 'common':
			return "#FFFFFF";
		case 'uncommon':
			return "#1EFF00";
		case 'rare':
			return "#0070DD";
		case 'legendary':
			return "#FF8000";
	}
}

function GetElementColor(element) {
	switch(element) {
		case "Water":
			return "#33A9C2";
		case "Earth":
			return "#91621F";
		case "Fire":
			return "#CF0000";
		case "Storm":
			return "#CBCB0A";
		case "Order":
			return "#CFCF76";
		case "Chaos":
			return "#A017E6";
	}
	return "#FFFFFF"
}

function GetElementName(elementID) {
	switch(elementID) {
		case 0:
			return "None";
		case 1:
			return "Water";
		case 2:
			return "Earth";
		case 4:
			return "Fire";
		case 8:
			return "Storm";
		case 16:
			return "Order";
		case 32:
			return "Chaos";
	}
	return "None";
}

function FindAllItemPanels() {
	for (var i = 0; i < DOTA_ITEM_STASH_MAX; i++) {
		var parentPanel = FindItemPanelByIndex(i);
		var itemPanel = parentPanel.FindChildTraverse("ItemImage");
		BindPanelHover(itemPanel);
	}
	var customUIPanel = base.FindChildTraverse("CustomUIContainer_Hud");
	var runeItemPanels = customUIPanel.FindChildrenWithClassTraverse("custom_item_slot");
	for (var i = 0; i < runeItemPanels.length; i++) {
		var itemPanel = runeItemPanels[i];
		BindPanelHover(itemPanel);
	}
}

function BindPanelHover(itemPanel) {
	itemPanel.SetPanelEvent("onmouseover", function () { $.Schedule(1/200, function() { CheckItemTooltip(itemPanel); }); });
   	itemPanel.SetPanelEvent("onmouseout", function() { $.Schedule(1/6, function() { CheckItemTooltipEnd(itemPanel); }); });
}

function FindItemPanelByIndex(index) {
	var inventory = base.FindChildTraverse("inventory_items");
	if (index >= DOTA_ITEM_STASH_MIN) {
		inventory = base.FindChildTraverse("stash_row");
		index -= DOTA_ITEM_STASH_MIN;
	}
	return inventory.FindChildTraverse("inventory_slot_" + index);
}

function CheckItemTooltip(hoverPanel) {
	var itemTooltip = GetItemTooltip();
	if (!itemTooltip) { return; }
	if (!itemTooltip.BHasClass("TooltipVisible")) { return; }

	var itemID;
	if(hoverPanel.BHasClass("custom_item_slot")) {
		var curSlot = GetSlotNumberFromRuneSlot(hoverPanel.id);
		// $.Msg("Cur slot: " + curSlot);
		// $.Msg("Last slot: " + m_lastSlot);
		if (m_ItemIds[curSlot] == undefined) {
			return false;
		}
		itemID = m_ItemIds[curSlot]["Id"];
		hoverPanel = hoverPanel.FindChildTraverse("new_item_image");
	} else {
		itemID = hoverPanel.contextEntityIndex;
	}

	var itemNameLabel = itemTooltip.FindChildTraverse('AbilityName');
	// var itemName = itemNameLabel.text;
	var itemName = $.Localize("DOTA_Tooltip_ability_" + Abilities.GetAbilityName(itemID));

	var details = itemTooltip.FindChildTraverse("AbilityDetails");
	details.AddClass("InventoryItem");
	// var mainShop = itemTooltip.FindChildTraverse("ItemAvailibilityMainShop");
	// mainShop.AddClass("InventoryItem");
	// var sideShop = itemTooltip.FindChildTraverse("ItemAvailibilitySideShop");
	// sideShop.AddClass("InventoryItem");
	// var secretShop = itemTooltip.FindChildTraverse("ItemAvailibilitySecretShop");
	// secretShop.AddClass("InventoryItem");
	// 

	var netTable = CustomNetTables.GetTableValue("item_extras", itemID.toString());
	if (netTable) {
		var realItemName = hoverPanel.itemname;
		var damageType = "Element: ";
		if (realItemName.indexOf("ability_core") >= 0) {
			var elementName = GetElementName(netTable.specialDamageType);
			damageType += elementName;
			CreateSubtitle(itemTooltip, damageType, GetElementColor(elementName));

			var rarity = netTable.rarity;
			itemNameLabel.text = ColorText(itemName, GetRarityColor(rarity));

			reset = false;
			if (resetSchedule) {
				$.CancelScheduled(resetSchedule, {});
			}
			resetSchedule = $.Schedule(1 / 6, function() {
				resetSchedule = undefined;
				reset = true;
			});
			return;
		}
	}

	ResetItemTooltip();
	itemNameLabel.text = itemName;
	DeleteSubtitle(itemTooltip);
}

function CreateSubtitle(itemTooltip, text, color) {
	DeleteSubtitle(itemTooltip);

	var itemSubtitleLabel = $.CreatePanel("Label", $.GetContextPanel(), "ItemCustomSubtitle");
	itemSubtitleLabel.style.fontSize = "17px";
	itemSubtitleLabel.style.fontWeight = "bold";
	itemSubtitleLabel.style.color = color;
	itemSubtitleLabel.style.marginLeft = "4px";
	itemSubtitleLabel.style.marginTop = "3px";
	itemSubtitleLabel.text = text;
	itemSubtitleLabel.html = true;
	var parent = itemTooltip.FindChildTraverse("HeaderLabels");
	itemSubtitleLabel.SetParent(parent);
}

function DeleteSubtitle(itemTooltip) {
	var subtitle = itemTooltip.FindChildTraverse("ItemCustomSubtitle");
	if (subtitle) {
		subtitle.DeleteAsync(0);
	}
}

function CheckItemTooltipEnd(hoverPanel) {
	var itemTooltip = GetItemTooltip();
	if (!itemTooltip) { return; }

	if (reset) {
		ResetItemTooltip();
	}
}

function ResetItemTooltip() {
	var itemTooltip = GetItemTooltip();
	var itemNameLabel = itemTooltip.FindChildTraverse('AbilityName');
	itemNameLabel.text = "#DOTA_AbilityTooltip_Name";

	DeleteSubtitle(itemTooltip);
}

function GetItemTooltip() {
	var tooltip = base.FindChildTraverse("DOTAAbilityTooltip");
	if (!tooltip) { return undefined; }
	if (!tooltip.BHasClass("IsItem")) { return undefined; }
	return tooltip;
}

function UpdateInventory() {
	var itemTooltip = GetItemTooltip();
	$.Schedule(1/50, function() {
		// if (itemTooltip) {  return; }
		FindAllItemPanels();
		CheckItemTooltipEnd();
	});
}

(function() {
	// ReplaceButtons();
	GameEvents.Subscribe("init_rune_slots", InitRuneSlots);
	GameEvents.Subscribe("mark_rune_slot", MarkRuneSlot);
	GameEvents.Subscribe("load_runes", LoadRunes);

	InitializeItemTooltips();
	GameEvents.Subscribe( "dota_inventory_changed", UpdateInventory );
	GameEvents.Subscribe( "dota_inventory_item_changed", UpdateInventory );
	GameEvents.Subscribe( "m_event_dota_inventory_changed_query_unit", UpdateInventory );
	GameEvents.Subscribe( "m_event_keybind_changed", UpdateInventory );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateInventory );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateInventory )
})();


