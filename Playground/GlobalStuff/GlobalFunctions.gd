extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	TranslationServer.set_locale("fr")

# checks if the node has a signal named signal_name
func checkIfHasSignal(node,signal_name):
	for el in node.get_signal_list():
		if(el["name"] == signal_name):
			return true
	return false
