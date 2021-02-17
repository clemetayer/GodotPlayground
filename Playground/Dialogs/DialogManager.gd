extends Control

export(Array) var DIALOGS # NOTE : Array of Dictionnaries with structure : 
						  # {
						  #  'targets':<Array of NodePath> Path to the dialog box of the target, 
						  #  'dialog':<String>, 
						  # }

signal dialogs_done()

var isStarted = false
var indexDialog = 0

# start the dialog
func startDialog():
	isStarted = true
	indexDialog = 0
	for target in DIALOGS[indexDialog].targets:
		if target is NodePath:
			var node = get_node(target)
			node.connect("dialog_done",self,"nextDialog")
			node.dialog = DIALOGS[indexDialog].dialog
			node.startDialog()

# go to the next dialog if it is not done
func nextDialog():
	if(indexDialog < DIALOGS.size() - 1):
		indexDialog += 1
		for target in DIALOGS[indexDialog].targets:
			if target is NodePath:
				var node = get_node(target)
				node.connect("dialog_done",self,"nextDialog")
				node.dialog = DIALOGS[indexDialog].dialog
				node.startDialog()
	else:
		isStarted = false
		emit_signal("dialogs_done")
