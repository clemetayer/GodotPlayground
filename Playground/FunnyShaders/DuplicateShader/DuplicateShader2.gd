tool
extends Particles2D


var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = Vector2(200 * cos(time) - 100, 200 * sin(time) - 100)
	time = fmod(time+delta,2*PI)

