import os
import sys
import re
from glob import glob

def main(args):
	CheckItems()
	

def CheckItems():
	print("Combining runes and cores...")
	startID = 3000

	rootPath = os.path.dirname(os.path.abspath(__file__))
	rootPath = str(rootPath) + "\\scripts"
	pathList = ['cores', 'runes']

	for pathName in pathList:
		path = rootPath + "\\data\\" +  pathName
		completeText = ""

		results = [y for x in os.walk(path) for y in glob(
			os.path.join(x[0], '*.txt'))]

		for r in results:
			startID += 1
			pattern = r'([^\\]+)\.txt$'
			match = re.search(pattern, r)
			if match is not None:
				name = match.group(1)
				
				file = open(r, 'r', encoding="utf8")
				text = file.read()
				file.close()

				rarityPattern = r'.*ability_(rune|core)_(\w+?)_\w+'
				rarityMatch = re.search(rarityPattern, name)
				if rarityMatch is not None:
					rarity = rarityMatch.group(2)

					kvPattern = r'((.?|\s)*?){\s((.|\s)*)'
					kvMatch = re.search(kvPattern, text)
					itemType = rarityMatch.group(1)

					cooldown = ""
					cdPattern = r'"AbilityCooldown"\s*.*'
					cdMatch = re.search(cdPattern, text)
					if cdMatch:
						cooldown = "\n\n\t" + cdMatch.group()

					runeText = GetItemText(startID, itemType, rarity, cooldown)
					runeText = kvMatch.group(1) + "{" + runeText + "\n" + kvMatch.group(3)
					completeText += runeText + "\n\n\n"

		fileName = rootPath + "\\npc\\items\\complete_" + pathName + "_data.txt"
		file = open(fileName, 'w+', encoding="utf8")
		file.write(completeText)
		file.close()
	print("Done!")


def GetItemText(itemId, itemType, quality, cooldown):
	text = """
	"ID"                    "%s"
	"BaseClass"             "item_datadriven"
	"AbilityBehavior"       "DOTA_ABILITY_BEHAVIOR_PASSIVE"
	"AbilityTextureName"    "item_%s"
	"Model"                 "models/props_gameplay/gem01.vmdl" 
	"Effect"                "particles/world/dropped_item_%s.vpcf"
	"ItemQuality"           "%s"

	"ItemDisassembleRule"	"DOTA_ITEM_DISASSEMBLE_NEVER"
	"ItemCost"				"0"
	"ItemKillable"			"1" 
	"ItemSellable"			"1"
	"ItemPurchasable"		"1"
	"ItemDroppable"			"1"
	"ItemShareability"		"ITEM_FULLY_SHAREABLE_STACKING"

	"SideShop"				"1" 
	"SecretShop"			"0"

	"ItemStackable"			"0"
	"ItemPermanent"			"0"

	"ItemInitialCharges"	"0"
	"ItemDisplayCharges"	"0"
	"ItemRequiresCharges"	"0"%s
	""" % (str(itemId), itemType, quality, quality, cooldown)
	return text

# Aufrufen der Main mit Paramtern.
if __name__ == "__main__":
	main(sys.argv[1:])