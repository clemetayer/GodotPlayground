extends DialogBoxTemplate
class_name DialogChoicesTemplate

signal custom_signal(name,values)

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
		if(Input.is_action_just_pressed("next_dialog")):
			if (RTL.get_visible_characters() > RTL.get_total_character_count()): 
				if page < len(dialog_pages)-1:
					page += 1
					RTL.set_visible_characters(0)
					RTL.set_bbcode(dialog_pages[page])
				else:
					if(CHOICES.size() == 0):
						RTL.set_visible_characters(0)
						page = 0
						dialog_pages = []
						dialog_started = false
						self.hide()
						emit_signal("dialog_done")
			else: # shows the whole text at once
				RTL.set_visible_characters(RTL.get_total_character_count())

# sets the choices in the dialog box 
func setChoices():
	if(OPTIONS_PATH != null and get_node_or_null(OPTIONS_PATH)):
		for child in get_node(OPTIONS_PATH).get_children(): # clears the current buttons
			child.queue_free()
		for choice in CHOICES:
			var button = Button.new()
			button.text = tr(choice.choice_key)
			button.set_h_size_flags(SIZE_EXPAND_FILL)
			button.connect("pressed",self,"choiceMade",[choice.choice_signal_name,choice.choice_signal_value])
			get_node(OPTIONS_PATH).add_child(button)

# emits the choice made by the player
func choiceMade(choice,values):
	emit_signal("custom_signal", choice, values)
