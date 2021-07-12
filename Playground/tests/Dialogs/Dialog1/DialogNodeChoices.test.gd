extends WAT.Test

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### ENUMS #####
# enumerations

##### VARIABLES #####
var dialog_choices_path = "res://tests/Dialogs/Dialog1/DialogBoxChoices.tscn"
var dialog_box

##### PROCESSING #####
func pre():
	dialog_box = load(dialog_choices_path).instance()
	add_child(dialog_box)

func post():
	 dialog_box.queue_free()

func title() -> String:
	return "Dialog node choices tests"

##### UTILS #####
# Resets the dialog box to its standard values
func resetDialogBox():
	dialog_box.stopDialog()
	dialog_box.RTL.text = ""
	dialog_box.DIALOG = ""
	dialog_box.sound.stop()
	dialog_box.test_emulate_next_dialog_key = false
	dialog_box.CHOICES = []
	dialog_box.setChoices()

##### TEST FUNCTIONS #####
# Test of a dialog choice
func test_dialog_choice() -> void:
	var dialog_node = DialogNodeChoices.new()
	add_child(dialog_node)
	watch(dialog_node,"dialog_done")
	watch(dialog_node,"choice_made")
	dialog_node.NAME = "test"
	dialog_node.DIALOG_KEY = "test"
	dialog_node.BOX_PATH = dialog_node.get_path_to(dialog_box)
	dialog_node.NEXT_DIALOGS = []
	dialog_node.CHOICES = [
		{
			"key":"choice 1",
			"name":"test1",
			"next_dialogs":[]
		},
		{
			"key":"choice 2",
			"name":"test2",
			"next_dialogs":[]
		}
	]
	dialog_node.startDialog()
	asserts.is_true(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done connected")
	asserts.is_true(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("choice_made",dialog_node,"choiceMade"), "choice_made connected")
	asserts.is_true(dialog_node.isStarted,"Dialog node isStarted true")
	asserts.is_true(dialog_box.visible, "Dialog box visible")
	asserts.is_true(dialog_box.dialog_started, "dialog_started true")
	asserts.is_equal(dialog_box.page, 0, "Page = 0")
	asserts.is_equal(dialog_box.DIALOG, tr(dialog_node.DIALOG_KEY), "Dialog correctly set")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_true(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done still connected")
	asserts.is_true(dialog_node.isStarted,"Dialog node isStarted still true")
	asserts.signal_was_not_emitted(dialog_node,"dialog_done","dialog_done signal was not emitted yet")
	dialog_box.get_node(dialog_box.OPTIONS_PATH).get_children()[0].emit_signal("pressed")
	asserts.is_false(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("dialog_done",dialog_node,"dialogDone"), "dialog_done disconnected correctly")
	asserts.is_false(dialog_node.get_node(dialog_node.BOX_PATH).is_connected("choice_made",dialog_node,"choiceMade"), "choice_made disconnected correctly")
	asserts.is_false(dialog_node.isStarted,"Dialog node isStarted false")
	asserts.signal_was_not_emitted(dialog_node,"dialog_done","dialog_done signal was not emitted")
	asserts.signal_was_emitted_with_arguments(dialog_node,"choice_made",[dialog_node.CHOICES[0].name],"signal choice_made emitted with correct arg")
	dialog_node.queue_free()
	resetDialogBox()
	describe("Test of the dialog with choices function")
