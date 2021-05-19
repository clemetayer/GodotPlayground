tool
extends Node
class_name MainLoopsTemplate

export(Array,Dictionary) var LOOPS setget set_loops # info for each loop

func set_loops(loop):
	for i in loop.size():
		if loop[i].size() == 0:
			# default value for new items in the dialogs array
			loop[i] = {
				"track": String(), # name of the track
				"play":false, # if the track should be playing or not
				"startBar":0, # bar on which it starts in the song (to know when song should be done on loop_once)
				"busName":"Master", # track bus name
				"isLeadTrack":false # true if should be used to define where to start the song
			}
	LOOPS = loop

# starts streams specified in LOOPS
func start() -> void:
	for loop in LOOPS:
		if loop.play:
			startTrack(loop.track)

# starts the specified track
func startTrack(track_name : String) -> void:
	var time = 0.0
	for loop in LOOPS:
		if loop.play and loop.isLeadTrack:
			time = get_node(loop.track).get_playback_position()
	get_node(track_name).play(time)
	setPlay(track_name,true)

# starts the track on a specific bus
func startTrackOnBus(track_name : String, bus_name : String) -> void:
	get_node(track_name).bus = bus_name
	startTrack(track_name)

# sets the bus on track
func setBusOnTrack(track_name : String, bus_name : String) -> void:
	get_node(track_name).bus = bus_name

# sets all the tracks on a special bus
func setBusAll(bus_name : String) -> void:
	for loop in LOOPS:
		setBusOnTrack(loop.track,bus_name)

# stops all the tracks
func stopAll() -> void:
	for loop in LOOPS:
		stopTrack(loop.track)

# stops the specified track
func stopTrack(track_name : String) -> void:
	setPlay(track_name,false)
	get_node(track_name).stop()

# sets the play value in a track
func setPlay(track : String, value : bool) -> void:
	for loop in LOOPS:
		if(loop.track == track):
			loop.play = value

# returns the bus of the specified track as a string (or null if does not exist)
func getBus(track : String):
	for loop in LOOPS:
		if(loop.track == track):
			return loop.busName
	return null

# true if the specified track is playing
func isPlaying(track:String) -> bool:
	for loop in LOOPS:
		if(loop.track == track):
			return loop.play
	return false
