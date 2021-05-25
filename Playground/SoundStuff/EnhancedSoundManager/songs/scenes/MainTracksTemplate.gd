tool
extends Node
class_name MainTracksTemplate

# NOTE : if some tracks are looping, it should be a good idea to set the looping on

# TODO : find a better way to tell time on a song (replace isLeadTrack)

var playing = false

export(Array,Dictionary) var TRACKS setget set_tracks # info for each loop

func set_tracks(track):
	for i in track.size():
		if track[i].size() == 0:
			# default value for new items in the dialogs array
			track[i] = {
				"name": String(), # name of the track
				"play":false, # if the track should be playing or not
				"isLeadTrack":false # idk, find something better here
			}
	TRACKS = track

# starts streams specified in LOOPS
func start() -> void:
	for track in TRACKS:
		if track.play:
			startTrack(track.name)

# starts the specified track
func startTrack(track_name : String) -> void:
	var time = 0.0
	for track in TRACKS:
		if track.play and track.isLeadTrack:
			time = get_node(track.name).get_playback_position()
	get_node(track_name).play(time)
	setPlay(track_name,true)

# sets the bus on track
func setBusOnTrack(track_name : String, bus_name : String) -> void:
	get_node(track_name).bus = bus_name

# sets all the tracks on a special bus
func setBusAll(bus_name : String) -> void:
	for track in TRACKS:
		setBusOnTrack(track.name,bus_name)

# stops all the tracks
func stopAll() -> void:
	for track in TRACKS:
		stopTrack(track.name)

# stops the specified track
func stopTrack(track_name : String) -> void:
	setPlay(track_name,false)
	get_node(track_name).stop()

# sets the play value in a track
func setPlay(track_name : String, value : bool) -> void:
	for track in TRACKS:
		if(track.name == track_name):
			track.play = value

# returns the bus of the specified track as a string (or null if does not exist)
func getBus(track_name : String):
	for track in TRACKS:
		if(track.name == track_name):
			return track.busName
	return null

# true if the specified track is playing
func isPlaying(track_name : String) -> bool:
	for track in TRACKS:
		if(track.name == track_name):
			return track.play
	return false
