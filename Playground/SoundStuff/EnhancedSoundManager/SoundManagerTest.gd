extends Node2D

export(String,FILE) var MAIN_MENU_SONG = "res://SoundStuff/EnhancedSoundManager/Song1.tscn"

var main_menu_load

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu_load = load(MAIN_MENU_SONG)

func _on_MainMenu_pressed():
	$SoundManager.addSongToQueue(main_menu_load.instance())


func _on_Loop1_pressed():
	$SoundManager.setNextLoop(0)


func _on_Loop2_pressed():
	$SoundManager.setNextLoop(1)


func _on_Loop3_pressed():
	$SoundManager.setNextLoop(2)
