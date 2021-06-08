tool
extends Node
class_name DialogManager

export(Array) var DIALOGS setget set_dialog # Dialogs are an array of arrays, in case a dialog "step" should play on multiple dialog boxes

signal dialogs_done()
signal custom_signal(name,value) # custom signal to pass information between the dialog box and the dialog manager (for instance if a choice on a node has been made)

var isStarted = false
var indexDialog = 0
var number_of_dialogs = 0 # number of dialogs playing at the same time (to wait for other dialogs to finish before getting to the next step

##### DIALOG SETTERS #####
# sets the dialog array
func set_dialog(dialogs):
	for i in dialogs.size():
		if(dialogs[i] == null):
			dialogs[i] = setBaseDialog(i)
		else:
			for j in dialogs[i].sub_dialogs.size():
				if(dialogs[i].sub_dialogs[j] == null):
					dialogs[i].sub_dialogs[j] = setSubDialog()
				else:
					if(dialogs[i].sub_dialogs[j].choices is bool and dialogs[i].sub_dialogs[j].choices == true):
						dialogs[i].sub_dialogs[j].choices = [setBaseChoice()]
					if(dialogs[i].sub_dialogs[j].choices is Array):
						if(dialogs[i].sub_dialogs[j].choices.size() == 0): # sets choices to false if size is 0
							dialogs[i].sub_dialogs[j].choices = false
						else:
							for k in dialogs[i].sub_dialogs[j].choices.size():
								if(dialogs[i].sub_dialogs[j].choices[k] == null):
									dialogs[i].sub_dialogs[j].choices[k] = setBaseChoice()
	DIALOGS = dialogs

func setBaseDialog(index : int) -> Dictionary :
	return {
		"name":"", # UNUSED : implement method next_dialog_name + goto dialog_name
		"sub_dialogs":[setSubDialog()], # to trigger dialogs on multiple boxes at the same time
		"next_dialog_index":index + 1
	}

# sets the basic elements for the dialog
func setSubDialog() -> Dictionary :
	return {
		"name":"",
		"dialog_key":"",
		"path":NodePath(),
		"instant_start":true, # false if the dialog should not start immediately (wait for a signal for instance)
		"choices":false
	}

# sets a base choice for the dialog
func setBaseChoice() -> Dictionary :
	return {
		"choice_key":"", # text of the choice
		"choice_signal_name":"", # signal generated when choice made
		"choice_signal_value":null
	}

##### USER FUNCTIONS #####
# start the dialog
func startDialog():
	isStarted = true
	indexDialog = 0
	for dialog in DIALOGS[indexDialog].sub_dialogs:
		if(dialog.instant_start):
			startDialogOnNode(dialog)

# stops the current dialog (all dialogs)
func stopCurrentDialog():
	for dialog in DIALOGS[indexDialog].sub_dialogs:
		stopDialogOnNode(dialog)

# starts a specific dialog
func startSubDialogWithName(name : String):
	for dialog in DIALOGS[indexDialog].sub_dialogs:
		if(dialog.name == name):
			startDialogOnNode(dialog)

# stops a specific dialog
func stopSubDialogWithName(name : String):
	for dialog in DIALOGS[indexDialog].sub_dialogs:
		if(dialog.name == name):
			stopDialogOnNode(dialog)

# starts the next dialog on dialogs that have instant start and those which does not, but matches a name in the array
func startNextOnNames(names : Array):
	if(DIALOGS[indexDialog].next_dialog_index < DIALOGS.size() or DIALOGS[indexDialog].next_dialog_index == -1):
		indexDialog = DIALOGS[indexDialog].next_dialog_index
		for dialog in DIALOGS[indexDialog].sub_dialogs:
			if(dialog.instant_start or dialog.name in names):
				startDialogOnNode(dialog)
	else:
		isStarted = false
		emit_signal("dialogs_done")

# triggers a specific method on a specific dialog if it exists
func triggerMethodOnSubDialog(name : String, method_name : String, parameters : Array):
	for dialog in DIALOGS.sub_dialogs:
		if(dialog.name == name and get_node(dialog.path).has_method(method_name)):
			return get_node(dialog.path).callv(method_name,parameters)

##### DIALOG MANAGER FUNCTIONS #####
# go to the next dialog if it is done
func nextDialog():
	if(DIALOGS[indexDialog].next_dialog_index < DIALOGS.size() or DIALOGS[indexDialog].next_dialog_index == -1):
		indexDialog = DIALOGS[indexDialog].next_dialog_index
		for dialog in DIALOGS[indexDialog].sub_dialogs:
			if(dialog.instant_start):
				startDialogOnNode(dialog)
	else:
		isStarted = false
		emit_signal("dialogs_done")

# starts the dialog on a specific node
func startDialogOnNode(dialog:Dictionary):
	var node = get_node_or_null(dialog.path)
	if(node != null):
		if(GlobalFunctions.checkIfHasSignal(node,"dialog_done") and not node.is_connected("dialog_done", self, "nextDialog")):
			node.connect("dialog_done",self,"nextDialog")
		if(GlobalFunctions.checkIfHasSignal(node,"custom_signal") and not node.is_connected("custom_signal", self, "customSignal")):
			node.connect("custom_signal",self,"customSignal")
		if(dialog.choices is Array and node.get("CHOICES") != null):
			node.CHOICES = dialog.choices.duplicate()
		else:
			node.CHOICES = []
		node.DIALOG = tr(dialog.dialog_key)
		node.startDialog()

# stops the dialog on a specific node
func stopDialogOnNode(dialog:Dictionary):
	var node = get_node_or_null(dialog.path)
	if(node != null):
		node.stopDialog()

##### SIGNALS #####

func customSignal(name:String,value):
	emit_signal("custom_signal",name,value)
