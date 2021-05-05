extends Node
# inspired from Godot mixing desk : https://github.com/kyzfrintin/Godot-Mixing-Desk

signal beat(beat)
signal bar(bar)
signal song_changed(old_song,new_song)
signal song_done(song_name)

var queue = []
var is_playing : bool
var current_song
var current_song_info : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	is_playing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handleQueue()

# handles the song queue
func handleQueue() -> void:
	if(queue.size() > 0): # should switch to another song
		if(queue.size()>1): # clean queue (keep the last element only
			for i in range(0,queue.size()-1):
				queue[i].queue_free()
		if(not is_playing): # should play the song in queue immediately
			play(queue[0])

# sets the next loop for current song
func setNextLoop(index:int) -> void:
	current_song_info.nextLoop = index

# plays the next song immediately (frees the previous one if not already done) with the specified loop
func play(song) -> void:
	if($Overlay.get_children().size() > 0): # stops and frees each children in overlay
		for child in $Overlay.get_children():
			child.stop()
			child.queue_free()
	if(is_instance_valid(current_song)): # frees the current song
		current_song.queue_free()
	current_song = song
	is_playing = true
	initCurrentSongInfo(song)
	cloneAndPlay(song.get_node(song.MAIN_SONG))

func initCurrentSongInfo(song) -> void :
	var loop = song.LOOP_TIMES[song.LOOP_INDEX]
	current_song_info = {
		"beat":1, # current beat
		"bar":loop[0], # current bar
		"loopValues": { # current loop (in bars)
			"start":loop[0],
			"end":loop[1],
		},
		"nextLoop":null, # loop index eventually specified by the user
		"loopIndex":song.LOOP_INDEX, # loop index from the song array of loops
		"switchIndex":null, # beat or bar index where the song should be switched
		"isTransitionning":false # true if the song is in the process of transitionning to another (case of fade out), lock first queue element
	}

# clones the song_stream in the overlay node and plays it
func cloneAndPlay(track : AudioStreamPlayer) -> void:
	var trk = track.duplicate()
	$Overlay.add_child(trk)
	var start_time = current_song_info.bar * current_song.BEATS_PER_BAR * 60.0 / current_song.BPM
	trk.play(start_time)
	initBeatTimer()

# initialize the beat timer and sets the beat and bar value
func initBeatTimer():
	$BeatTimer.stop()
	# loads new song info
	$BeatTimer.set_wait_time(60.0/current_song.BPM)
	$BeatTimer.start()


# returns true if the song is playing
func isPlaying() -> bool:
	return is_playing

# verifies if the parameters of the song are correct
func verifySongMandatoryParameters(song) -> bool:
	var are_parameters_ok : bool = true
	if(song.get("BPM") == null or song.BPM == 0):
		are_parameters_ok = false
		printerr("Mandatory parameter missing : BPM")
	if(song.get("BEATS_PER_BAR") == null or song.BEATS_PER_BAR == 0):
		are_parameters_ok = false
		printerr("Mandatory parameter missing : BEATS_PER_BAR")
	if(song.get("MAIN_SONG") == null or song.MAIN_SONG == null):
		are_parameters_ok = false
		printerr("Mandatory parameter missing : MAIN_SONG")
	return are_parameters_ok

# adds the song to queue
func addSongToQueue(song) -> void:
	if(not verifySongMandatoryParameters(song)): # parameters invalid, not adding to queue
		return
	queue.append(song)

############## BEAT PROCESS ##############

# do the beat process
func _on_BeatTimer_timeout():
	beatProcess()

# function on each beat
func beatProcess():
	# updates beat number
	if(current_song_info.beat >= current_song.BEATS_PER_BAR): # bar done
		current_song_info.beat = 1
		barProcess()
	else:
		current_song_info.beat += 1
	# check song switch
	if(
		(current_song.TRANSITION_MODE == current_song.transition_mode.beat_index
			or current_song.TRANSITION_MODE == current_song.transition_mode.next_beat)
		and current_song_info.beat == current_song_info.switchIndex
	): # should switch songs
		switchSong()
	# emit signal
	print("Beat : %d" % current_song_info.beat)
	emit_signal("beat",current_song_info.beat)

# function at each bar
func barProcess():
	# updates beat number
	if(current_song_info.bar >= current_song_info.loopValues.end): # end of loop process
		current_song_info.bar = current_song_info.loopValues.start
	else:
		current_song_info.bar += 1
	# check if should switch song
	if(
		(current_song.TRANSITION_MODE == current_song.transition_mode.bar_index
		or current_song.TRANSITION_MODE == current_song.transition_mode.next_bar)
	and current_song_info.bar == current_song_info.switchIndex): # should switch songs
		switchSong()
	# check if end of loop
	elif(current_song_info.bar == current_song_info.loopValues.end):
		loopProcess()
	# emit signal
	print("Bar : %d" % current_song_info.bar)
	emit_signal("bar",current_song_info.bar)

# switches to the first song in queue
func switchSong():
	pass

# handles the looping process
func loopProcess():
	var nextLoop = current_song.endLoop(current_song_info.loopIndex) # check song info at end of loop
	if(current_song_info.nextLoop != null): # switches to the loop specified externally
		current_song_info.loopIndex = current_song_info.nextLoop 
		current_song.LOOP_INDEX = current_song_info.loopIndex
		current_song_info.loopValues.start = current_song.LOOP_TIMES[current_song_info.nextLoop][0]
		current_song_info.loopValues.end = current_song.LOOP_TIMES[current_song_info.nextLoop][1]
		current_song_info.nextLoop = null
	elif(nextLoop != -1): # automatic loop from song
		current_song_info.loopIndex = nextLoop
		current_song.LOOP_INDEX = current_song_info.loopIndex
		current_song_info.loopValues.start = current_song.LOOP_TIMES[nextLoop][0]
		current_song_info.loopValues.end = current_song.LOOP_TIMES[nextLoop][1]
	replaySong()

# replays the current song at the correct loop values
func replaySong():
	var stream = $Overlay.get_child(0)
	var start_time = current_song_info.bar * current_song.BEATS_PER_BAR * 60.0 / current_song.BPM
	stream.seek(start_time)
