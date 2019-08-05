
$.Msg("Rune Slots!");

// Find HUD Elements
var base = $.GetContextPanel().GetParent().GetParent().GetParent();
var x = base.FindChildTraverse('HUDElements');
var x = x.FindChildTraverse('minimap_container');
var glyphScanContainer = x.FindChildTraverse('GlyphScanContainer');
var x = x.FindChildTraverse('minimap_block');
var minimap = x.FindChildTraverse('minimap');

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

	PositionContextPanel();
}

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

function ToggleRunesHUD() {
	var containerQ = $("#rune_container_q");
	var containerW = $("#rune_container_w");
	var containerE = $("#rune_container_e");
	if (RUNES_OPEN) {
		SetOpen(containerQ);
		SetOpen(containerW);
		SetOpen(containerE);
		RUNES_OPEN = false;
	} else {
		SetClosed(containerQ);
		SetClosed(containerW);
		SetClosed(containerE);
		RUNES_OPEN = true;
	}
	PositionContextPanel();
}

function SetOpen(element) {
	element.RemoveClass("close_rune_container");
	element.RemoveClass("open_rune_container");
	element.AddClass("open_rune_container");
}

function SetClosed(element) {
	element.RemoveClass("close_rune_container");
	element.RemoveClass("open_rune_container");
	element.AddClass("close_rune_container");
}

(function() {
	ReplaceButtons();
})();


