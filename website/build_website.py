import sys, getopt, os, re
from glob import glob
from base_html import getBaseHTML, getIcon, addClass, tag
from collections import defaultdict
import html

def main(argv):
	print("Start!\n\n")
	generateServerLua()

def genere

def generateServerLua():
	serverStr = ""

	# Find all lua files
	gameDir = "..\\game\\rune_wars\\scripts"
	results = [y for x in os.walk(gameDir) for y in glob(os.path.join(x[0], '*.lua'))]
	newResults = [processPath(path,"vscripts") for path in results]
	dirDict = {}
	for path in newResults:
		dirDict = getFileStructure(path, dirDict)
	dirDict = {"vscripts":dirDict}

	# Create header text
	serverStr += tag("Overview", "h1") + tag("This is an overview of all contents of the 'game' folder.", "p")
	serverStr += tag("Directory Structure", "h2")

	# Create directory overview
	newStr = createStructureHtml(dirDict)
	newStr = addClass(newStr, className="structure-text")
	serverStr += tag(newStr, "div", optID="dir-container", optClasses=["highlight-container"])

	# Create List of all lua Files with according code
	fileInfos = getAllFileInfos(results)
	funcHeader = tag("Lua Files", "h2")
	funcStr = ""
	for filePath, fileInfo in fileInfos.items():
		funcs = []
		if "funcs" in fileInfo:
			for func in fileInfo["funcs"]:
				funcName = ""
				if func["header"][0]:
					funcName += func["header"][0] + ":"
				funcName += func["header"][1] + "("
				if func["header"][2]:
					funcName += func["header"][2]
				funcName += ")"
				funcs.append({"name":funcName, "line":func["line"], "doc":func["doc"], "body":func["body"]})
			funcs = sorted(funcs,key=lambda x: x["name"].lower())
		filePath = prettifyPath(filePath, "vscripts")
		fileStr = tag(tag(filePath, "b"), "p", optID=getFileID(filePath))
		for func in funcs:
			tempStr = tag(str(func["line"]) + ":&nbsp&nbsp" + tag(func["name"], "span", optClasses=["show-code"]), "p")
			tempStr += tag(tag(html.escape(func["body"].replace("\t", "    ")), "code", optClasses=["lua"]), "pre", optClasses=["code-syntax-block"])
			fileStr += tag(tempStr,"div")
		funcStr += tag(fileStr, "div", optClasses=["file-block"])
	serverStr += funcHeader + tag(funcStr, "div", optClasses=["highlight-container", "code"])

	# write result to files
	serverStr = getBaseHTML(serverStr, short=False)
	with open("./server.html", mode="w") as file:
		file.write(serverStr)

def createStructureHtml(dirDict, offset=0, base=True, path=[]):
	if base:
		arrowIcon = addClass(getIcon("tri", size=14), classNames=["tri-icon", "tri-icon-active"])
	else:
		arrowIcon = addClass(getIcon("tri", size=14), className="tri-icon")
	folderIcon = getIcon("dir", size=25)
	fileIcon = getIcon("file", size=25)

	dirs = ""
	files = ""
	for name, item in dirDict.items():
		if not name == "_files":
			dirHeader = tag(arrowIcon + folderIcon + name, "div", optClasses=["structure-text-align"], optStyle=["margin-left:%spx"%(offset)])
			if base:
				dirBody =  tag(createStructureHtml(item, offset + 50, False, path + [name]), "div", optClasses=["sub-dirs", "sub-dirs-active"])
			else:
				dirBody =  tag(createStructureHtml(item, offset + 50, False, path + [name]), "div", optClasses=["sub-dirs"])
			dirs += tag(dirHeader + dirBody, "div")
		else:
			for fileName in item:
				filePath = "/".join(path + [fileName])
				fileLink = "#" + getFileID(filePath)
				files += tag(fileIcon + tag(fileName, "a", optArgs={"href":fileLink}), "div", optClasses=["structure-text-align"], optStyle=["margin-left:%spx"%(offset + 14)])
	return dirs + files

def getFileStructure(path, oldDict={}):
	if len(path) == 1:
		oldDict.setdefault("_files", []).append(path[0])
		return oldDict
	newDict = oldDict.setdefault(path[0], {})
	path.pop(0)
	if len(path) > 1:
		getFileStructure(path,newDict)
	elif len(path) == 1:
		newDict.setdefault("_files", []).append(path[0])
	return oldDict

def getAllFileInfos(pathList):
	allDict = {}
	for path in pathList:
		with open(path, mode="r") as file:
			struc = defaultdict(list)

			fileContent = file.read()

			funcDict = defaultdict(dict)
			funcPattern = r'(---.*?)*^((local\s+)*function\s+([\w:]+).*?^end)'
			funcMatches = re.finditer(funcPattern, fileContent, flags=re.S|re.M)
			for match in funcMatches:
				if not match.group(4):
					continue
				name = match.group(4)
				funcDict[name]["body"] = match.group(2)
				if match.group(1):
					funcDict[name]["doc"] = match.group(1)
				else:
					funcDict[name]["doc"] = ""

			content = fileContent.split("\n")
			isComment = False
			for i,line in enumerate(content):
				if "--[[" in line:
					isComment = True
				if not isComment:
					if (reqMatch := re.search(r".*require\([\"'](.*)[\"']\)", line)):
						if "--" not in reqMatch.group(0):
							newDict = {"line":i,"cont": re.split(r'[\./\\]', reqMatch.group(1))}
							struc["reqs"].append(newDict)
					if (funcMatch := re.search(r".*function\s+(((\w+):)*(\w+))\s*\((.*)\)", line)):
						if "--" not in funcMatch.group(0):
							func = [funcMatch.group(3), funcMatch.group(4), funcMatch.group(5)]
							newDict = {"line":i,"header": func}
							if funcMatch.group(1) in funcDict:
								entry = funcDict[funcMatch.group(1)]
								newDict["doc"] = entry["doc"]
								newDict["body"] = entry["body"]
							else:
								continue
							struc["funcs"].append(newDict)
				if "]]" in line:
					isComment = False
		name = re.search(r"\\(\w+\.lua)", path).group(1)
		strucDict = dict(struc)
		strucDict["name"] = name
		allDict[path] = strucDict
	return allDict

def getFileID(fileName):
	fileName = fileName.replace("_", "-")
	fileName = fileName.replace(" ", "-")
	fileName = fileName.replace("/", "-")
	fileName = fileName.replace("\\", "-")
	fileName = fileName.replace(".lua", "")
	fileName = fileName.replace(".", "")
	if fileName[0] == "-":
		return fileName[1:]
	return fileName

def processPath(path, name):
	pattern = name + r'\\(.*)'
	if (match := re.search(pattern, path)) is not None:
		return match.group(1).split("\\")
	return []

def prettifyPath(path, name):
	pattern = name + r'\\(.*)'
	if (match := re.search(pattern, path)) is not None:
		return name + "/" + match.group(1).replace("\\", "/")
	return ""

if __name__ == "__main__":
	main(sys.argv[1:])