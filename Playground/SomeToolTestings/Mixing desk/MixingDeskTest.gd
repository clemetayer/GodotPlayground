extends Node2D

onready var MDM = get_node("Music/MixingDeskMusic")
var currentSong

# Called when the node enters the scene tree for the first time.
func _ready():
	MDM.init_song("MainMenu")
	MDM.play("MainMenu")
	currentSong = "MainMenu"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Song1Button_pressed():
	MDM.queue_bar_transition("Song1P1")
	currentSong = "Song1P1"

func _on_LoopPart1_pressed():
	MDM.queue_bar_transition("Song1P1")
	currentSong = "Song1P1"


func _on_LoopPart2_pressed():
	MDM.queue_bar_transition("Song1P2")
	currentSong = "Song1P2"


func _on_LoopPart3_pressed():
	MDM.queue_bar_transition("Song1P3")
	currentSong = "Song1P3"


func _on_Song2Button_pressed():
	MDM.queue_bar_transition("MainMenu")
	currentSong = "MainMenu"


func _on_InstantFade12_pressed():
	pass # Replace with function body.


func _on_InstantFade21_pressed():
	pass # Replace with function body.

## instantly fades to the next song
#func instantFadeSwitch(songName):
#	var transitionBeats = MDM.get_node(currentSong).transition_beats
#	MDM.fadeout_above_layer(currentSong,0)
#	for i in range(transitionBeats):


func _on_MixingDeskMusic_bar_changed(bar):
	print("bar : %d" % bar)


func _on_MixingDeskMusic_beat(beat):
	print("beat : %d" % beat)


func _on_MixingDeskMusic_core_loop_finished(song_name):
	print("core loop finished : %s" % song_name)


func _on_MixingDeskMusic_shuffle(array_switch_songs):
	print("shuffle from %s to %s" % [array_switch_songs[0], array_switch_songs[1]])


func _on_MixingDeskMusic_song_changed(array_switch_songs):
	print("song changed from %s to %s" % [array_switch_songs[0], array_switch_songs[1]])
