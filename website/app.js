var darkButton = document.getElementById("dark");
var lightButton = document.getElementById("light");
var logo = document.getElementById("logo");
var header = document.getElementById("header");
var body = document.body;

function setLogo(logoName) {
	"use strict";
	if (logo !== null) {
		logo.src = logoName;
	}
}

var theme = localStorage.getItem("theme");
if (theme) {
	body.classList.add(theme);
	if (theme === "dark" && logo !== null) {
		setLogo("logo_light.png");
	}
} else {
	body.classList.add("light");
}

darkButton.onclick = function () {
	"use strict";
	body.classList.replace("light", "dark");
	setLogo("logo_light.png");
	localStorage.setItem("theme", "dark");
};

lightButton.onclick = function () {
	"use strict";
	body.classList.replace("dark", "light");
	setLogo("logo.png");
	localStorage.setItem("theme", "light");
};

function openCloseIcon(event) {
	"use strict";
	var targetElem, dirDiv;
	targetElem = event.currentTarget;
	dirDiv = targetElem.parentElement.parentElement.getElementsByClassName("sub-dirs")[0];
	
	if (targetElem.classList.contains("no-click")) {
		return;
	}
	
	if (targetElem.classList.contains("tri-icon-active")) {
		targetElem.classList.remove("tri-icon-active");
		dirDiv.classList.remove("sub-dirs-active");
	} else {
		targetElem.classList.add("tri-icon-active");
		dirDiv.classList.add("sub-dirs-active");
	}
}

function setTriIcons() {
	"use strict";
	var triIcons, i, icon;
	triIcons = document.getElementsByClassName("tri-icon");
	for (i = 0; i < triIcons.length; i += 1) {
		icon = triIcons[i];
		icon.addEventListener("click", openCloseIcon);
	}
}

function openCloseCode(event) {
	"use strict";
	var rootElem, codeBlock, triIcon, block, i;
	rootElem = event.currentTarget.parentElement.parentElement.parentElement;
	codeBlock = rootElem.getElementsByTagName("div");
	for (i = 0; i < codeBlock.length; i += 1) {
		block = codeBlock[i];
		if (block.classList.contains("func-block-active")) {
			block.classList.remove("func-block-active");
		} else {
			block.classList.add("func-block-active");
		}
	}
	triIcon = rootElem.getElementsByClassName("tri-icon")[0];
	if (triIcon.classList.contains("tri-icon-active")) {
		triIcon.classList.remove("tri-icon-active");
	} else {
		triIcon.classList.add("tri-icon-active");
	}
}

function setCodeButtons() {
	"use strict";
	var buttons, i, button;
	buttons = document.getElementsByClassName("show-code");
	for (i = 0; i < buttons.length; i += 1) {
		button = buttons[i];
		button.addEventListener("click", openCloseCode);
	}
}

window.onload = function () {
	"use strict";
	if (header !== null) {
		header.classList.add("header-loaded");
	}
	setTriIcons();
	setCodeButtons();
};

function searchChanged() {
	"use strict";
	var searchBar, searchField, dropdown, newResult, curText, index;
	searchBar = document.getElementById("search-bar");
	searchField = document.getElementById("search-field");
	dropdown = searchBar.getElementsByClassName("dropdown")[0];
	
	curText = searchField.value;
	dropdown.innerHTML = "";
	
	for (index = 0; index < curText.length; index += 1) {
		newResult = document.createElement("a");
		newResult.href = "#";
		newResult.classList.add("search-result");
		newResult.classList.add("code");
		newResult.innerHTML = curText.substring(0, index + 1);
		
		dropdown.appendChild(newResult);
	}
	if (curText.length === 0) {
		newResult = document.createElement("a");
		newResult.href = "#";
		newResult.classList.add("search-result");
		newResult.classList.add("code");
		newResult.innerHTML = "No Results";
		
		dropdown.appendChild(newResult);
	}
}