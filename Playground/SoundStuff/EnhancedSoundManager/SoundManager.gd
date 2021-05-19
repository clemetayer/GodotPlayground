extends Node
# inspired from Godot mixing desk : https://github.com/kyzfrintin/Godot-Mixing-Desk

# TODO : implement signal song done
# TODO : implement songs that can be on various final buses
# ARCHITECTURE : Using direct references to main loop in songs, which is not fine

enum play_style {play_once,loop}

export(String) var BGM_BUS = "Master"

#signal beat(beat)
#signal bar(bar)
#signal song_changed(old_song,new_song)

var queue = []
var is_playing : bool
var switch_song_lock = false
var current_song : DefaultSong
var current_play_style
var amplifier_effect_index = 0
var filter_effect_index = 1

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
		var bus_dup_index = 0 # in case many tracks transitionning
		while(AudioServer.get_bus_index("T:"+ song.NAME + "-" + str(bus_dup_index)) != -1):
			bus_dup_index += 1
		var transition_bus_name = createTransitionBus("T:"+ song.NAME + "-" + str(bus_dup_index), song.getBus(track))
		updateTrack(song,track,transition,transition_bus_name)
		current_song.setPlay(track,song.isPlaying(track))

# creates a temporary bus to handle transitionning tracks
func createTransitionBus(name : String, send_to : String) -> String:
	var bus_index = AudioServer.bus_count # Note : bus indexes starts at 0
	AudioServer.add_bus(bus_index)
	AudioServer.add_bus_effect(bus_index,AudioEffectAmplify.new(),amplifier_effect_index)
	AudioServer.add_bus_effect(bus_index,AudioEffectFilter.new(),filter_effect_index)
	AudioServer.set_bus_name(bus_index,name)
	AudioServer.set_bus_send(bus_index,send_to)
	return name

# updates the track at track_index
func updateTrack(song : DefaultSong, track : String, transition : TransitionTemplate, transition_bus_name : String):
	var tween : Tween
	var final_bus_name = song.getBus(track)
	var play = song.isPlaying(track)
	if(play): # should transition in
		var transition_time = computeTransitionTime(transition,song.BPM,song.BEATS_PER_BAR)
		tween = initTransitionTween(true,transition,transition_bus_name,transition_time)
		$MainMixingDesk.startTrackOnBus(track,transition_bus_name)
#		main_loops.startTrackOnBus(main_loops.LOOPS[track_index].track,transition_bus_name)
	else: # should transition out
		var transition_time = computeTransitionTime(transition,song.BPM,song.BEATS_PER_BAR)
		tween = initTransitionTween(false,transition,transition_bus_name,transition_time)
		$MainMixingDesk.setBusOnTrack(track,transition_bus_name)
#		main_loops.setBusOnTrack(main_loops.LOOPS[track_index].track,transition_bus_name)
	$Tweens.add_child(tween)
	var _val = tween.start()
	yield(tween,"tween_all_completed") # waits for the fade in/out to finish
	tween.queue_free()
	if(play): # it was a transition in
		$MainMixingDesk.setBusOnTrack(track,final_bus_name) # sets to its final bus
#		main_loops.setBusOnTrack(main_loops.LOOPS[track_index].track,final_bus_name) # sets to its final bus
	else: # it was a transition out
		$MainMixingDesk.stopTrack(track)
#		main_loops.stopTrack(main_loops.LOOPS[track_index].track)
	AudioServer.remove_bus(AudioServer.get_bus_index(transition_bus_name))

# skips to the next song with specific transition type
func switchSong(song : DefaultSong, transition : TransitionTemplate) -> void :
	switch_song_lock = true
	yield(removeSongs(transition),"completed")
	addSong(song,transition)
	switch_song_lock = false

# transitions out the song if needed, returns true if fade out tween is being used for this
func removeSongs(transition : TransitionTemplate) -> void:
	var transition_bus_name = createTransitionBus("R:" + current_song.NAME, BGM_BUS)
	var transition_time = computeTransitionTime(transition,current_song.BPM, current_song.BEATS_PER_BAR)
	var tween = initTransitionTween(false,transition,transition_bus_name,transition_time)
	$Tweens.add_child(tween)
	tween.start()
	yield(tween,"tween_all_completed")
	tween.queue_free()
	$MainMixingDesk.freeCurrent()
	current_song.queue_free()
	current_song = null

# adds the songs in song, and plays it with transition_type
func addSong(song : DefaultSong, transition : TransitionTemplate) -> void:
	$MainMixingDesk.play(song) # duplicates and plays main track
	current_song = song
	var transition_bus_name = createTransitionBus("A:" + song.NAME,BGM_BUS)
	var transition_time = computeTransitionTime(transition,song.BPM,song.BEATS_PER_BAR) 
	var tween = initTransitionTween(true,transition,transition_bus_name,transition_time)
	$Tweens.add_child(tween)
	tween.start()
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
func initTransitionTween(fade_in : bool, transition : TransitionTemplate, bus_name : String, transition_time : Array) -> Tween:
	var tween = Tween.new()
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

##### PROCESSING #####

# Called when the node enters the scene tree for the first time.
func _ready():
	is_playing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handleQueue()
