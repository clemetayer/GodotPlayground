extends Node

# NOTE : intentionally fairly simple, management should be done by sound manager

# TODO : add an option to play from last stop point

## set from sound manager ##
var current_song : NodePath

## informations for self and other nodes##
var beat : int
var playing : bool
#signal beat()

## for main mixing desk ##
var last_beat : int
var loop : Array

##### USER FUNCTIONS #####
# returns the current Audio stream playing
func getCurrent():
	return get_node_or_null(current_song)

# frees the current audio stream
func freeCurrent() -> void:
	var song = get_node_or_null(current_song)
	if(song != null):
		stopCurrent()
		song.queue_free()

# stops the current audio stream
func stopCurrent() -> void:
	var song = get_node_or_null(current_song)
	if(song != null):
		song.stop()
		playing = false

# (re?)plays the current audio stream
func playCurrent() -> void:
	var song = get_node_or_null(current_song)
	if(song != null):
		song.play()
		playing = true

# starts the specified track on the specified bus
func startTrackOnBus(track:String,bus:String) -> void:
	var song = get_node_or_null(current_song)
	if(song != null):
		song.startTrackOnBus(track,bus)

# sets the specified track on the specified bus
func setBusOnTrack(track:String,bus:String) -> void:
	var song = get_node_or_null(current_song)
	if(song != null):
		song.setBusOnTrack(track,bus)

# stops the specified track
func stopTrack(track:String) -> void:
	var song = get_node_or_null(current_song)
	if(song != null):
		song.stopTrack(track)

# starts the specified track
func startTrack(track:String) -> void:
	var song = get_node_or_null(current_song)
	if(song != null):
		song.startTrack(track)

# plays an audio stream at specified loop
func play(p_song : DefaultSong) -> void:
	var song = get_node_or_null(current_song)
	if(song != null): # already something playing
		freeCurrent()
	add_child(p_song)
	current_song = get_node(p_song.name).get_path()
	get_node(current_song).play()
	playing = true

# compares play values of two songs
func compareSongsPlayValues(song1 : DefaultSong, song2 : DefaultSong) -> Array:
	return song1.compareSongsPlayValues(song2)
