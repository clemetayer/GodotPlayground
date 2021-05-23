extends Node2D

func _on_MainMenu_pressed():
	var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
	var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
	var loop0song = song1load.instance()
	loop0song.setPlay("Piano",true)
	loop0song.setPlay("UltraSoft",true)
	loop0song.setPlay("OtherParts",true)
	$CenterContainer/VBoxContainer/HBoxContainer/Track1.pressed = true
	$CenterContainer/VBoxContainer/HBoxContainer/Track2.pressed = true
	$CenterContainer/VBoxContainer/HBoxContainer/Track3.pressed = true
	$SoundManager.addSongToQueue(loop0song,transition1load.instance())


func _on_Track1_toggled(button_pressed):
	var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
	var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
	var loop1song = song1load.instance()
	loop1song.setPlay("Piano",button_pressed)
	loop1song.setPlay("UltraSoft",$CenterContainer/VBoxContainer/HBoxContainer/Track2.pressed)
	loop1song.setPlay("OtherParts",$CenterContainer/VBoxContainer/HBoxContainer/Track3.pressed)
	$SoundManager.addSongToQueue(loop1song,transition1load.instance())


func _on_Track2_toggled(button_pressed):
	var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
	var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
	var loop2song = song1load.instance()
	loop2song.setPlay("Piano",$CenterContainer/VBoxContainer/HBoxContainer/Track1.pressed)
	loop2song.setPlay("UltraSoft", button_pressed)
	loop2song.setPlay("OtherParts",$CenterContainer/VBoxContainer/HBoxContainer/Track3.pressed)
	$SoundManager.addSongToQueue(loop2song,transition1load.instance())


func _on_Track3_toggled(button_pressed):
	var song1load = load("res://SoundStuff/EnhancedSoundManager/songs/scenes/Song1.tscn")
	var transition1load = load("res://SoundStuff/EnhancedSoundManager/Transitions/Transition1.tscn")
	var loop3song = song1load.instance()
	loop3song.setPlay("Piano",$CenterContainer/VBoxContainer/HBoxContainer/Track1.pressed)
	loop3song.setPlay("UltraSoft",$CenterContainer/VBoxContainer/HBoxContainer/Track2.pressed)
	loop3song.setPlay("OtherParts",button_pressed)
	$SoundManager.addSongToQueue(loop3song,transition1load.instance())
