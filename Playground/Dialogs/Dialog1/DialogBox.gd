extends Control
class_name DialogBox

export(float) var TEXT_SPEED = 0.05 # timeout time before showing another character
export(String) var DIALOG = "" # dialog string
export(NodePath) var TEXT_PATH # path of the RTL where the text should be displayed
export(AudioStream) var CHAR_SOUND # sound that should be played at each character

signal dialog_done()

var dialog_started = false # true if dialog has started
var dialog_pages = [] # pages of dialog if the whole dialog doesn't fit in one page
var page = 0 # current dialog page
var RTL_char_timer = Timer # timer to display characters
var sound = AudioStreamPlayer2D # stream of CHAR_SOUND

var test_emulate_next_dialog_key = false # key to emulate skipping to the next dialog, for unitary testing purposes

onready var RTL = get_node(TEXT_PATH) # Rich text label access shortcut because it is accessed a lot

##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	readyFunction()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	processFunction(delta)

##### USER FUNCTIONS #####
# Starts the dialog 
func startDialog():
	self.show()
	computeDialogPages()
	RTL_char_timer.wait_time = TEXT_SPEED
	RTL_char_timer.start(TEXT_SPEED)
	page = 0
	RTL.set_visible_characters(0)
	RTL.set_bbcode(dialog_pages[page])
	dialog_started = true

# Stops the dialog
func stopDialog():
	self.hide()
	RTL_char_timer.stop()
	page = 0
	RTL.set_visible_characters(0)
	RTL.set_bbcode(dialog_pages[page])
	dialog_started = false

##### DIALOG BOX TEMPLATE FUNCTIONS #####
# divides the dialog in dialogPages
func computeDialogPages():
	dialog_pages = []
	var rect_text_size = RTL.get_font("normal_font").get_string_size(DIALOG) # get the text rectangle size
	var RTL_size = RTL.rect_size
	var nb_lines = rect_text_size.x/RTL_size.x
	var nb_lines_per_pages = RTL_size.y/rect_text_size.y - 1 # -1 just to be sure everything will fit
	var nb_pages = nb_lines/nb_lines_per_pages
	var avg_nb_letters_per_page = DIALOG.length()/nb_pages
	var l_string_index = 0
	for page_index in range(1, int(nb_pages) + 1): # starting at beginning of page 1 for rStringIndex
		var r_string_index = page_index * int(avg_nb_letters_per_page)
		if(r_string_index <= DIALOG.length()):
			while(r_string_index > l_string_index and DIALOG[r_string_index] != ' '):
				r_string_index -= 1
			if(r_string_index == l_string_index): # the last word (alone) doesn't fit in one page
				dialog_pages.append(DIALOG.substr(l_string_index,page_index * int(avg_nb_letters_per_page))) # FIXME : sometimes, text goes out of the dialog box, but that's a very specific case so ¯\_(ツ)_/¯
				r_string_index = page_index * int(avg_nb_letters_per_page)
			else:
				dialog_pages.append(DIALOG.substr(l_string_index,r_string_index))
		l_string_index = r_string_index
	if(l_string_index < DIALOG.length() - 1):
		dialog_pages.append(DIALOG.substr(l_string_index,DIALOG.length()))

# triggered when RTL char timer is timeout
func nextChar():
	if(dialog_started and RTL.get_visible_characters() < RTL.text.length()):
		RTL.set_visible_characters(RTL.get_visible_characters()+1)
		sound.play()

# special function process to allow overriding in children
func processFunction(_delta):
	if(dialog_started):
		if(Input.is_action_just_pressed("next_dialog") or test_emulate_next_dialog_key):
			if (RTL.get_visible_characters() >= RTL.text.length()): 
				if page < len(dialog_pages)-1:
					page += 1
					RTL.set_visible_characters(0)
					RTL.set_bbcode(dialog_pages[page])
				else:
					RTL.set_visible_characters(0)
					page = 0
					dialog_started = false
					self.hide()
					emit_signal("dialog_done")
			else: # shows the whole text at once
				RTL.set_visible_characters(RTL.text.length())

# special function ready to allow overriding in children
func readyFunction():
	self.hide()
	RTL_char_timer = Timer.new()
	RTL_char_timer.connect("timeout",self,"nextChar")
	add_child(RTL_char_timer)
	sound = AudioStreamPlayer2D.new()
	sound.stream = CHAR_SOUND
	add_child(sound)
