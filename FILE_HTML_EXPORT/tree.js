// You can find instructions for this file here:
// http://www.treeview.net
// Decide if the names are links or just the icons
HIGHLIGHT = 1
USETEXTLINKS = 1  //replace 0 with 1 for hyperlinks
// Decide if the tree is to start all open or just showing the root folders
STARTALLOPEN = 0 //replace 0 with 1 to show the whole tree
ICONPATH = 'icons/' //change if the gifs folder is a subfolder, for example:'images/'

foldersTree = gFld("<i>Objects</i>", "javascript:parent.op()")

foldersTree.iconSrc = ICONPATH + "THB60608AE06000000000000.ico"

foldersTree.xID = "Root"
aux0 = insFld(foldersTree, gFld('& ', "javascript:loadFrames('Files/{AB27088E-175A-45F9-A4FB-3EA0BBC6C397}/{AB27088E-175A-45F9-A4FB-3EA0BBC6C397}.htm','Files/{AB27088E-175A-45F9-A4FB-3EA0BBC6C397}/Table.htm','Files/{AB27088E-175A-45F9-A4FB-3EA0BBC6C397}/Добавление_пользовательского_элемента_управления_в_TDMS.pdf')"))
aux0.iconSrc = ICONPATH + "TH2300230000000000000000.ico"
aux0.iconSrcClosed = ICONPATH + "TH2300230000000000000000.ico"
aux0.xID="{AB27088E-175A-45F9-A4FB-3EA0BBC6C397}"
docAux = insDoc(aux0, gLnk("S", '& ', "javascript:loadFrames('Files/{F234BCBB-DF81-4BA7-9999-7D4EAC04A181}/{F234BCBB-DF81-4BA7-9999-7D4EAC04A181}.htm','Files/{F234BCBB-DF81-4BA7-9999-7D4EAC04A181}/Table.htm','Files/{F234BCBB-DF81-4BA7-9999-7D4EAC04A181}/test.pdf')"))
docAux.iconSrc = ICONPATH + "TH2300230000000000000000.ico"
docAux.xID = "{F234BCBB-DF81-4BA7-9999-7D4EAC04A181}"
