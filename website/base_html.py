
def getBaseHTML(insert, short=False, optHeader=""):
	if not short:
		return """
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width">
		<title>Doc - Server</title>

		<link href="https://fonts.googleapis.com/css2?family=Carter+One&display=swap" rel="stylesheet">
		<link href="https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap" rel="stylesheet">

		<link rel="stylesheet" type="text/css" href="style.css">

		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
		<script src="app.js" type="text/javascript" charset="utf-8" async defer></script>

		<link rel="stylesheet" href="./highlighting/styles/a11y-custom.css">
		<script src="./highlighting/highlight.pack.js"></script>

		<script>hljs.initHighlightingOnLoad();</script>
	</head>
	<body>
		
		<nav class="navbar">
			<ul class="navbar-nav">
				<li class="nav-item"><a href="index.html" title="">Home</a></li>

				<li class="nav-item has-dropdown">
					<a href="server_overview.html" title="">Server</a>
					<div class="dropdown">
						<a href="server_overview.html">Overview</a>
						<a href="server_classes.html">Classes</a>
						<a href="server_modifiers.html">Modifiers</a>
					</div>
				</li>
				<li class="nav-item has-dropdown">
					<a href="client.html" title="">Client</a>
					<div class="dropdown">
						<a href="client.html#Overview">Overview</a>
						<a href="client.html#Scripts">Scripts</a>
						<a href="client.html#Server">Server Connection</a>
					</div>
				</li>
				<li class="nav-item has-dropdown">
					<a href="assets.html" title="">Assets</a>
					<div class="dropdown">
						<a href="assets.html#Overview">Overview</a>
						<a href="assets.html#Scripts">Particles</a>
						<a href="assets.html#Server">Other</a>
					</div>
				</li>
				<li class="nav-item has-dropdown">
					<a href="settings.html" title="">Settings</a>
					<div class="dropdown">
						<a id="light" class="theme-switcher" href="">light theme</a>
						<a id="dark" class="theme-switcher" href="">dark theme</a>
					</div>
				</li>
				<li id="search-bar" class="nav-item has-dropdown">
					<input type="text" id="search-field" name="search-field" onkeyup="searchChanged()">
					%s
					<div class="dropdown">
						<a class="search-result code" href="#">No Results</a>
					</div>
				</li>
			</ul>
		</nav>

		%s

		<main>
			<a href="#" id="top-scroller">%s</a>

			%s		
		</main>

	</body>
</html>
		""" % (getIcon("search", size=35, color="gray0"), optHeader, getIcon("top_arrow", size=50), insert)
	else:
		return """<!DOCTYPE html> <html> <head> <meta charset="utf-8"> <meta name="viewport" content="width=device-width"> <title>Doc - Server</title> <link href="https://fonts.googleapis.com/css2?family=Carter+One&display=swap" rel="stylesheet"> <link rel="stylesheet" type="text/css" href="style.css"> <script src="app.js" type="text/javascript" charset="utf-8" async defer></script> </head> <body> <nav class="navbar"> <ul class="navbar-nav"> <li class="nav-item"><a href="index.html" title="">Home</a></li> <li class="nav-item has-dropdown"> <a href="server.html" title="">Server</a> <div class="dropdown"> <a href="server.html#Overview">Overview</a> <a href="server.html#Classes">Classes</a> <a href="server.html#Modifiers">Modifiers</a> </div> </li> <li class="nav-item has-dropdown"> <a href="client.html" title="">Client</a> <div class="dropdown"> <a href="client.html#Overview">Overview</a> <a href="client.html#Scripts">Scripts</a> <a href="client.html#Server">Server Connection</a> </div> </li> <li class="nav-item has-dropdown"> <a href="assets.html" title="">Assets</a> <div class="dropdown"> <a href="assets.html#Overview">Overview</a> <a href="assets.html#Scripts">Particles</a> <a href="assets.html#Server">Other</a> </div> </li> <li class="nav-item has-dropdown"> <a href="" title="">Settings</a> <div class="dropdown"> <a id="light" class="theme-switcher" href="#">light theme</a> <a id="dark" class="theme-switcher" href="#">dark theme</a> </div> </li> </ul> </nav> <main>%s</main> </body> </html>
		""" % (insert)

def tag(text, tag, optID="", optClasses=[], optStyle=[], optArgs={}):
	className = ""
	if len(optClasses) > 0:
		className = ' class="' + " ".join(optClasses) + '"'
	styles = ""
	if len(optStyle) > 0:
		styles = ' style="' + ";".join(optStyle) +';"'
	args = ""
	if len(optArgs) > 0:
		argList = []
		for name, arg in optArgs.items():
			argList.append(name + '="' + arg + '"')
		args = " " + " ".join(argList)
	if optID != "":
		optID = ' id="' + optID + '"'
	return "<%s%s%s%s%s>%s</%s>" % (tag, optID, className, styles, args, text, tag)

def addClass(text, className="", classNames=[]):
	if len(classNames) > 0:
		className = " ".join(classNames)
	return tag(text, "span", optClasses=[className])

def getIcon(iconType, size=50, color=""):
	if color != "":
		color = "fill: var(--" + color + ");"
	if iconType == "dir":
		return """<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="%s" height="%s" viewBox="0 0 226 226" style=" fill:#000000;"><g transform="translate(33.9,33.9) scale(0.7,0.7)"><g fill="none" fill-rule="nonzero" stroke="none" stroke-width="1" stroke-linecap="butt" stroke-linejoin="miter" stroke-miterlimit="10" stroke-dasharray="" stroke-dashoffset="0" font-family="none" font-weight="none" font-size="none" text-anchor="none" style="mix-blend-mode: normal"><path d="M0,226v-226h226v226z" fill="none" stroke="none"></path><g style="%s" class="icon" stroke="none"><path d="M13.56,18.08c-7.46859,0 -13.56,6.09141 -13.56,13.56v117.94375c6.62109,-35.24187 14.03672,-74.77422 14.4075,-76.69875c2.29531,-11.70609 11.12344,-18.645 23.73,-18.645h174.3025v-4.52c0,-7.46859 -6.09141,-13.56 -13.56,-13.56h-117.37875c-1.25359,-0.45906 -3.83141,-4.55531 -5.22625,-6.78c-3.47828,-5.54406 -7.04484,-11.3 -12.995,-11.3zM38.1375,63.28c-5.79125,0 -12.995,2.03047 -14.83125,11.44125c-0.58266,2.93094 -18.18594,96.63266 -23.30625,123.87625v0.2825c0,7.46859 6.09141,13.56 13.56,13.56h176.28c7.32734,0 13.31281,-5.86187 13.56,-13.13625l22.45875,-121.61625l0.14125,-0.8475c0,-7.46859 -6.09141,-13.56 -13.56,-13.56z"></path></g></g></g></svg>
		""" % (size, size, color)
	elif iconType == "file":
		return """<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="%s" height="%s" viewBox="0 0 226 226" style=" fill:#000000;"><g transform="translate(33.9,33.9) scale(0.7,0.7)"><g fill="none" fill-rule="nonzero" stroke="none" stroke-width="1" stroke-linecap="butt" stroke-linejoin="miter" stroke-miterlimit="10" stroke-dasharray="" stroke-dashoffset="0" font-family="none" font-weight="none" font-size="none" text-anchor="none" style="mix-blend-mode: normal"><path d="M0,226v-226h226v226z" fill="none" stroke="none"></path><g style="%s" class="icon" stroke="none"><path d="M28.25,0v226h169.5v-160.08333l-65.91667,-65.91667zM47.08333,18.83333h75.33333v56.5h56.5v131.83333h-131.83333zM75.33333,103.58333v9.41667h56.5v-9.41667zM75.33333,131.83333v9.41667h75.33333v-9.41667zM75.33333,160.08333v9.41667h56.5v-9.41667z"></path></g></g></g></svg>
		""" % (size, size, color)
	elif iconType == "arrow":
		return """<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="%s" height="%s" viewBox="0 0 172 172" style=" fill:#000000;"><g transform="translate(25.8,25.8) scale(0.7,0.7)"><g fill="none" fill-rule="nonzero" stroke="none" stroke-width="1" stroke-linecap="butt" stroke-linejoin="miter" stroke-miterlimit="10" stroke-dasharray="" stroke-dashoffset="0" font-family="none" font-weight="none" font-size="none" text-anchor="none" style="mix-blend-mode: normal"><path d="M0,172v-172h172v172z" fill="none" stroke="none"></path><g style="%s" class="icon" stroke="none"><path d="M0,0v86c0,35.44141 29.0586,64.5 64.5,64.5h57.33333v21.5l50.16667,-35.83333l-50.16667,-35.83333v21.5h-57.33333c-19.96028,0 -35.83333,-15.87305 -35.83333,-35.83333v-86z"></path></g></g></g></svg>
		""" % (size, size, color)
	elif iconType == "tri":
		return """<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="%s" height="%s" viewBox="0 0 172 172" style=" fill:#000000;"><g fill="none" fill-rule="nonzero" stroke="none" stroke-width="1" stroke-linecap="butt" stroke-linejoin="miter" stroke-miterlimit="10" stroke-dasharray="" stroke-dashoffset="0" font-family="none" font-weight="none" font-size="none" text-anchor="none" style="mix-blend-mode: normal"><path d="M0,172v-172h172v172z" fill="none"></path><g style="%s" class="icon click-icon"><path d="M28.66667,14.33333v143.33333l124.07292,-71.66667z"></path></g></g></svg>
		""" % (size, size, color)
	elif iconType == "top_arrow":
		return """<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="%s" height="%s" viewBox="0 0 172 172" style=" fill:#000000;"><g transform="translate(25.8,25.8) scale(0.7,0.7)"><g fill="none" fill-rule="nonzero" stroke="none" stroke-width="1" stroke-linecap="butt" stroke-linejoin="miter" stroke-miterlimit="10" stroke-dasharray="" stroke-dashoffset="0" font-family="none" font-weight="none" font-size="none" text-anchor="none" style="mix-blend-mode: normal"><path d="M0,172v-172h172v172z" fill="none" stroke="none"></path><g style="%s" class="icon" stroke="none"><path d="M86,0l-64.5,86h43v86h43v-86h43z"></path></g></g></g></svg>
		""" % (size, size, color)
	elif iconType == "search":
		return """<svg xmlns="http://www.w3.org/2000/svg" x="0px" y="0px" width="%s" height="%s" viewBox="0 0 172 172" style=" fill:#000000;"><g transform="translate(25.8,25.8) scale(0.7,0.7)"><g fill="none" fill-rule="nonzero" stroke="none" stroke-width="1" stroke-linecap="butt" stroke-linejoin="miter" stroke-miterlimit="10" stroke-dasharray="" stroke-dashoffset="0" font-family="none" font-weight="none" font-size="none" text-anchor="none" style="mix-blend-mode: normal"><path d="M0,172v-172h172v172z" fill="none" stroke="none"></path><g style="%s" class="icon" stroke="none"><path d="M95.04232,106.54818l17.77669,17.77669c-2.7155,5.17904 -2.99544,10.33008 -0.13998,13.18555l32.44597,32.44597c4.08724,4.08724 12.98958,1.84765 19.82031,-5.01107c6.85872,-6.85872 9.09831,-15.73307 5.01107,-19.82031l-32.41797,-32.44597c-2.88346,-2.85547 -8.0345,-2.57552 -13.21354,0.11198l-17.77669,-17.74869zM60.91667,0c-33.64974,0 -60.91667,27.26693 -60.91667,60.91667c0,33.64974 27.26693,60.91667 60.91667,60.91667c33.64974,0 60.91667,-27.26692 60.91667,-60.91667c0,-33.64974 -27.26692,-60.91667 -60.91667,-60.91667zM60.91667,107.5c-25.72722,0 -46.58333,-20.85612 -46.58333,-46.58333c0,-25.72722 20.85612,-46.58333 46.58333,-46.58333c25.72722,0 46.58333,20.85612 46.58333,46.58333c0,25.72722 -20.85612,46.58333 -46.58333,46.58333z"></path></g></g></g></svg>
		""" % (size, size, color)
	elif iconType == "logo":
		return """<svg version="1.0" xmlns="http://www.w3.org/2000/svg"  width="%s" height="%s" viewBox="0 0 465.000000 465.000000"  preserveAspectRatio="xMidYMid meet"> <metadata> Created by potrace 1.15, written by Peter Selinger 2001-2017 </metadata> <g transform="translate(0.000000,465.000000) scale(0.100000,-0.100000)" style="%s" class="icon" stroke="none"> <path d="M2080 4067 c-36 -7 -108 -32 -160 -56 -110 -52 -143 -56 -310 -42 -69 6 -296 16 -505 22 -319 10 -386 9 -420 -2 -60 -21 -69 -48 -56 -172 12 -110 4 -283 -25 -547 -18 -162 -15 -206 23 -365 21 -88 27 -137 28 -245 2 -126 4 -138 28 -184 20 -36 27 -63 27 -104 0 -53 -2 -57 -45 -96 l-45 -42 0 -74 c0 -117 25 -246 60 -312 26 -51 30 -69 30 -137 0 -100 -23 -222 -50 -266 -32 -51 -46 -269 -32 -479 13 -192 18 -211 64 -221 18 -4 312 -10 653 -15 341 -4 621 -8 622 -9 1 -1 23 -27 49 -59 62 -77 67 -79 117 -46 56 37 107 41 196 14 80 -23 115 -23 216 4 113 29 429 49 795 50 190 1 351 5 358 9 6 5 12 16 12 26 0 33 25 44 83 37 45 -6 138 -28 213 -51 15 -5 24 -1 30 12 10 21 18 1199 9 1291 -7 68 -23 92 -61 92 -28 0 -29 3 -9 33 20 31 35 142 35 267 0 123 -12 181 -45 232 -35 53 -39 81 -19 119 9 19 18 52 18 74 1 35 5 42 33 54 18 8 36 21 40 30 4 9 9 246 11 528 l3 511 -63 21 c-83 27 -175 41 -271 41 -72 0 -80 -2 -103 -27 l-24 -26 -28 26 c-15 14 -40 30 -55 36 -31 12 -286 30 -481 34 l-128 2 -18 -44 c-23 -61 -51 -81 -111 -81 -40 0 -54 5 -84 32 -25 21 -52 34 -87 39 -33 5 -57 16 -72 32 -26 28 -61 33 -256 41 -79 3 -149 1 -190 -7z m-705 -643 c61 -42 135 -96 165 -120 30 -24 81 -64 112 -89 31 -25 149 -104 263 -175 113 -71 330 -213 483 -316 152 -103 408 -275 567 -383 160 -107 301 -207 315 -221 14 -14 68 -50 120 -80 121 -67 196 -119 237 -161 l32 -34 -34 -135 c-40 -162 -94 -319 -141 -412 l-34 -68 -189 0 -189 0 -83 73 c-80 70 -282 278 -674 692 -99 105 -297 309 -440 455 -516 526 -895 929 -895 953 0 8 238 94 265 96 6 1 60 -33 120 -75z m1940 -24 c27 -21 63 -49 79 -63 l29 -24 -27 -144 c-45 -237 -68 -319 -90 -319 -37 0 -521 363 -606 454 -21 23 -22 29 -10 36 34 21 294 91 426 114 93 16 117 9 199 -54z m-1960 -1521 c88 -74 448 -436 510 -512 31 -39 36 -50 24 -57 -31 -20 -319 -110 -400 -126 -79 -15 -90 -15 -140 0 -58 17 -159 87 -248 173 l-54 52 6 58 c8 80 126 382 183 471 18 27 17 28 119 -59z"/> </g> </svg>
		""" % (size, size, color)