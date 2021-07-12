extends WAT.Test

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var dialog_box_path = "res://tests/Dialogs/Dialog1/DialogBox.tscn"
var dialog_box

##### PROCESSING #####
func pre():
	dialog_box = load(dialog_box_path).instance()
	add_child(dialog_box)

func post():
	dialog_box.queue_free()

func title() -> String:
	return "Test of a dialog cancel node"

##### UTILS #####
# Resets the dialog box to its standard values
func resetDialogBox():
	dialog_box.stopDialog()
	dialog_box.RTL.text = ""
	dialog_box.DIALOG = ""
	dialog_box.sound.stop()
	dialog_box.test_emulate_next_dialog_key = false

##### TEST FUNCTIONS #####
# Functions to be tested
func test_dialog_with_timer() -> void:
	var dialog_node = DialogNodeCancel.new()
	add_child(dialog_node)
	watch(dialog_node,"dialog_done")
	dialog_node.NAME = "test"
	dialog_node.DIALOG_KEY = "A particulary long string that takes more than one second to complete."
	dialog_node.BOX_PATH = dialog_node.get_path_to(dialog_box)
	dialog_node.NEXT_DIALOGS = []
	dialog_node.CANCEL_TIME = 1.0
	dialog_node.startDialog()
	yield(until_timeout(0.9),YIELD)
	asserts.is_true(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done connected")
	asserts.is_true(dialog_node.isStarted,"Dialog node isStarted true")
	asserts.is_true(dialog_box.visible, "Dialog box visible")
	asserts.is_true(dialog_box.dialog_started, "dialog_started true")
	asserts.is_true(dialog_box.get_node(dialog_box.TEXT_PATH).get_visible_characters() > 5, "at least some characters are displayed")
	asserts.is_equal(dialog_box.page, 0, "Page = 0")
	asserts.is_equal(dialog_box.DIALOG, tr(dialog_node.DIALOG_KEY), "Dialog correctly set")
	yield(until_timeout(0.2),YIELD)
	asserts.is_false(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done disconnected correctly")
	asserts.is_false(dialog_node.isStarted,"Dialog node isStarted false")
	asserts.signal_was_emitted(dialog_node,"dialog_done","dialog_done signal was emitted")
	describe("Test of a dialog cancelled by a timer")
