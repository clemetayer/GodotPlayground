extends Node
# inspired from Godot mixing desk : https://github.com/kyzfrintin/Godot-Mixing-Desk

# TODO : implement signal song done
# TODO : implement loop and play_once
# ARCHITECTURE : let the transition setup the tween ?
# FIXME : """loud""" noise on song start/end
# TODO : implement on next beat transition

enum play_style {play_once,loop}
enum effects {amplifier,filter}

export(String) var BGM_BUS = "Master"

signal song_changed(old_song,new_song)

var queue = []
var bus_array = []
var is_playing : bool
var switch_song_lock = false
var current_song : DefaultSong
var current_play_style

##### USER FUNCTIONS #####

# returns true if the song is playing
func isPlaying() -> bool:
	return is_playing

# adds the song to queue
func addSongToQueue(song : DefaultSong, transition : TransitionTemplate) -> void:
	queue.append({"song":song,"transition":transition})

##### MANAGER FUNCTIONS #####

# handles the song queue
func handleQueue() -> void:
	if(queue.size() > 0):
		var music = queue.pop_front() # OPTIMIZATION : free at the right moment ?
		if(current_song != null): # a song is currently playing; NOTE : not using "is_instance_valid" because it is a dictionnary (the elements in it are freed and it should be set as null in this case)
			if(current_song.NAME == music.song.NAME): # same song,set new loop to play eventually
				updateSong(music.song, music.transition)
			elif(not switch_song_lock): # play next song
				switchSong(music.song,music.transition)
		else:
			addSong(music.song,music.transition)

# updates if necessary the current song playing (especially if new tracks should be playing)
func updateSong(song : DefaultSong, transition : TransitionTemplate):
	var diff_tracks = $MainMixingDesk.compareSongsPlayValues(song,$MainMixingDesk.getCurrent())
	for track in diff_tracks:
		updateTrack(song,track,transition,getBusTrack(track))
		current_song.setPlay(track,song.isPlaying(track))

# creates a temporary bus to handle transitionning tracks
func createTransitionBus(name : String, send_to : String) -> String:
	var bus_index = AudioServer.bus_count # Note : bus indexes starts at 0
	AudioServer.add_bus(bus_index)
	AudioServer.add_bus_effect(bus_index,AudioEffectAmplify.new(),effects.amplifier)
	AudioServer.add_bus_effect(bus_index,AudioEffectFilter.new(),effects.filter)
	AudioServer.set_bus_name(bus_index,name)
	AudioServer.set_bus_send(bus_index,send_to)
	return name

# updates the track at track_index
func updateTrack(song : DefaultSong, track : String, transition : TransitionTemplate, transition_bus_name : String):
	var tween : Tween
	var play = song.isPlaying(track)
	if(play): # should transition in
		var transition_time = computeTransitionTime(transition,song.BPM,song.BEATS_PER_BAR)
		tween = initTransitionTween(true,transition,transition_bus_name,transition_time)
		$MainMixingDesk.startTrack(track)
	else: # should transition out
		var transition_time = computeTransitionTime(transition,song.BPM,song.BEATS_PER_BAR)
		tween = initTransitionTween(false,transition,transition_bus_name,transition_time)
	$Tweens.add_child(tween)
	var _val = tween.start()
	yield(tween,"tween_all_completed") # waits for the fade in/out to finish
	tween.queue_free()
	if(not play): # it was a transition in
		$MainMixingDesk.stopTrack(track)

# skips to the next song with specific transition type
func switchSong(song : DefaultSong, transition : TransitionTemplate) -> void :
	switch_song_lock = true
	var old_song = current_song.NAME
	yield(removeSongs(transition),"completed")
	addSong(song,transition)
	emit_signal("song_changed",old_song,song.NAME)
	switch_song_lock = false

# transitions out the song if needed, returns true if fade out tween is being used for this
func removeSongs(transition : TransitionTemplate) -> void:
	var transition_time = computeTransitionTime(transition,current_song.BPM, current_song.BEATS_PER_BAR)
	var tween : Tween
	for bus in bus_array:
		tween = initTransitionTween(false,transition,bus.busName,transition_time,tween)
	$Tweens.add_child(tween)
	var _val = tween.start()
	yield(tween,"tween_all_completed")
	tween.queue_free()
	$MainMixingDesk.freeCurrent()
	for bus in bus_array:
		AudioServer.remove_bus(AudioServer.get_bus_index(bus.busName))
	bus_array = []
	current_song.queue_free()
	current_song = null

# adds the songs in song, and plays it with transition_type
func addSong(song : DefaultSong, transition : TransitionTemplate) -> void:
	current_song = song
	var _err = current_song.connect("beat",self,"onBeat")
	_err = current_song.connect("bar",self,"onBar")
	var tracks = song.getTrackList()
	var tween : Tween
	var transition_time = computeTransitionTime(transition,song.BPM,song.BEATS_PER_BAR) 
	for track in tracks: # create a transition bus for each track (for further transitions) and sets the track to the bus
		bus_array.append({
			"trackName":track.name,
			"busName":song.name + ":" + track.name,
			"sendTo":track.bus
		})
		var bus_name = createTransitionBus(song.name + ":" + track.name, track.bus)
		song.setBusOnTrack(track.name,bus_name)
		tween = initTransitionTween(true,transition,bus_name,transition_time,tween)
	redirectTracksBusDefault()
	$Tweens.add_child(tween)
	var _val = tween.start()
	$MainMixingDesk.play(song) # duplicates and plays main track
	yield(tween,"tween_all_completed")
	tween.queue_free()

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
func initTransitionTween(fade_in : bool, transition : TransitionTemplate, bus_name : String, transition_time : Array, custom_tween : Tween = null) -> Tween:
	var tween : Tween
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
				var _val = tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name),effects.amplifier),
					"volume_db",
					-50.0,
					0,
					transition_time[0])
			TransitionTemplate.fade_type.filter:
				var _val = tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effects.filter),
					"cutoff_hz",
					0,
					10000,
					transition_time[0])
	else: # fade out
		# sets the fade
		match(transition.FADE_TYPE):
			TransitionTemplate.fade_type.instant:
				pass
			TransitionTemplate.fade_type.volume:
				var _val = tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name),effects.amplifier),
					"volume_db",
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effects.amplifier).volume_db,
					-50.0,
					transition_time[1])
			TransitionTemplate.fade_type.filter:
				var _val = tween.interpolate_property(
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effects.filter),
					"cutoff_hz",
					AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effects.filter).cutoff_hz,
					0,
					transition_time[1])
	return tween

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

##### PROCESSING #####

# Called when the node enters the scene tree for the first time.
func _ready():
	is_playing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handleQueue()

##### DEBUG #####
# on beat
func onBeat(number : int):
	print("beat : %d" % number)

# on bar
func onBar(number : int):
	print("bar : %d" % number)

# shows every bus and tracks buses
func showBuses():
	print("========================")
	print("----------- buses -----------")
	for i in range(AudioServer.get_bus_count()):
		print("Bus %s sends to %s" % [AudioServer.get_bus_name(i),AudioServer.get_bus_send(i)])
	print("----------- tracks -----------")
	var current_streams = current_song.getTrackList()
	for track in current_streams:
		print("Track %s sends to %s" % [track.name,track.bus])
	print("========================")

# function at each tween step
func tweenStep(object: Object, key: NodePath, elapsed: float, value: Object):
	print("Object %s at path %s has value %s. Time elapsed : %f" % [object,key,value,elapsed])
