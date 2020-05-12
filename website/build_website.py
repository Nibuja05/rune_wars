import sys, getopt, os, re
from glob import glob
from base_html import getBaseHTML, getIcon, addClass, tag
from collections import defaultdict, OrderedDict
import html
from bs4 import BeautifulSoup as bs
import pprint

pp = pprint.PrettyPrinter(indent=4)

def main(argv):
	print("Start!\n")

	name = "rune_wars"

	generateMainPage(name)
	generateServerLua()

	print("")

def generateMainPage(name):
	mainStr = ""

	header = getIcon("logo", size=250) + tag("Complete documentation for " + name, "h1")
	header += tag("Overview, Server and Client Code, Assets, ...", "p")
	header = tag(header, "header", optID="header")

	mainStr += """
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
	"""

	mainStr = getBaseHTML(mainStr, optHeader=header)
	with open("./index.html", mode="w") as file:
		file.write(prettifyHTML(mainStr))

def generateServerLua():
	# Find all lua files
	gameDir = "..\\game\\rune_wars\\scripts"
	results = [y for x in os.walk(gameDir) for y in glob(os.path.join(x[0], '*.lua'))]
	newResults = [processPath(path,"vscripts") for path in results]
	dirDict = {}
	for path in newResults:
		dirDict = getFileStructure(path, dirDict)
	dirDict = {"vscripts":dirDict}

	fileInfos = getAllFileInfos(results)
	generateSeverOverview(dirDict, fileInfos)
	generateServerClasses(fileInfos)
	generateServerModifiers(fileInfos)

def generateSeverOverview(dirDict, fileInfos):
	serverStr = ""

	# Create header text
	serverStr += tag("Overview", "h1") + tag("This is an overview of all contents of the 'game' folder.", "p")
	serverStr += tag("Directory Structure", "h2")

	# Create directory overview
	newStr = createStructureHtml(dirDict)
	newStr = addClass(newStr, className="structure-text")
	serverStr += tag(newStr, "div", optID="dir-container", optClasses=["highlight-container"])

	# Create List of all lua Files with according code
	arrowIcon = tag(getIcon("tri", size=14), "span", optClasses=["tri-icon", "no-click"])

	funcHeader = tag("Lua Files", "h2")
	funcStr = ""
	for filePath, fileInfo in fileInfos.items():
		funcs = []
		if "ignore" in getDocFlags(fileInfo["doc"]):
			continue
		if "funcs" in fileInfo:
			for func in fileInfo["funcs"]:
				funcName = ""
				if func["header"][0]:
					funcName += func["header"][0] + ":"
				funcName += func["header"][1] + "("
				if func["header"][2]:
					funcName += func["header"][2]
				funcName += ")"
				funcs.append({"name":funcName, "line":func["line"], "doc":func["doc"], "body":func["body"], "className":func["header"][0]})
			funcs = sorted(funcs,key=lambda x: x["name"].lower())

		filePath = prettifyPath(filePath, "vscripts")
		fileStr = tag(tag(filePath, "b"), "p", optID=getFileID(filePath))
		if (fileDoc := createFuncDoc(fileInfo["doc"])) != "":
			fileStr += tag(fileDoc, "p")

		ignoreClasses = []
		if "classes" in fileInfo:
			for classDef in fileInfo["classes"]:
				if "ignore" in getDocFlags(classDef["doc"]):
					ignoreClasses.append(classDef["name"])

		for func in funcs:
			if "ignore" in getDocFlags(func["doc"]):
				continue
			if func["className"] in ignoreClasses:
				continue
			tempFuncStr = arrowIcon
			tempFuncStr += tag(tag(func["doc"]["name"], "span", optClasses=["show-code"]), "p")
			tempFuncStr = tag(tempFuncStr, "div", optClasses=["func-header"])
			tempStr = tag(createFuncDoc(func["doc"], func["name"]),"div", optClasses=["func-description"])
			# tempStr += tag(tag(html.escape(func["body"].replace("\t", "    ")), "code", optClasses=["lua"]), "pre", optClasses=["code-syntax-block"])
			tempStr += createCodeBlock(func["body"], "lua", func["line"])
			tempStr = tag(tempStr,"div", optClasses=["func-block"])
			fileStr += tag(tempFuncStr + tempStr, "div")
		funcStr += tag(fileStr, "div", optClasses=["file-block"])
	serverStr += funcHeader + tag(funcStr, "div", optClasses=["highlight-container", "code"])

	# write result to files
	serverStr = getBaseHTML(serverStr, short=False)
	with open("./server_overview.html", mode="w") as file:
		file.write(prettifyHTML(serverStr))

def generateServerClasses(fileInfos):
	serverStr = tag("Classes", "h1")

	classes = defaultdict(dict)
	for filePath, fileInfo in fileInfos.items():
		funcs = []
		if "funcs" in fileInfo:
			if "classes" in fileInfo:
				for classDef in fileInfo["classes"]:
					className = classDef["name"].strip()
					if "modifier" not in className:
						classes[className]["path"] = filePath
						classes[className]["library"] = ("libs" in filePath) or ("addon_game_mode.lua" in filePath)
						classes[className]["extension"] = ("cdota" in className.lower())
						classes[className]["base"] = classDef["base"]
						classes[className]["doc"] = classDef["doc"]

			for func in fileInfo["funcs"]:
				possibleClass = func["header"][0]
				if possibleClass is not None and possibleClass in classes:
					if "modifier" not in possibleClass:
						classes[possibleClass]["funcs"] = classes[possibleClass].setdefault("funcs", [])
						classes[possibleClass]["funcs"].append(func)
				elif possibleClass is not None:
					if "modifier" not in possibleClass and "cdota" in possibleClass.lower():
						classes[possibleClass]["path"] = filePath
						classes[possibleClass]["library"] = ("libs" in filePath)
						classes[possibleClass]["extension"] = True
						classes[possibleClass]["base"] = possibleClass
						classes[possibleClass]["doc"] = {"name":possibleClass,"body":""}
						classes[possibleClass]["funcs"] = classes[possibleClass].setdefault("funcs", [])
						classes[possibleClass]["funcs"].append(func)

			
	classes = OrderedDict(sorted(classes.items(), key=lambda x: x[0].lower()))

	overviewStr = tag("Extensions", "h3")
	detailStr = ""
	classStr = tag("Extensions", "h2")
	for name, classInfo in classes.items():
		if classInfo["extension"]:
			classStr += generateClassBlock(name, classInfo)
			overviewStr += tag(name, "a", optArgs={"href":"#" + getFileID(classInfo["path"])}, optClasses=["code"]) + "<br>"
	detailStr += tag(classStr, "div", optClasses=["highlight-container"])
	detailStr += "<br>"

	overviewStr += tag("Libraries", "h3")
	classStr = tag("Libraries", "h2")
	for name, classInfo in classes.items():
		if classInfo["library"] and not classInfo["extension"]:
			classStr += generateClassBlock(name, classInfo)
			overviewStr += tag(name, "a", optArgs={"href":"#" + getFileID(classInfo["path"])}, optClasses=["code"]) + "<br>"
	detailStr += tag(classStr, "div", optClasses=["highlight-container"])
	detailStr += "<br>"

	overviewStr += tag("Other", "h3")
	classStr = tag("Other", "h2")
	for name, classInfo in classes.items():
		if not classInfo["library"] and not classInfo["extension"]:
			classStr += generateClassBlock(name, classInfo)
			overviewStr += tag(name, "a", optArgs={"href":"#" + getFileID(classInfo["path"])}, optClasses=["code"]) + "<br>"

	overviewStr += "<br>" * 2
	detailStr += tag(classStr, "div", optClasses=["highlight-container"])

	serverStr += overviewStr + detailStr

	serverStr = getBaseHTML(serverStr, short=False)
	with open("./server_classes.html", mode="w") as file:
		file.write(prettifyHTML(serverStr))

def generateClassBlock(name, classInfo):
	arrowIcon = tag(getIcon("tri", size=14), "span", optClasses=["tri-icon", "no-click"])
	blockStr = tag("File: " + prettifyPath(classInfo["path"], "vscripts"), "p", optClasses=["code"])
	blockStr += createFuncDoc(classInfo["doc"])
	if "funcs" in classInfo:
		fileStr = ""
		for func in classInfo["funcs"]:
			if "ignore" in getDocFlags(func["doc"]):
				continue
			tempFuncStr = arrowIcon
			tempFuncStr += tag(tag(func["doc"]["name"], "span", optClasses=["show-code"]), "p")
			tempFuncStr = tag(tempFuncStr, "div", optClasses=["func-header"])
			tempStr = tag(createFuncDoc(func["doc"], name),"div", optClasses=["func-description"])
			# tempStr += tag(tag(html.escape(func["body"].replace("\t", "    ")), "code", optClasses=["lua"]), "pre", optClasses=["code-syntax-block"])
			tempStr += createCodeBlock(func["body"], "lua", func["line"])
			tempStr = tag(tempStr,"div", optClasses=["func-block"])
			fileStr += tag(tempFuncStr + tempStr, "div")
		blockStr += tag("Functions","p", optStyle=["margin-block-end: 0", "margin-block-start: 1.5em"]) + tag(fileStr, "div", optClasses=["file-block"])
	return tag(tag(name, "h3", optID = getFileID(classInfo["path"])) + blockStr, "div", optClasses=["file-block"])

def generateServerModifiers(fileInfos):
	serverStr = tag("Modifiers", "h1")

	classes = defaultdict(dict)
	for filePath, fileInfo in fileInfos.items():
		funcs = []
		if "funcs" in fileInfo:
			for func in fileInfo["funcs"]:
				possibleClass = func["header"][0]
				if possibleClass is not None:
					if "modifier" in possibleClass:
						classes[possibleClass]["path"] = filePath
						classes[possibleClass]["funcs"] = classes[possibleClass].setdefault("funcs", [])
						classes[possibleClass]["funcs"].append(func)

	modifierStr = ""
	for name, classInfo in classes.items():
		modifierStr += tag(name, "h3")

	modifierStr = tag(modifierStr, "div", optClasses=["highlight-container"])

	serverStr += tag(modifierStr, "p")

	serverStr = getBaseHTML(serverStr, short=False)
	with open("./server_modifiers.html", mode="w") as file:
		pass
		# file.write(prettifyHTML(serverStr))

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
			# https://regex101.com/r/pFfmzU/1/
			funcPattern = r'(---\s*([\w ]+)?(\n--[^\n]*)*)*\n*((local\s+)*function\s+([\w:]+).*?^end)'
			funcMatches = re.finditer(funcPattern, fileContent, flags=re.S|re.M)
			for match in funcMatches:
				if not match.group(6):
					continue
				name = match.group(6)
				funcDict[name]["body"] = match.group(4)
				funcDict[name]["isLocal"] = False
				if match.group(5):
					funcDict[name]["isLocal"] = True
				funcDict[name]["doc"] = {"name":name, "body":""}
				if match.group(1):
					if match.group(2):
						funcDict[name]["doc"]["name"] = match.group(2)
					if match.group(3):
						funcDict[name]["doc"]["body"] = match.group(1).lstrip()

			fileDocMatch = re.search(r'(?<!.)^(---\s*([\w ]+)?(\n--[^\n]*)*)', fileContent, flags=re.M)
			struc["doc"] = {"name":"", "body":""}
			if fileDocMatch:
				if fileDocMatch.group(2):
					struc["doc"]["name"] = fileDocMatch.group(2)
				if fileDocMatch.group(1):
					struc["doc"]["body"] = fileDocMatch.group(1)

			classDocMatch = re.finditer(r'(---\s*([\w ]+)?(\n--[^\n]*)*)*\n\s*.*?(\w+)\s*=\s*class\((\w+|{})\)', fileContent)
			for match in classDocMatch:
				newClass = {"name":match.group(4),"base":match.group(5),"doc":{"name":match.group(4), "body":""}}
				if match.group(2):
					newClass["doc"]["name"] = match.group(2)
				if match.group(1):
					newClass["doc"]["body"] = match.group(1)
				struc["classes"].append(newClass)

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
					if (modifierReqMatch := re.search(r'LinkLuaModifier.*\"(.*\.lua)\"', line)):
						if "--" not in modifierReqMatch.group(0):
							newDict = {"line":i,"cont": re.split(r'[\./\\]', modifierReqMatch.group(1))}
							struc["modReqs"].append(newDict)
					if (particleMatch := re.search(r'\"([\w/\\]+?\.vpcf)\"', line)):
						if "--" not in particleMatch.group(0):
							newDict = {"line":i,"cont": particleMatch.group(1)}
							struc["particles"].append(newDict)	
					if (funcMatch := re.search(r".*function\s+(((\w+):)*(\w+))\s*\((.*)\)", line)):
						if "--" not in funcMatch.group(0):
							func = [funcMatch.group(3), funcMatch.group(4), funcMatch.group(5)]
							newDict = {"line":i,"header": func}
							if funcMatch.group(1) in funcDict:
								entry = funcDict[funcMatch.group(1)]
								newDict["doc"] = entry["doc"]
								newDict["body"] = entry["body"]
								newDict["isLocal"] = entry["isLocal"]
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

def createCodeBlock(code, codeType, startLine=0):
	lineCount = startLine + code.count('\n') + 1
	code = html.escape(code.replace("\t", "    "))
	code = tag(code, "code", optClasses=[codeType])

	lines = []
	maxLen = len(str(lineCount))
	for i in range(startLine, lineCount):
		line = str(i) + ":" + " " * (maxLen-len(str(i)))
		lines.append(line)
	lineStr = "\n".join(lines)
	lineStr = tag(tag(lineStr, "div", optClasses=["code-syntax-lines"]), "code")

	return  tag(lineStr + code, "pre", optClasses=["code-syntax-block"])

def createFuncDoc(docDict, funcName=""):
	args = []
	if docDict["body"] != "":
		lines = docDict["body"].split("\n")
		for line in lines:
			if not re.search(r'^---', line):
				if (match := re.search(r'^--\s*(.*)', line)):
					if match.group(1):
						args.append(match.group(1))
	description = ""
	decorators = []
	if len(args) > 0:
		for arg in args:
			if not (match := re.search(r'^@(\w+)\s(.*)', arg)):
				description += arg + "<br>"
			else:
				if match.group(2):
					decorators.append((match.group(1), match.group(2)))

	return description + formatDecorator(decorators, funcName)

def getDocFlags(docDict):
	flags = []
	args = []
	if docDict["body"] != "":
		lines = docDict["body"].split("\n")
		for line in lines:
			if not re.search(r'^---', line):
				if (match := re.search(r'^--\s*(.*)', line)):
					if match.group(1):
						args.append(match.group(1))
	for arg in args:
		if (match := re.search(r'^\s*@(\w+)\s*$', arg)):
			flags.append(match.group(1))
	return flags

def formatDecorator(decorator, funcName):
	if decorator == []:
		return ""
	decoStr = ""

	args = []
	if (match := re.search(r'.*?\((.*)\)', funcName)):
		if match.group(1):
			args = match.group(1).replace(" ","").split(",")
	index = 0
	inTable = False
	curTable = ""

	for name, item in decorator:
		if not name == "field":
			if inTable:
				inTable = False
				decoStr += tag(curTable, "table", optClasses=["table-table"])
				curTable = ""
		if name == "param":
			decoStr += tag("Parameter:<br>", "b")
			paramType = ""
			if ":" in item:
				paramSplit = item.split(":")
				paramType = " [" + paramSplit[0] + "]"
				item = paramSplit[1]
				if paramSplit[0] == "table":
					inTable = True
			if len(args) < index + 1:
				break
			decoStr += tag(args[index] + paramType + ": " + item.lstrip(), "span", optStyle=["margin-left:2rem"])
			index += 1
		elif name == "field":
			if inTable:
				paramType = ""
				description = ""
				name = ""
				if (match := re.search(r'^(\w+)*\s*(\w+)*(:.*)?$', item)):
					name = match.group(1)
					if match.group(2):
						paramType = " [" + match.group(2) + "]"
					if match.group(3):
						description = match.group(3)
				curTable += tag(tag(name + paramType,"td") + tag(description, "td"),"tr")
		elif name == "author":
			decoStr = "Author: " + item + "<br>" + decoStr

	if inTable:
		inTable = False
		decoStr += tag(curTable, "table", optClasses=["table-table"])

	return "<br>" + decoStr

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

def prettifyHTML(source):
	soup = bs(source, features="html.parser")
	return soup.prettify()

if __name__ == "__main__":
	main(sys.argv[1:])