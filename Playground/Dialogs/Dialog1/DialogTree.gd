extends Node
class_name DialogTree

##### VARIABLES #####
#---- EXPORTS -----
export(Array,NodePath) var STARTS # Nodes where to start the dialog

#---- STANDARD -----
var current_dialogs # array of the current dialogs playing
var wait_for = [] # array to keep track of dialogs where a wait is required

##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	current_dialogs = []

# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	pass

##### USER FUNCTIONS #####
# Starts the dialog(s)
func startDialogs():
	for path in STARTS:
		var node = get_node_or_null(path)
		if(isValidDialog(node)):
			connectSignals(node)
			current_dialogs.append(path)
			node.startDialog()

# Stops the current dialog(s)
func stopCurrentDialogs():
	while current_dialogs.size() > 0:
		var path = current_dialogs.pop_front()
		var node = get_node_or_null(path)
		if(node != null):
			disconnectSignals(node) # Disconnects first to avoid going to a next dialog afterwards
			node.stopDialog()
	wait_for = [] # OPTIMIZATION : free each item instead ?

# triggers a specific method on the current dialog   
func triggerMethodOnCurrentDialogs(method_name:String, args:Array):
	for path in current_dialogs:
		var dialog = get_node_or_null(path)
		if(dialog != null):
			dialog.triggerMethodOnDialog(method_name,args)

##### NODE FUNCTIONS #####
# Checks if the dialog is valid
func isValidDialog(node) -> bool:
	return (node != null
			and node.has_method("startDialog"))

# Starts the next dialogs for a specific choice
func nextDialogsChoices(choice, base_node):
	for next in choice.next_dialogs:
		var node = base_node.get_node_or_null(next)
		if(not current_dialogs.has(next) and isValidDialog(node)):
			current_dialogs.append(get_path_to(node))
			connectSignals(node)
			node.startDialog() 

# disconnects the various signals from node
# to prevent the signals to be triggered again
func disconnectSignals(node):
	if(GlobalFunctions.checkIfHasSignal(node,"dialog_done") and node.is_connected("dialog_done",self,"dialogDone")):
		node.disconnect("dialog_done",self,"dialogDone")
	if(GlobalFunctions.checkIfHasSignal(node,"choice_made") and node.is_connected("choice_made",self,"choiceMade")):
		node.disconnect("choice_made",self,"choiceMade")

# connects the various signals from node
func connectSignals(node):
	if(GlobalFunctions.checkIfHasSignal(node,"dialog_done") and not node.is_connected("dialog_done",self,"dialogDone")):
		node.connect("dialog_done",self,"dialogDone",[get_path_to(node)])
	if(GlobalFunctions.checkIfHasSignal(node,"choice_made") and not node.is_connected("choice_made",self,"choiceMade")):
		node.connect("choice_made",self,"choiceMade",[get_path_to(node)])

# handles the wait for queue, returns true if all nodes to wait are done
func handleWaitFor(previous_node, next_node) -> bool:
	if(next_node.WAIT_FOR == null or next_node.WAIT_FOR.size() <= 0): # nothing to wait for
		return true
	createInWaitFor(next_node)
	var index = 0
	for element in wait_for:
		if(element.name == next_node.name):
			for path in element.wait:
				if(path == next_node.get_path_to(previous_node)):
					element.wait.remove(element.wait.find(path))
					if(element.wait.size() <= 0): # all waits are done
						wait_for.remove(index)
						return true 
					else:
						return false
		index += 1
	return true # should not be possible, but if that's the case, goes to the next dialog (so it doesn't block the dialog)

# adds the node if not in wait_for array
func createInWaitFor(node):
	for element in wait_for:
		if(element.name == node.name): # element already in array
			return
	var element = {
		"name":node.name,
		"wait":node.WAIT_FOR.duplicate()
	}
	wait_for.append(element)


##### SIGNAL MANAGEMENT #####
# triggered when a dialog is done
func dialogDone(path : NodePath):
	var node = get_node(path)
	current_dialogs.erase(get_path_to(node))
	var nexts = node.NEXT_DIALOGS
	disconnectSignals(node)
	for next in nexts:
		var next_node = node.get_node_or_null(next) 
		if (not current_dialogs.has(next) and isValidDialog(next_node) and handleWaitFor(node,next_node)):
			current_dialogs.append(get_path_to(next_node))
			connectSignals(next_node)
			next_node.startDialog()

# triggered when a choice is made
func choiceMade(name : String, path : NodePath):
	var node = get_node(path)
	current_dialogs.erase(get_path_to(node))
	disconnectSignals(node)
	node.stopDialog()
	if(node.get("CHOICES") != null):
		for choice in node.CHOICES:
			if(choice.name == name):
				nextDialogsChoices(choice, node)
