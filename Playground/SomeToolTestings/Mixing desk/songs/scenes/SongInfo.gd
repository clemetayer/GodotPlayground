tool
extends Node

export(Array) var SONG_INFO setget set_SONG_INFO
export(String) var NAME

func set_SONG_INFO(song_info):
	for i in range(song_info.size()):
		if(song_info[i] == null):
			song_info[i] = {
				"name":"",
				"play":false,
				"startBar":0
			}
	SONG_INFO = song_info

# returns a list of all the audioStreams for the song
func getStreamsList() -> Array:
	return $MDM/IntroSong/CoreContainer.get_children()

# sets the play value on SONG_INFO for a specific track (can only set play on a playing song)
func setPlayOnTrack(track_name : String, value : bool) -> void:
	for track in SONG_INFO:
		if(track.name == track_name):
			track.play = value

# sets the bus on a specific track (MDM needs to be specified, to set the correct
func setBusOnTrack(track_name : String, bus : String):
	for track in $MDM/IntroSong/CoreContainer.get_children():
		if(track.name == track_name):
			track.bus = bus

# returns a specific audio stream if it exists, returns false otherwise
func getAudioStream(name : String):
	return $MDM/IntroSong/CoreContainer.get_node_or_null(name)

# returns the mdm
func getMDM():
	return get_node("MDM")

# returns the song
func getSong():
	return get_node("MDM/IntroSong")

func getUpdateTracks(song) -> Array:
	var update_array = []
	for i in range(SONG_INFO.size()):
		if(SONG_INFO[i].play != song.SONG_INFO[i].play):
			update_array.append({
				"name":SONG_INFO[i].name,
				"play":song.SONG_INFO[i].play
			})
	return update_array

# sets the song behaviour on a specific bar/beat
# should be called in sound manager
# TODO : do something here
func songBeatProcess(_beat_num : int, _bar_num : int, _song):
	pass

# calls the init function from MDM on a specific song
# TODO : implement multiple songs if needed
#func initSong(song):
#	for song in $MDM.get_children():
#		$MDM.init_song(song)

# sets the play value on a song
# TODO : implement multiple songs if needed
#func setPlayOnSong(song_name : String, value : bool) -> void:
#	for song in SONG_INFO:
#		if(song.name == song_name):
#			song.play = value
