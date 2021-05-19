extends Node
class_name SongTemplate

enum play_style {play_once, loop_song, shuffle, endless_shuffle, loop_song_mix}

##### exports for MDM Manager #####
export(Array,NodePath) var LOOP_PARTS # Array of path to different loops
export(int) var LOOP_INDEX # LOOP_PARTS index to play at start
export(String) var NAME # name of the song
export(play_style) var PLAY_STYLE # play style for MixingDeskMusic node

##### exports for song setup #####
export(String) var DEFAULT_BUS = "Master" # default bus
export(int) var DEFAULT_TEMPO = 120 # default tempo
export(int) var DEFAULT_BEATS_IN_BAR = 4 # default beats in bar

# init song's default variables
func initDefault():
	for child in get_children():
		if(child.bus == "Music"): # should switch to default bus
			child.bus = DEFAULT_BUS
		if(child.tempo == 0): # should switch to default tempo
			child.tempo = DEFAULT_TEMPO
		if(child.beats_in_bar == 0): # should switch to default beats in bar
			child.beats_in_bar = DEFAULT_BEATS_IN_BAR

# *** optionnal *** : skips to a specific loop part after a loop is done. -1 if should stay in the same loop
func autoSkipToLoop(_loop_index:int)->int:
	return -1
