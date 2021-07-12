tool
extends DialogNode
class_name DialogNodeChoices

# IMPORTANT NOTE : It is recommended to not have two dialog nodes triggering one same dialog node. This could create mismatches in dialog.

##### SIGNALS #####
signal choice_made(name)

##### VARIABLES #####
#---- EXPORTS -----
export(Array) var CHOICES setget set_choices

##### USER FUNCTIONS #####
# start the dialog
func startDialog():
	isStarted = true
	var node = get_node_or_null(BOX_PATH)
	if(node != null):
		if(GlobalFunctions.checkIfHasSignal(node,"dialog_done") and not node.is_connected("dialog_done", self, "dialogDone")):
			node.connect("dialog_done",self,"dialogDone")
		if(node.get("CHOICES") != null):
			if(GlobalFunctions.checkIfHasSignal(node,"choice_made") and not node.is_connected("choice_made", self, "choiceMade")):
				node.connect("choice_made",self,"choiceMade")
			node.CHOICES = CHOICES.duplicate()
		node.DIALOG = tr(DIALOG_KEY)
		node.startDialog()

##### NODE FUNCTIONS #####
# sets a base choice for the dialog
func set_choices(choices):
	for i in range(choices.size()):
		if(choices[i] == null):
			choices[i] = {
				"key":"", # text of the choice
				"name":"", # signal generated when choice made
				"next_dialogs": [NodePath()] # paths to the next dialog nodes
			}
	CHOICES = choices

# disconnects the signals 
func disconnectSignals():
	var node = get_node_or_null(BOX_PATH)
	if(node != null):
		if(GlobalFunctions.checkIfHasSignal(node, "dialog_done") and node.is_connected("dialog_done",self,"dialogDone")):
			node.disconnect("dialog_done",self,"dialogDone")
		if(GlobalFunctions.checkIfHasSignal(node, "choice_made") and node.is_connected("choice_made",self,"choiceMade")):
			node.disconnect("choice_made",self,"choiceMade")

# resets additional variables set for choices
func resetDialogBoxChoices():
	var node = get_node_or_null(BOX_PATH)
	if(node != null and node.get("CHOICES") != null):
		node.CHOICES = []

##### SIGNAL MANAGEMENT #####
# triggered when a custom signal from the dialog box is received
func choiceMade(name:String):
	disconnectSignals()
	resetDialogBoxChoices()
	isStarted = false
	emit_signal("choice_made", name)
