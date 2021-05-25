extends Node2D

var locks = [false,false,false] # locks to not activate if an automatic transition took place

func _ready():
	var _err = SignalManager.connect("track_played",self,"onTrackPlayed")
	_err = SignalManager.connect("track_stopped",self,"onTrackStopped")

func _on_Song_1_pressed():
	var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
	var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
	var loop0song = song1load.instance()
	loop0song.setPlay("Piano",true)
	loop0song.setPlay("UltraSoft",true)
	loop0song.setPlay("OtherParts",true)
	$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/Piano.pressed = true
	$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/UltraSoft.pressed = true
	$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/OtherParts.pressed = true
	$SoundManager.addSongToQueue(loop0song,transition1load.instance())

func _on_Song2_pressed():
	var song2load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song2.tscn")
	var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
	var loop0song = song2load.instance()
	loop0song.setPlay("MainMenu",true)
	$SoundManager.addSongToQueue(loop0song,transition1load.instance())

func _on_Piano_toggled(button_pressed):
	if(not locks[0]):
		var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
		var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
		var loop1song = song1load.instance()
		loop1song.setPlay("Piano",button_pressed)
		loop1song.setPlay("UltraSoft",$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/UltraSoft.pressed)
		loop1song.setPlay("OtherParts",$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/OtherParts.pressed)
		$SoundManager.addSongToQueue(loop1song,transition1load.instance())
	else:
		locks[0] = false


func _on_UltraSoft_toggled(button_pressed):
	if(not locks[1]):
		var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
		var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
		var loop2song = song1load.instance()
		loop2song.setPlay("Piano",$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/Piano.pressed)
		loop2song.setPlay("UltraSoft", button_pressed)
		loop2song.setPlay("OtherParts",$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/OtherParts.pressed)
		$SoundManager.addSongToQueue(loop2song,transition1load.instance())
	else:
		locks[1] = false


func _on_OtherParts_toggled(button_pressed):
	if(not locks[2]):
		var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
		var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
		var loop3song = song1load.instance()
		loop3song.setPlay("Piano",$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/Piano.pressed)
		loop3song.setPlay("UltraSoft",$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/UltraSoft.pressed)
		loop3song.setPlay("OtherParts",button_pressed)
		$SoundManager.addSongToQueue(loop3song,transition1load.instance())
	else:
		locks[2] = false

func onTrackPlayed(track):
	match(track):
		"Piano":
			locks[0] = true
			$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/Piano.pressed = true
		"UltraSoft":
			locks[1] = true
			$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/UltraSoft.pressed = true
		"OtherParts":
			locks[2] = true
			$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/OtherParts.pressed = true

func onTrackStopped(track):
	match(track):
		"Piano":
			locks[0] = true
			$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/Piano.pressed = false
		"UltraSoft":
			locks[1] = true
			$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/UltraSoft.pressed = false
		"OtherParts":
			locks[2] = true
			$CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/OtherParts.pressed = false 
