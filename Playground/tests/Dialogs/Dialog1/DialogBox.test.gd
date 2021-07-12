extends WAT.Test
class_name DialogBoxUTest

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
	return "Dialog box template tests"

##### UTILS #####
# Resets the dialog box to its standard values
func resetDialogBox():
	dialog_box.stopDialog()
	dialog_box.RTL.text = ""
	dialog_box.DIALOG = ""
	dialog_box.sound.stop()
	dialog_box.test_emulate_next_dialog_key = false

##### TEST FUNCTIONS #####
# Test of the compute dialog pages function
func test_compute_dialog_pages():
	dialog_box.DIALOG = "test 1 dialog"
	dialog_box.computeDialogPages()
	asserts.is_equal(1,dialog_box.dialog_pages.size(),"Short dialog on one page")
	dialog_box.DIALOG = "test 2 dialog, something way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way way longer"
	dialog_box.computeDialogPages()
	asserts.is_equal(3,dialog_box.dialog_pages.size(),"Long dialog on three pages")
	resetDialogBox()
	describe("Test of the 'computeDialogPages' function")

# Test of the ready function
func test_ready_function():
	asserts.is_false(dialog_box.visible,"Dialog box hidden")
	asserts.is_true(dialog_box.RTL_char_timer != null and dialog_box.has_node(dialog_box.RTL_char_timer.get_path()), "Timer created and in tree")
	asserts.that(dialog_box.RTL_char_timer, "is_connected", ["timeout", dialog_box, "nextChar"], "Timer is connected to nextChar", "Timer is not connected to nextChar")
	asserts.is_true(dialog_box.sound != null and dialog_box.has_node(dialog_box.sound.get_path()), "Sound stream created and added to tree")
	resetDialogBox()
	describe("Test of the 'readyFunction'")

# Test if the "nextChar" function
func test_nextCharFunction():
	dialog_box.RTL.set_bbcode("test")
	dialog_box.dialog_started = true
	dialog_box.RTL.set_visible_characters(0)
	for i in range(1,"test".length() + 1):
		dialog_box.nextChar()
		asserts.is_equal(i,dialog_box.RTL.get_visible_characters(), "Correct amount of characters for %s" % ["test".substr(0,i)])
		asserts.is_equal("test".substr(0,i),dialog_box.RTL.get_text().substr(0,dialog_box.RTL.get_visible_characters()), "Correct text for %s" % ["test".substr(0,i)])
		asserts.is_true(dialog_box.sound.playing, "Character sound playing")
		dialog_box.sound.stop()
	dialog_box.nextChar()
	asserts.is_equal(4,dialog_box.RTL.get_visible_characters(), "Correct amount of characters when string is done")
	asserts.is_equal("test",dialog_box.RTL.get_text(), "Correct text when string is done")
	asserts.is_false(dialog_box.sound.playing, "Character sound not playing")
	resetDialogBox()
	describe("Test of the 'nextChar' function")

# Test of a standard dialog on one page
func test_dialog_single_page_no_skip():
	watch(dialog_box,"dialog_done")
	dialog_box.DIALOG = "test dialog on a single page"
	dialog_box.startDialog()
	asserts.is_true(dialog_box.visible,"Dialog box visible when starting the dialog")
	yield(until_timeout(dialog_box.TEXT_SPEED * (dialog_box.DIALOG.length() + 1)), YIELD) # wait for dialog to be done displaying
	asserts.is_equal(dialog_box.DIALOG, dialog_box.RTL.get_text().substr(0,dialog_box.RTL.get_visible_characters()), "Text entirely displayed")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_false(dialog_box.visible,"Dialog box hidden on dialog done")
	asserts.signal_was_emitted(dialog_box,"dialog_done", "Dialog done emitted")
	resetDialogBox()
	describe("Test of the dialog on a single page without skipping")

# Test of a standard dialog on one page but skipping this time
func test_dialog_single_page_skip():
	watch(dialog_box,"dialog_done")
	dialog_box.DIALOG = "test dialog on a single page"
	dialog_box.startDialog()
	asserts.is_true(dialog_box.visible,"Dialog box visible when starting the dialog")
	yield(until_timeout(dialog_box.TEXT_SPEED * (dialog_box.DIALOG.length() + 1) / 2), YIELD) # wait for dialog to be half done displaying
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_equal(dialog_box.DIALOG, dialog_box.RTL.get_text().substr(0,dialog_box.RTL.get_visible_characters()), "Text entirely displayed")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_false(dialog_box.visible,"Dialog box hidden on dialog done")
	asserts.signal_was_emitted(dialog_box,"dialog_done", "Dialog done emitted")
	resetDialogBox()
	describe("Test of the dialog on a single page with skipping")

# test multiple pages
func test_dialog_multiple_pages():
	watch(dialog_box,"dialog_done")
	dialog_box.DIALOG = "test on multiple pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages pages"
	dialog_box.startDialog()
	asserts.is_true(dialog_box.visible,"Dialog box visible when starting the dialog")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_equal(dialog_box.dialog_pages[dialog_box.page], dialog_box.RTL.get_text().substr(0,dialog_box.RTL.get_visible_characters()), "Text entirely displayed")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_equal(dialog_box.page, 1, "Next page")
	asserts.signal_was_not_emitted(dialog_box,"dialog_done","Dialog done not emitted")
	asserts.is_equal(dialog_box.RTL.get_visible_characters(),0,"Number of characters shown on new page = 0")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.is_equal(dialog_box.dialog_pages[dialog_box.page], dialog_box.RTL.get_text().substr(0,dialog_box.RTL.get_visible_characters()), "Text entirely displayed")
	dialog_box.test_emulate_next_dialog_key = true
	dialog_box.processFunction(0.1)
	dialog_box.test_emulate_next_dialog_key = false
	asserts.signal_was_emitted(dialog_box,"dialog_done","Dialog done emitted")
	resetDialogBox()
	describe("Test of the dialog on a multiple pages")
