extends Node
class_name TransitionTemplate

enum fade_type {instant,volume,filter} # no fade, volume fade, lowpass filter fade
enum fade_timing {time,beat,bar} # time (in seconds), next beats, next bars

export(fade_type) var FADE_TYPE # how it should fade
export(fade_timing) var FADE_TIMING # on what it should fade
export(float) var FADE_IN_TIME # how much time new song should take to fade in
export(float) var FADE_OUT_TIME # how much time old song should take to fade in

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
