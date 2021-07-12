extends DialogNode
class_name DialogNodeCancel

##### VARIABLES #####
#---- EXPORTS -----
export(float) var CANCEL_TIME # Time after start for the node to cancel

#---- STANDARD -----
var timer # Cancel timer

##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = CANCEL_TIME
	timer.connect("timeout",self,"cancelDialog")
	add_child(timer)

# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
# func _process(_delta):
#     pass

##### USER FUNCTIONS #####
# start the dialog (overrided from parent)
func startDialog():
	.startDialog()
	timer.start()

# stops the dialog (if it has started) (overrided from parent)
func stopDialog():
	.stopDialog()
	timer.stop()

##### NODE FUNCTIONS #####
# Functions that are intended to be used exclusively by this script

##### SIGNAL MANAGEMENT #####
func cancelDialog():
	get_node(BOX_PATH).stopDialog()
	dialogDone()
