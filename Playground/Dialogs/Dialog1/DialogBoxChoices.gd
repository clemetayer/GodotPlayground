extends DialogBox
class_name DialogBoxChoices

signal choice_made(name)

export(Array,Dictionary) var CHOICES = [] # options to show
export(NodePath) var OPTIONS_PATH = null # path to the choices HBox

##### USER FUNCTIONS #####
# Overrided from parent
func startDialog():
	setChoices()
	.startDialog()

##### DIALOG CHOICES TEMPLATE FUNCTION #####
# Overrided from parent
func processFunction(_delta):
	if(dialog_started):
		if(Input.is_action_just_pressed("next_dialog") or test_emulate_next_dialog_key):
			if (RTL.get_visible_characters()>= RTL.text.length()): 
				if page < len(dialog_pages)-1:
					page += 1
					RTL.set_visible_characters(0)
					RTL.set_bbcode(dialog_pages[page])
				elif(CHOICES.size() == 0):
					RTL.set_visible_characters(0)
					page = 0
					dialog_pages = []
					dialog_started = false
					self.hide()
					emit_signal("dialog_done")
			else: # shows the whole text at once
				RTL.set_visible_characters(RTL.text.length())

# sets the choices in the dialog box 
func setChoices():
	var options = get_node_or_null(OPTIONS_PATH)
	if(options != null):
		for child in options.get_children(): # clears the current buttons
			child.queue_free()
		for choice in CHOICES:
			var button = Button.new()
			button.text = tr(choice.key)
			button.set_h_size_flags(SIZE_EXPAND_FILL)
			button.connect("pressed",self,"choiceMade",[choice.name])
			options.add_child(button)

# emits the choice made by the player
func choiceMade(name):
	emit_signal("choice_made",name)
