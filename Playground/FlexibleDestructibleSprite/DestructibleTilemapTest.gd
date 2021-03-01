extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
#	if(Input.is_action_just_pressed("next_dialog")):
#		var img = $ViewportContainer/Viewport.get_texture().get_data()
#		img.flip_y()
#		img.save_png("res://FlexibleDestructibleSprite/test.png")

func destructibleLoaded():
	print("Destructible loaded !")
