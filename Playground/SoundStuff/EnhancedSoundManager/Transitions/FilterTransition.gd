extends TransitionTemplate

enum time_type {time,beat,bar}
export(time_type) var TIME_TYPE = time_type.time

# computes the transition in/out times [transition_in,transition_out] in seconds
# overrided from parent
func computeTransitionTime(tempo : int, beats_per_bar : int) -> Array:
	var transition_time = [0,0]
	# computes the fade time
	match(TIME_TYPE):
		time_type.time:
			transition_time[0] = FADE_IN_TIME
			transition_time[1] = FADE_OUT_TIME
		time_type.beat:
			transition_time[0] = FADE_IN_TIME * (60.0/tempo)
			transition_time[1] = FADE_OUT_TIME * (60.0/tempo)
		time_type.bar:
			transition_time[0] = FADE_IN_TIME * (60.0 / tempo) * beats_per_bar
			transition_time[1] = FADE_OUT_TIME * (60.0 / tempo) * beats_per_bar
	return transition_time

# initializes the tween for the transition (does not start it)
# overrided from parent
func initTransitionTween(fade_in : bool, bus_name : String, transition_time : Array, effects : Dictionary, custom_tween : Tween = null) -> Tween:
	var tween : Tween
	if(custom_tween == null):
		tween = Tween.new()
	else:
		tween = custom_tween
	if(fade_in): # fade in
		var _val = tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effects.filter),
					"cutoff_hz",
					0,
					10000,
					transition_time[0])
	else: # fade out
		var _val = tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effects.filter),
					"cutoff_hz",
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effects.filter).cutoff_hz,
					0,
					transition_time[1])
	return tween
