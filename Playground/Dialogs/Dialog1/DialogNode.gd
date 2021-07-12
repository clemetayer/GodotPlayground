extends Node
class_name DialogNode

# IMPORTANT NOTE : It is recommended to not have two dialog nodes triggering one same dialog node. This could create mismatches in dialog.

##### SIGNALS #####
signal dialog_done()

##### VARIABLES #####
#---- EXPORTS -----
export(String) var NAME # name of the dialog
export(String) var DIALOG_KEY # key of the dialog
export(NodePath) var BOX_PATH # path to the dialog box showing the dialog
export(Array,NodePath) var NEXT_DIALOGS # paths to the next dialog. Empty means the dialog is done after that
export(Array,NodePath) var WAIT_FOR # OPTIONNAL : Waits for multiple node to be done before starting this one 

#---- STANDARD -----
var isStarted = false

##### USER FUNCTIONS #####
# start the dialog
func startDialog():
	isStarted = true
	var node = get_node_or_null(BOX_PATH)
	if(node != null):
		if(GlobalFunctions.checkIfHasSignal(node,"dialog_done") and not node.is_connected("dialog_done", self, "dialogDone")):
			node.connect("dialog_done",self,"dialogDone")
		node.DIALOG = tr(DIALOG_KEY)
		node.startDialog()

# stops the dialog (if it has started)
func stopDialog():
	if(isStarted):
		var node = get_node_or_null(BOX_PATH)
		if(node != null):
			disconnectSignals()
			node.stopDialog()
			isStarted = false

# triggers a specific method on a specific dialog if it exists
func triggerMethodOnDialog(method_name : String, args : Array):
	var node = get_node_or_null(BOX_PATH)
	if(node != null and node.has_method(method_name)):
		return node.callv(method_name,args)

##### NODE FUNCTIONS #####
# disconnects the signals 
func disconnectSignals():
	var node = get_node_or_null(BOX_PATH)
	if(node != null):
		if(GlobalFunctions.checkIfHasSignal(node, "dialog_done") and node.is_connected("dialog_done",self,"dialogDone")):
			node.disconnect("dialog_done",self,"dialogDone")

##### SIGNAL MANAGEMENT #####
# triggered when the dialog is done
func dialogDone():
	disconnectSignals()
	isStarted = false
	emit_signal("dialog_done")
