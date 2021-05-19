extends Node
class_name DefaultSong

enum play_style {play_once,loop}

export(int) var BPM
export(int) var BAR_NUMBER # number of bars in song
export(int) var BEATS_PER_BAR # or time signature (4,3,2 are the most common)
export(NodePath) var MAIN_LOOPS # path to the main song to play
export(play_style) var PLAY_STYLE # play style
export(String) var NAME # name of the song

# plays the song with parameters in MAIN_LOOPS
func play() -> void:
	get_node(MAIN_LOOPS).start()

# stops the song (entirely)
func stop() -> void:
	get_node(MAIN_LOOPS).stopAll()

# sets the "play" value on track
func setPlay(track : String, value : bool) -> void:
	get_node(MAIN_LOOPS).setPlay(track,value)

# starts the specified track on the specified bus
func startTrackOnBus(track:String,bus:String) -> void:
	get_node(MAIN_LOOPS).startTrackOnBus(track,bus)

# sets the specified track on the specified bus
func setBusOnTrack(track:String,bus:String) -> void:
	get_node(MAIN_LOOPS).setBusOnTrack(track,bus)

# stops the specified track
func stopTrack(track:String) -> void:
	get_node(MAIN_LOOPS).stopTrack(track)

# starts the specified track
func startTrack(track:String) -> void:
	get_node(MAIN_LOOPS).startTrack(track)

# compares the play values of self, compared to a similar Default Song. Returns an array of tracks that have different play values (as strings)
func compareSongsPlayValues(song : DefaultSong) -> Array:
	var diff_array = []
	for index in range(get_node(MAIN_LOOPS).LOOPS.size()):
		if(get_node(MAIN_LOOPS).LOOPS[index].play != song.get_node(song.MAIN_LOOPS).LOOPS[index].play):
			diff_array.append(get_node(MAIN_LOOPS).LOOPS[index].track)
	return diff_array

# returns the final bus of a specific track
func getBus(track:String):
	return get_node(MAIN_LOOPS).getBus(track)

# true if the specified track is playing
func isPlaying(track:String) -> bool:
	return get_node(MAIN_LOOPS).isPlaying(track)
