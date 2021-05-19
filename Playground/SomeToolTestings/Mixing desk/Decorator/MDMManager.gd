extends Node

# TODO : handle loop transitions
# TODO : handle other songs in queue (with transition)
# TODO : handle volume transitions
# maybe use own sound manager instead of MDM ?

export(NodePath) var MDM_PATH
export(String) var BUS # bus where the BGM should play
export(int) var FILTER_EFFECT_INDEX # filter in bus

var queue = []
var current_song
var high_filter_val = 20000
var switch_song_lock = false # lock to prevent tweens to restart at each frame

onready var MDM = get_node(MDM_PATH)

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
		if(current_song != null): # a song is currently playing; NOTE : not using "is_instance_valid" because it is a dictionnary (the elements in it are freed and it should be set as null in this case)
			if(current_song.song.NAME == queue[0].song.NAME): # same song, maybe new loop to play
				pass
			elif(not switch_song_lock): # play next song
				switchSong(queue[0].song,queue[0].transition)
		else:
			addSong(queue[0].song,queue[0].transition)

# adds the songs to MDM
func addSongsToMDM(song) -> void:
	var loop_index = 0
	for child in song.get_children():
		var dup = child.duplicate()
		dup.name = song.NAME + "_" +str(loop_index)
		MDM.add_child(dup)
		loop_index += 1
	MDM.refresh_songs()
	for index in range(song.LOOP_PARTS.size()):
		MDM.init_song(song.NAME + "_" + str(index))
	

# sets next loop to the one specified in the index
func nextLoop(_index:int) -> void:
	pass

# skips to the next song with specific transition type
func switchSong(song, transition) -> void :
	switch_song_lock = true
	yield(removeSongs(transition),"completed")
	addSong(song,transition)
	switch_song_lock = false

# transitions out the song if needed, returns true if fade out tween is being used for this
func removeSongs(transition) -> void:
	var transition_time
	var song_to_remove = MDM.get_current_song()
	# computes the fade time
	match(transition.FADE_TIMING):
		TransitionTemplate.fade_timing.time:
			transition_time = transition.FADE_OUT_TIME
		TransitionTemplate.fade_timing.beat:
			transition_time = transition.FADE_OUT_TIME * (60.0 / song_to_remove.tempo)
		TransitionTemplate.fade_timing.bar:
			transition_time = queue[0].transition.FADE_OUT_TIME * (60.0 / song_to_remove.tempo) * song_to_remove.beats_in_bar 
	# sets the fade
	match(queue[0].transition.FADE_TYPE):
		TransitionTemplate.fade_type.instant:
			pass
		TransitionTemplate.fade_type.volume:
			pass
		TransitionTemplate.fade_type.filter:
			$Tweens/FadeOut.interpolate_property(
				AudioServer.get_bus_effect(AudioServer.get_bus_index(BUS), FILTER_EFFECT_INDEX),
				"cutoff_hz",
				AudioServer.get_bus_effect(AudioServer.get_bus_index(BUS), FILTER_EFFECT_INDEX).cutoff_hz,
				0,
				transition_time)
			$Tweens/FadeOut.start()
			yield($Tweens/FadeOut,"tween_all_completed")
	for loop_index in range(current_song.song.LOOP_PARTS.size()):
		MDM.stop_now(current_song.song.NAME + "_" + str(loop_index))
		MDM.get_node(current_song.song.NAME + "_" + str(loop_index)).queue_free()
	current_song.song.queue_free()
	current_song.transition.queue_free()
	current_song = null

# adds the songs in song, and plays it with transition_type
func addSong(song,transition) -> void:
	song.initDefault()
	addSongsToMDM(song)
	var songName = song.NAME
	var song_to_play = song.get_node(song.LOOP_PARTS[song.LOOP_INDEX])
	var transition_time
	# computes the fade time
	match(transition.FADE_TIMING):
		TransitionTemplate.fade_timing.time:
			transition_time = transition.FADE_IN_TIME
		TransitionTemplate.fade_timing.beat:
			transition_time = transition.FADE_IN_TIME * (60.0 / song_to_play.tempo)
		TransitionTemplate.fade_timing.bar:
			transition_time = transition.FADE_IN_TIME * (60.0 / song_to_play.tempo) * song_to_play.beats_in_bar 
	# sets the fade
	match(transition.FADE_TYPE):
		TransitionTemplate.fade_type.instant:
			pass
		TransitionTemplate.fade_type.volume:
			pass
		TransitionTemplate.fade_type.filter:
			$Tweens/FadeIn.interpolate_property(
				AudioServer.get_bus_effect(AudioServer.get_bus_index(BUS), FILTER_EFFECT_INDEX),
				"cutoff_hz",
				AudioServer.get_bus_effect(AudioServer.get_bus_index(BUS), FILTER_EFFECT_INDEX).cutoff_hz,
				high_filter_val,
				transition_time)
			$Tweens/FadeIn.start()
	MDM.play_mode = song.PLAY_STYLE
	MDM.play(songName + "_" + str(song.LOOP_INDEX))
	current_song = queue.pop_front()

######## ROUTINES ########
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handleQueue()

func _on_MixingDeskMusic_bar_changed(bar):
	print("bar : %d" % bar)

func _on_MixingDeskMusic_beat(beat):
	print("beat : %d" % beat)

func _on_MixingDeskMusic_core_loop_finished(song_name):
	print("song %s finished" % song_name)

func _on_MixingDeskMusic_shuffle(array_switch_songs):
	print("shuffled from %s to %s" % array_switch_songs)

func _on_MixingDeskMusic_song_changed(array_switch_songs):
	print("song changed from %s to %s" % array_switch_songs)

func _on_FadeIn_tween_all_completed():
	print("fade in done")
