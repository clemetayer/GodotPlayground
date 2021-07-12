extends DialogBoxUTest

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var dialog_choices_path = "res://tests/Dialogs/Dialog1/DialogBoxChoices.tscn"

##### PROCESSING #####
func pre():
	dialog_box = load(dialog_choices_path).instance()
	add_child(dialog_box)

func post():
	 dialog_box.queue_free()

func title() -> String:
	return "Dialog choices template tests"

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
# Test of the "setChoices" function
# Note : impossible to test translation because TranslationServer is not active with the "tool" keyword.
# That means the "tr()" won't activate.
# A workaround could be to "force" the translation like how it was done to emulate a key press
func test_setChoices_function() -> void:
	dialog_box.CHOICES = [{"key":"tests_Dialog1_DialogChoice_choice1","name":"Choice1"},
	{"key":"tests_Dialog1_DialogChoice_choice2","name":"Choice2"}]
	dialog_box.setChoices()
	asserts.is_equal(dialog_box.get_node(dialog_box.OPTIONS_PATH).get_child_count(),2,"Two childrens in options")
	for button in dialog_box.get_node(dialog_box.OPTIONS_PATH).get_children():
		asserts.is_class_instance(button,Button,"Choice is a button")
	asserts.is_not_equal(dialog_box.get_node(dialog_box.OPTIONS_PATH).get_children()[0].text, dialog_box.get_node(dialog_box.OPTIONS_PATH).get_children()[1].text, "Buttons have different texts")
	# Test reset to no choices
	dialog_box.CHOICES = []
	dialog_box.setChoices()
	yield(until_timeout(0.3), YIELD) # Waits for the dialog box to be queue freed (should be less than 0.3s)
	asserts.is_equal(dialog_box.get_node(dialog_box.OPTIONS_PATH).get_child_count(),0,"Old options were freed")
	resetDialogBox()
	describe("Test setChoices function")

# Test of a choice dialog
func test_choice_dialog() -> void:
	watch(dialog_box,"choice_made")
	dialog_box.CHOICES = [{"key":"choice1","name":"Choice1"},
	{"key":"choice2","name":"Choice2"}]
	dialog_box.startDialog()
	asserts.is_true(dialog_box.visible,"Dialog box visible when starting the dialog")
	asserts.is_equal(dialog_box.get_node(dialog_box.OPTIONS_PATH).get_child_count(),2,"Choices added")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_equal(dialog_box.DIALOG, dialog_box.RTL.get_text().substr(0,dialog_box.RTL.get_visible_characters()), "Text entirely displayed")
	asserts.is_true(dialog_box.visible,"Dialog box still displaying even though the dialog is done")
	for choice in dialog_box.get_node(dialog_box.OPTIONS_PATH).get_children():
		choice.emit_signal("pressed")
		match(choice.text):
			"choice1":
				asserts.signal_was_emitted_with_arguments(dialog_box, "choice_made", ["Choice1"], "Correct choice_made emitted")
			"choice2":
				asserts.signal_was_emitted_with_arguments(dialog_box, "choice_made", ["Choice2"], "Correct choice_made emitted")
	describe("Test dialog choice")
