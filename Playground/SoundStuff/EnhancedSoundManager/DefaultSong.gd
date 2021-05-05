extends Node
class_name DefaultSong

enum transition_mode {beat_index,bar_index,next_beat,next_bar}
enum fade_type {instant,volume,filter}

signal skip_to_part(index)

export(int) var BPM
export(int) var TOTAL_BARS
export(int) var BEATS_PER_BAR # or time signature (4,3,2 are the most common)
export(transition_mode) var TRANSITION_MODE # transition on specific or next beat/bar
export(int) var TRANSITION_TIME # will transition at a specific beat/bar number
export(fade_type) var FADE_TYPE # how one song will transition to another (same for both songs)
export(int) var FADE_TIME # in beat/bar, when it should start before arriving at TRANSITION_TIME
export(Array,Array,int) var LOOP_TIMES # in bars, positions where loops are possible. If empty, it will loop from beginning to end
export(int) var LOOP_INDEX # index of the loop to play in the array index
export(NodePath) var MAIN_SONG # path to the main song to play

# emits signal to skip to specific loop part
func skipToPart(loop_index:int) -> void:
	emit_signal("skip_to_part",loop_index)

# *optionnal* : executes at loop end, returns the next loop index. By default, -1 => keep the loop
func endLoop(_loop_index:int) -> int:
	return -1
