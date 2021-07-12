extends WAT.Test
class_name DialogTreeUTest

# Doc : https://wat.readthedocs.io/en/latest/index.html

# NOTE : Sometimes, tests might fail because the dialog nodes are not already loaded when beginning the tests

# TODO :
# Test d'un seul dialogue sur un seul point de départ - Done
# Test de dialogues avec plusieurs points de départs - Done
# Test test d'un dialogue enchaînant avec un autre - DONE
# Test d'un dialogue enchaînant avec lui-même - DONE
# Test d'un enchainement de dialogues suite à un choix
# Test stop current dialog
# Test de deux dialogues se rejoignant - DONE
# Test de deux dialogues s'exécutant en même temps (note : vérifier qu'ils se skippent avec le même press de touche) - DONE

##### VARIABLES #####
var dialog_box_template_path = "res://tests/Dialogs/Dialog1/DialogBox.tscn"
var dialog_box_choices_path = "res://tests/Dialogs/Dialog1/DialogBoxChoices.tscn"
var dialog_box

##### PROCESSING #####
func pre():
	dialog_box = load(dialog_box_template_path).instance()
	add_child(dialog_box)

func post():
	dialog_box.queue_free()

func title() -> String:
	return "Test of the dialog tree template"

##### UTILS #####
# Resets the dialog box to its standard values
func resetDialogBox():
	dialog_box.stopDialog()
	dialog_box.RTL.text = ""
	dialog_box.DIALOG = ""
	dialog_box.sound.stop()
	dialog_box.test_emulate_next_dialog_key = false

# shortcut for testing that a dialog started
func checkDialogStarted(dialog_node, dialog_box):
	asserts.is_true(dialog_node.isStarted,"Dialog node isStarted true for " + dialog_node.NAME)
	asserts.is_true(dialog_box.dialog_started, "dialog_started true for " + dialog_node.NAME)
	asserts.is_true(dialog_box.visible,"Dialog box visible for " + dialog_node.NAME)
	asserts.is_equal(dialog_box.DIALOG, tr(dialog_node.DIALOG_KEY), "Dialog correctly set for " + dialog_node.NAME)

# shortcut for testing that a dialog is done
func checkDialogDone(dialog_node,dialog_box):
	asserts.is_false(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done disconnected correctly for " + dialog_node.NAME)
	asserts.is_false(dialog_node.isStarted,"Dialog node isStarted false for " + dialog_node.NAME)
	asserts.signal_was_emitted(dialog_node,"dialog_done","dialog_done signal was emitted for " + dialog_node.NAME)

# shortcut to skip dialog
func skipDialog(dialog_box):
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false

##### TEST FUNCTIONS #####
# Test of a single dialog with single start point
func test_single_dialog() -> void:
	var dialog_node = DialogNode.new()
	var dialog_tree = DialogTree.new()
	add_child(dialog_tree)
	dialog_tree.add_child(dialog_node)
	watch(dialog_node,"dialog_done")
	dialog_node.NAME = "test"
	dialog_node.DIALOG_KEY = "test"
	dialog_node.BOX_PATH = dialog_node.get_path_to(dialog_box)
	dialog_node.NEXT_DIALOGS = []
	dialog_tree.STARTS = [dialog_tree.get_path_to(dialog_node)]
	dialog_tree.startDialogs()
	asserts.is_true(dialog_node.isStarted,"Dialog node isStarted true")
	asserts.is_true(dialog_box.dialog_started, "dialog_started true")
	asserts.is_equal(dialog_box.DIALOG, tr(dialog_node.DIALOG_KEY), "Dialog correctly set")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_false(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done disconnected correctly")
	asserts.is_false(dialog_node.isStarted,"Dialog node isStarted false")
	asserts.signal_was_emitted(dialog_node,"dialog_done","dialog_done signal was emitted")
	dialog_tree.queue_free()
	resetDialogBox()
	describe("Single dialog test")

# test of a chained dialog
func test_chain_dialog() -> void:
	# Nodes setup
	var dialog_node1 = DialogNode.new()
	var dialog_node2 = DialogNode.new()
	var dialog_node3_1 = DialogNode.new()
	var dialog_node3_2 = DialogNode.new()
	var dialog_node4 = DialogNode.new()
	var dialog_tree = DialogTree.new()
	var dialog_box2 = load(dialog_box_template_path).instance()
	add_child(dialog_tree)
	add_child(dialog_box2)
	dialog_tree.add_child(dialog_node1)
	dialog_tree.add_child(dialog_node2)
	dialog_tree.add_child(dialog_node3_1)
	dialog_tree.add_child(dialog_node3_2)
	dialog_tree.add_child(dialog_node4)
	watch(dialog_node1,"dialog_done")
	watch(dialog_node2,"dialog_done")
	watch(dialog_node3_1,"dialog_done")
	watch(dialog_node3_2,"dialog_done")
	watch(dialog_node4,"dialog_done")
	dialog_node1.NAME = "test1"
	dialog_node1.DIALOG_KEY = "test1"
	dialog_node1.BOX_PATH = dialog_node1.get_path_to(dialog_box)
	dialog_node1.NEXT_DIALOGS = [dialog_node1.get_path_to(dialog_node2)]
	dialog_node2.NAME = "test2"
	dialog_node2.DIALOG_KEY = "test2"
	dialog_node2.BOX_PATH = dialog_node2.get_path_to(dialog_box)
	dialog_node2.NEXT_DIALOGS = [dialog_node2.get_path_to(dialog_node3_1),dialog_node2.get_path_to(dialog_node3_2)]
	dialog_node3_1.NAME = "test3_1"
	dialog_node3_1.DIALOG_KEY = "test3_1"
	dialog_node3_1.BOX_PATH = dialog_node3_1.get_path_to(dialog_box)
	dialog_node3_1.NEXT_DIALOGS = [dialog_node3_1.get_path_to(dialog_node4)]
	dialog_node3_2.NAME = "test3_2"
	dialog_node3_2.DIALOG_KEY = "test3_2 but a bit longer to actually wait for the dialog to be done"
	dialog_node3_2.BOX_PATH = dialog_node3_2.get_path_to(dialog_box2)
	dialog_node3_2.NEXT_DIALOGS = [dialog_node3_2.get_path_to(dialog_node4)]
	dialog_node4.NAME = "test4"
	dialog_node4.DIALOG_KEY = "test4"
	dialog_node4.BOX_PATH = dialog_node4.get_path_to(dialog_box)
	dialog_node4.NEXT_DIALOGS = []
	dialog_node4.WAIT_FOR = [dialog_node4.get_path_to(dialog_node3_1),dialog_node4.get_path_to(dialog_node3_2)]
	dialog_tree.STARTS = [dialog_tree.get_path_to(dialog_node1)]
	for i in range(2): # restarts the test 2 times
		dialog_tree.startDialogs()
		checkDialogStarted(dialog_node1,dialog_box)
		skipDialog(dialog_box)
		checkDialogDone(dialog_node1,dialog_box)
		checkDialogStarted(dialog_node2,dialog_box)
		skipDialog(dialog_box)
		checkDialogDone(dialog_node2,dialog_box)
		checkDialogStarted(dialog_node3_1,dialog_box)
		checkDialogStarted(dialog_node3_2,dialog_box2)
		skipDialog(dialog_box)
		checkDialogDone(dialog_node3_1,dialog_box)
		checkDialogStarted(dialog_node3_2,dialog_box2)
		asserts.is_false(dialog_node4.isStarted,"dialog 4 not started yet (waiting for 3_2)")
		asserts.is_equal(dialog_tree.wait_for.size(),1,"wait_for array correctly decreased")
		skipDialog(dialog_box2)
		checkDialogDone(dialog_node3_2,dialog_box2)
		asserts.is_false(dialog_box2.visible, "dialog box 2 hidden")
		checkDialogStarted(dialog_node4,dialog_box)
		skipDialog(dialog_box)
		checkDialogDone(dialog_node4,dialog_box)
	dialog_tree.queue_free()
	dialog_box2.queue_free()
	resetDialogBox()
	describe("Chained dialog test")

# test of a dialog that loops with itselfs
func test_loop_self() -> void:
	var dialog_node = DialogNode.new()
	watch(dialog_node,"dialog_done")
	var dialog_tree = DialogTree.new()
	add_child(dialog_tree)
	dialog_tree.add_child(dialog_node)
	dialog_node.NAME = "test"
	dialog_node.DIALOG_KEY = "test"
	dialog_node.BOX_PATH = dialog_node.get_path_to(dialog_box)
	dialog_node.NEXT_DIALOGS = [dialog_node.get_path_to(dialog_node)]
	dialog_tree.STARTS = [dialog_tree.get_path_to(dialog_node)]
	dialog_tree.startDialogs()
	checkDialogStarted(dialog_node,dialog_box)
	skipDialog(dialog_box)
	asserts.signal_was_emitted(dialog_node,"dialog_done","dialog_done signal was emitted")
	checkDialogStarted(dialog_node,dialog_box)
	resetDialogBox()
	dialog_tree.queue_free()
	describe("Loop dialog test")

# Test with multiple starting points
func test_multiple_starts() -> void:
	var dialog_node1 = DialogNode.new()
	var dialog_node2 = DialogNode.new()
	var dialog_tree = DialogTree.new()
	var dialog_box2 = load(dialog_box_template_path).instance()
	dialog_tree.add_child(dialog_node1)
	dialog_tree.add_child(dialog_node2)
	add_child(dialog_tree)
	add_child(dialog_box2)
	watch(dialog_node1,"dialog_done")
	watch(dialog_node2,"dialog_done")
	dialog_node1.NAME = "test1"
	dialog_node1.DIALOG_KEY = "test1"
	dialog_node1.BOX_PATH = dialog_node1.get_path_to(dialog_box)
	dialog_node1.NEXT_DIALOGS = []
	dialog_node2.NAME = "test2"
	dialog_node2.DIALOG_KEY = "test2"
	dialog_node2.BOX_PATH = dialog_node2.get_path_to(dialog_box2)
	dialog_node2.NEXT_DIALOGS = []
	dialog_tree.STARTS = [dialog_tree.get_path_to(dialog_node1),dialog_tree.get_path_to(dialog_node2)]
	dialog_tree.startDialogs()
	checkDialogStarted(dialog_node1,dialog_box)
	checkDialogStarted(dialog_node2,dialog_box2)
	skipDialog(dialog_box)
	skipDialog(dialog_box2)
	checkDialogDone(dialog_node1,dialog_box)
	checkDialogDone(dialog_node2,dialog_box2)
	dialog_tree.queue_free()
	dialog_box2.queue_free()
	resetDialogBox()
	describe("Test of multiple start points")

# Test of a dialog choice leading to another
func test_dialog_choice() -> void:
	var dialog_node1 = DialogNodeChoices.new()
	var dialog_node2_1 = DialogNode.new()
	var dialog_node2_2 = DialogNode.new()
	var dialog_box_choices = load(dialog_box_choices_path).instance()
	var dialog_tree = DialogTree.new()
	add_child(dialog_box_choices)
	dialog_tree.add_child(dialog_node1)
	dialog_tree.add_child(dialog_node2_1)
	dialog_tree.add_child(dialog_node2_2)
	add_child(dialog_tree)
	watch(dialog_node1, "choice_made")
	watch(dialog_node2_1, "dialog_done")
	watch(dialog_node2_2, "dialog_done")
	dialog_node2_1.NAME = "choice1"
	dialog_node2_1.DIALOG_KEY = "choice1"
	dialog_node2_1.BOX_PATH = dialog_node2_1.get_path_to(dialog_box)
	dialog_node2_1.NEXT_DIALOGS = []
	dialog_node2_2.NAME = "choice2"
	dialog_node2_2.DIALOG_KEY = "choice2"
	dialog_node2_2.BOX_PATH = dialog_node2_2.get_path_to(dialog_box)
	dialog_node2_2.NEXT_DIALOGS = []
	dialog_node1.NAME = "test1"
	dialog_node1.DIALOG_KEY = "test1"
	dialog_node1.BOX_PATH = dialog_node1.get_path_to(dialog_box_choices)
	dialog_node1.NEXT_DIALOGS = []
	dialog_node1.CHOICES = [
		{
			"key":"choice 1",
			"name":"choice1",
			"next_dialogs":[dialog_node1.get_path_to(dialog_node2_1)]
		},
		{
			"key":"choice 2",
			"name":"choice2",
			"next_dialogs":[dialog_node1.get_path_to(dialog_node2_2)]
		}
	]
	dialog_tree.STARTS = [dialog_tree.get_path_to(dialog_node1)]
	dialog_tree.startDialogs()
	checkDialogStarted(dialog_node1,dialog_box_choices)
	dialog_box_choices.get_node(dialog_box_choices.OPTIONS_PATH).get_children()[0].emit_signal("pressed")
	var button_label = dialog_box_choices.get_node(dialog_box_choices.OPTIONS_PATH).get_children()[0].text
	asserts.is_false(dialog_node1.get_node(dialog_node1.BOX_PATH).is_connected("dialog_done",dialog_node1,"dialogDone"), "dialog_done disconnected")
	asserts.is_false(dialog_node1.get_node(dialog_node1.BOX_PATH).is_connected("choice_made",dialog_node1,"choiceMade"), "choice_made disconnected")
	asserts.is_false(dialog_node1.isStarted,"Dialog node isStarted false")
	match(button_label):
		"choice 1":
			asserts.signal_was_emitted_with_arguments(dialog_node1,"choice_made",["choice1"], "Choice 1 signal triggered")
			checkDialogStarted(dialog_node2_1,dialog_box)
		"choice 2":
			asserts.signal_was_emitted_with_arguments(dialog_node1,"choice_made",["choice2"], "Choice 2 signal triggered")
			checkDialogStarted(dialog_node2_2,dialog_box)
	dialog_tree.queue_free()
	dialog_box_choices.queue_free()
	resetDialogBox()
	describe("Test of a choice dialog")

# Tests if the stopCurrentDialogs function
func test_stopCurrentDialogs() -> void:
	var dialog_node1 = DialogNode.new()
	var dialog_node2 = DialogNode.new()
	var dialog_box2 = load(dialog_box_template_path).instance()
	var dialog_tree = DialogTree.new()
	add_child(dialog_box2)
	add_child(dialog_tree)
	dialog_tree.add_child(dialog_node1)
	dialog_tree.add_child(dialog_node2)
	dialog_node1.NAME = "test1"
	dialog_node1.DIALOG_KEY = "test1"
	dialog_node1.BOX_PATH = dialog_node1.get_path_to(dialog_box)
	dialog_node2.NEXT_DIALOGS = []
	dialog_node2.NAME = "test2"
	dialog_node2.DIALOG_KEY = "test2"
	dialog_node2.BOX_PATH = dialog_node2.get_path_to(dialog_box2)
	dialog_node2.NEXT_DIALOGS = []
	dialog_tree.STARTS = [dialog_tree.get_path_to(dialog_node1),dialog_tree.get_path_to(dialog_node2)]
	dialog_tree.startDialogs()
	checkDialogStarted(dialog_node1,dialog_box)
	checkDialogStarted(dialog_node2,dialog_box2)
	dialog_tree.stopCurrentDialogs()
	asserts.is_false(dialog_node1.get_node(dialog_node1.BOX_PATH).is_connected("dialog_done",dialog_node1,"dialogDone"), "dialog_done disconnected correctly")
	asserts.is_false(dialog_node1.isStarted,"Dialog node isStarted false")
	asserts.is_false(dialog_box.visible,"Dialog box hidden")
	asserts.is_false(dialog_node2.get_node(dialog_node2.BOX_PATH).is_connected("dialog_done",dialog_node2,"dialogDone"), "dialog_done disconnected correctly")
	asserts.is_false(dialog_node2.isStarted,"Dialog node isStarted false")
	asserts.is_false(dialog_box2.visible,"Dialog box hidden")
	dialog_tree.queue_free()
	dialog_box2.queue_free()
	describe("Test of the stopCurrentDialogs function")
	
