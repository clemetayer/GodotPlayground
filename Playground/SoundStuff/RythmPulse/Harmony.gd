extends Particles2D

export(float) var FREQUENCY = 300
export(float) var RANGE = 200
export(float) var TRESHOLD =  0.06

var spectrum
var maxi
var cnt

# Called when the node enters the scene tree for the first time.
func _ready():
	maxi = 0
	cnt = 0
	spectrum = AudioServer.get_bus_effect_instance(1,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var magnitude = spectrum.get_magnitude_for_frequency_range(FREQUENCY - RANGE/2, FREQUENCY + RANGE/2).length()
	
#	print("magnitude = " + str(magnitude) + "; maxi = " + str(maxi))
#	if(magnitude > maxi):
#		maxi = magnitude
	if(magnitude > TRESHOLD):
		emitting = true
		cnt += 1
		print("cnt = ", cnt)
	else:
		emitting = false
