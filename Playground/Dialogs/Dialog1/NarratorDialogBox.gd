extends DialogBoxChoices

##### PROCESSING #####
# Called when the node enters the scene tree for the first time.
# func _ready():
#     pass

# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
# func _process(_delta):
#     pass

##### USER FUNCTIONS #####
# a method to test method triggering in dialogs
func testMethod(arg1 : int, arg2 : String):
	print("Method on narrator triggered : [%d,%s]" % [arg1,arg2])
