extends WAT.Test
class_name DialogNodeUTest

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var dialog_box_path = "res://tests/Dialogs/Dialog1/DialogBox.tscn"
var dialog_box : DialogBox

##### PROCESSING #####
func pre():
	dialog_box = load(dialog_box_path).instance()
	add_child(dialog_box)

func post():
	dialog_box.queue_free()

func title() -> String:
	return "Dialog node tests"

##### UTILS #####
# Resets the dialog box to its standard values
func resetDialogBox():
	dialog_box.stopDialog()
	dialog_box.RTL.text = ""
	dialog_box.DIALOG = ""
	dialog_box.sound.stop()
	dialog_box.test_emulate_next_dialog_key = false

# Common test to check a dialog start
func startDialogAsserts(dialog_node):
	dialog_node.startDialog()
	asserts.is_true(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done connected")
	asserts.is_true(dialog_node.isStarted,"Dialog node isStarted true")
	asserts.is_true(dialog_box.visible, "Dialog box visible")
	asserts.is_true(dialog_box.dialog_started, "dialog_started true")
	asserts.is_equal(dialog_box.page, 0, "Page = 0")
	asserts.is_equal(dialog_box.DIALOG, tr(dialog_node.DIALOG_KEY), "Dialog correctly set")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_false(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done disconnected correctly")
	asserts.is_false(dialog_node.isStarted,"Dialog node isStarted false")
	asserts.signal_was_emitted(dialog_node,"dialog_done","dialog_done signal was emitted")

##### TEST FUNCTIONS #####
# test of the "triggerMethodOnDialog" function
func test_triggerMethodOnDialog() -> void:
	var dialog_node = DialogNode.new()
	add_child(dialog_node)
	dialog_node.BOX_PATH = dialog_node.get_path_to(dialog_box)
	dialog_node.NEXT_DIALOGS = []
	asserts.is_true(dialog_node.triggerMethodOnDialog("test_function",[1,true]), "Custom test method returning true")
	dialog_node.queue_free()
	resetDialogBox()
	describe("Test of the function triggerMethodOnDialog")

# test a one step dialog (on one box and no next dialog) 
func test_start_dialog() -> void:
	var dialog_node = DialogNode.new()
	add_child(dialog_node)
	watch(dialog_node,"dialog_done")
	dialog_node.NAME = "test"
	dialog_node.DIALOG_KEY = "test"
	dialog_node.BOX_PATH = dialog_node.get_path_to(dialog_box)
	dialog_node.NEXT_DIALOGS = []
	dialog_node.startDialog()
	startDialogAsserts(dialog_node)
	dialog_node.queue_free()
	resetDialogBox()
	describe("Test of a one step dialog")

func test_stop_dialog() -> void:
	var dialog_node = DialogNode.new()
	add_child(dialog_node)
	watch(dialog_node,"dialog_done")
	dialog_node.NAME = "test"
	dialog_node.DIALOG_KEY = "test"
	dialog_node.BOX_PATH = dialog_node.get_path_to(dialog_box)
	dialog_node.NEXT_DIALOGS = []
	dialog_node.startDialog()
	asserts.is_true(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done connected")
	dialog_box.processFunction(0.1)
	dialog_node.stopDialog()
	asserts.is_false(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done disconnected correctly")
	asserts.is_false(dialog_node.isStarted,"Dialog node isStarted false")
	asserts.signal_was_not_emitted(dialog_node,"dialog_done","dialog_done signal was not emitted (to make dialog_done management in tree easier)")
	resetDialogBox()
	startDialogAsserts(dialog_node)
	dialog_node.queue_free()
	resetDialogBox()
	describe("Test of the stopDialog function")
