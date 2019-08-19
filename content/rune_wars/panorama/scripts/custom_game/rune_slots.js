
$.Msg("Rune Slots!");

// local enums
var CONSUME_EVENT = true;
var CONTINUE_PROCESSING_EVENT = false;

var m_ItemIds = {};
var m_lastSlot = -1;
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

var RUNES_OPEN = false;

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

function ToggleRunesHUD() {
	var containerQ = $("#rune_container_q");
	var containerW = $("#rune_container_w");
	var containerE = $("#rune_container_e");
	if (RUNES_OPEN) {
		SetRuneContainerOpen(containerQ);
		SetRuneContainerOpen(containerW);
		SetRuneContainerOpen(containerE);
		RUNES_OPEN = false;
	} else {
		SetRuneContainerClosed(containerQ);
		SetRuneContainerClosed(containerW);
		SetRuneContainerClosed(containerE);
		RUNES_OPEN = true;
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
}

// ============================================================================================
// Additional Drag/Drop Functions
// ============================================================================================

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
}

// ============================================================================================
// Requested Functions
// ============================================================================================

function MarkRuneSlot(table) {
	var runeSlot = $("#" + table.slotName);
	runeSlot.AddClass("rune_slot_disabled");
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
// Load Function
// ============================================================================================


(function() {
	// ReplaceButtons();
	GameEvents.Subscribe("init_rune_slots", InitRuneSlots);
	GameEvents.Subscribe("mark_rune_slot", MarkRuneSlot);
})();


