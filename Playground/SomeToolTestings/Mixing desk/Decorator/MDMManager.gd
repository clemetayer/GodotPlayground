extends Node

# solution 2 : use multiple MDM

export(NodePath) var MDM_PATH
export(String) var BGM_BUS # bus where the BGM should play
export(int) var FILTER_EFFECT_INDEX # filter in bus

var queue = []
var current_song
var current_MDM # reference to the MDM that is currently playing
var switch_song_lock = false # lock to prevent tweens to restart at each frame
var bus_array = [] # list of buses for tracks
const amplifier_effect_index = 0
const filter_effect_index = 1

######## USER FUNCTIONS ########
func addToQueue(song,transition) -> void:
	queue.append({
		"song":song,
		"transition":transition
	})

######## MANAGER FUNCTIONS #########
# Handles the queue
func handleQueue() -> void:
	if(queue.size() > 0):
		var element = queue.pop_front()
		if(current_song != null): # a song is currently playing; NOTE : not using "is_instance_valid" because it is a dictionnary (the elements in it are freed and it should be set as null in this case)
			if(current_song.NAME == element.song.NAME): # same song, adds or removes some track if necessary
				updateSong(element.song,element.transition)
			elif(not switch_song_lock): # play next song
				switchSong(element.song,element.transition)
		else:
			addSong(element.song,element.transition)

# updates the current song playing
func updateSong(song, transition) -> void:
	var update_tracks = current_song.getUpdateTracks(song)
	var tween = Tween.new()
	var transition_time = computeTransitionTime(transition,song.getSong().tempo,song.getSong().beats_in_bar)
	for track in update_tracks:
		if(track.play):
			current_MDM.unmute(song.NAME,track.name)
		tween = initTransitionTween(track.play,transition,getBusTrack(track.name),transition_time,tween)
	$Tweens.add_child(tween)
	tween.start()
	yield(tween,"tween_all_completed")
	tween.queue_free()
	for track in update_tracks:
		if(not track.play):
			current_MDM.mute(song.NAME,track.name)

# skips to the next song with specific transition type
func switchSong(song, transition) -> void :
	switch_song_lock = true
	yield(removeSongs(transition),"completed")
	addSong(song,transition)
	switch_song_lock = false

# transitions out the song if needed, returns true if fade out tween is being used for this
# TODO
func removeSongs(_transition) -> void:
	pass

# adds the songs in song, and plays it with transition_type
func addSong(song,transition) -> void:
	var tracks = song.getStreamsList()
	current_song = song
	for track in tracks: # create a transition bus for each track (for further transitions) and sets the track to the bus
		bus_array.append({
			"trackName":track.name,
			"busName":song.name + ":" + track.name,
			"sendTo":track.bus
		})
		var bus_name = createTransitionBus(song.name + ":" + track.name, track.bus)
		song.setBusOnTrack(track.name,bus_name)
	var bus_name = createTransitionBus("A:" + song.name,BGM_BUS)
	redirectTracksBusTo(bus_name)
	var transition_time = computeTransitionTime(transition,song.getSong().tempo,song.getSong().beats_in_bar)
	var tween = initTransitionTween(true,transition,bus_name,transition_time)
	current_MDM = song.getMDM().duplicate()
	$MDMs.add_child(current_MDM)
	current_MDM.quickplay(song.NAME)
	for track in song.SONG_INFO:
		if not track.play:
			current_MDM.mute(song.NAME, track.name)
	$Tweens.add_child(tween)
	tween.start()
	yield(tween,"tween_all_completed") 
	tween.queue_free()
	redirectTracksBusDefault()
	AudioServer.remove_bus(AudioServer.get_bus_index(bus_name)) # removes the bus used for the transition

# gets the node in mdm that has a specific name
func getSongInMDM(name : String):
	for node in current_MDM.get_children():
		if(node.name == name):
			return node

# redirects all the buses declared in bus_array
func redirectTracksBusTo(redirect : String) -> void:
	for bus in bus_array:
		AudioServer.set_bus_send(AudioServer.get_bus_index(bus.busName),redirect)

# resets the all the buses declared in bus_array to their default send to value
func redirectTracksBusDefault() -> void:
	for bus in bus_array:
		AudioServer.set_bus_send(AudioServer.get_bus_index(bus.busName),bus.sendTo)

# returns the bus corresponding to the track
func getBusTrack(track : String) -> String:
	for bus in bus_array:
		if(bus.trackName == track):
			return bus.busName
	printerr("track %s not found in bus array !" % track)
	return BGM_BUS

# creates a temporary bus to handle transitionning tracks
func createTransitionBus(name : String, send_to : String) -> String:
	var bus_index = AudioServer.bus_count # Note : bus indexes starts at 0
	AudioServer.add_bus(bus_index)
	AudioServer.add_bus_effect(bus_index,AudioEffectAmplify.new(),amplifier_effect_index)
	AudioServer.add_bus_effect(bus_index,AudioEffectFilter.new(),filter_effect_index)
	AudioServer.set_bus_name(bus_index,name)
	AudioServer.set_bus_send(bus_index,send_to)
	return name

# computes the transition in/out times [transition_in,transition_out]
func computeTransitionTime(transition : TransitionTemplate, tempo : int, beats_per_bar : int) -> Array:
	var transition_time = [0,0]
	# computes the fade time
	match(transition.FADE_TIMING):
		TransitionTemplate.fade_timing.time:
			transition_time[0] = transition.FADE_IN_TIME
			transition_time[1] = transition.FADE_OUT_TIME
		TransitionTemplate.fade_timing.beat:
			transition_time[0] = transition.FADE_IN_TIME * (60.0/tempo)
			transition_time[1] = transition.FADE_OUT_TIME * (60.0/tempo)
		TransitionTemplate.fade_timing.bar:
			transition_time[0] = transition.FADE_IN_TIME * (60.0 / tempo) * beats_per_bar
			transition_time[1] = transition.FADE_OUT_TIME * (60.0 / tempo) * beats_per_bar
	return transition_time

# initializes the tween for the transition (does not start it)
# custom_tween is an optionnal parameter if you want to use a specific tween (to interpolate multiple properties at once for instance)
func initTransitionTween(fade_in : bool, transition : TransitionTemplate, bus_name : String, transition_time : Array, custom_tween : Tween = null) -> Tween:
	var tween
	if(custom_tween == null):
		tween = Tween.new()
	else:
		tween = custom_tween
	if(fade_in): # fade in
		# sets the fade
		match(transition.FADE_TYPE):
			TransitionTemplate.fade_type.instant:
				pass
			TransitionTemplate.fade_type.volume:
				pass
			TransitionTemplate.fade_type.filter:
				tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), filter_effect_index),
					"cutoff_hz",
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), filter_effect_index).cutoff_hz,
					0,
					transition_time[0])
	else: # fade out
		# sets the fade
		match(transition.FADE_TYPE):
			TransitionTemplate.fade_type.instant:
				pass
			TransitionTemplate.fade_type.volume:
				pass
			TransitionTemplate.fade_type.filter:
				tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), filter_effect_index),
					"cutoff_hz",
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), filter_effect_index).cutoff_hz,
					0,
					transition_time[1])
	return tween

######## ROUTINES ########
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handleQueue()

func _on_MixingDeskMusic_bar():
	print("bar")

func _on_MixingDeskMusic_beat():
	print("beat")

func _on_MixingDeskMusic_end():
	print("end")

func _on_MixingDeskMusic_shuffle():
	print("shuffled")

func _on_MixingDeskMusic_song_changed():
	print("song changed")
