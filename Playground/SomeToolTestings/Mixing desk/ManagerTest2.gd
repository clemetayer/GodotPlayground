extends Node2D

var transition = preload("res://SomeToolTestings/Mixing desk/Decorator/FadeTransition.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Song1Button_pressed():
	var song = load("res://SomeToolTestings/Mixing desk/songs/scenes/Song1.tscn").instance()
	if($UI/HBoxContainer/Song1/Tracks/Piano.pressed 
		and $UI/HBoxContainer/Song1/Tracks/UltraSoft.pressed
		and $UI/HBoxContainer/Song1/Tracks/OtherParts.pressed): # toggle everything off
		$UI/HBoxContainer/Song1/Tracks/Piano.pressed = false
		$UI/HBoxContainer/Song1/Tracks/UltraSoft.pressed = false
		$UI/HBoxContainer/Song1/Tracks/OtherParts.pressed = false
		song.setPlayOnTrack("Piano",false)
		song.setPlayOnTrack("UltraSoft",false)
		song.setPlayOnTrack("OtherParts",false)
	else: # toggle everything on
		$UI/HBoxContainer/Song1/Tracks/Piano.pressed = true
		$UI/HBoxContainer/Song1/Tracks/UltraSoft.pressed = true
		$UI/HBoxContainer/Song1/Tracks/OtherParts.pressed = true
		song.setPlayOnTrack("Piano",true)
		song.setPlayOnTrack("UltraSoft",true)
		song.setPlayOnTrack("OtherParts",true)
	$MDMManager.addToQueue(song,transition.instance())

func _on_Song2Button_pressed():
	pass

func _on_Piano_toggled(_button_pressed):
	var song = load("res://SomeToolTestings/Mixing desk/songs/scenes/Song1.tscn").instance()
	song.setPlayOnTrack("Piano", $UI/HBoxContainer/Song1/Tracks/Piano.pressed)
	song.setPlayOnTrack("UltraSoft", $UI/HBoxContainer/Song1/Tracks/UltraSoft.pressed)
	song.setPlayOnTrack("OtherParts", $UI/HBoxContainer/Song1/Tracks/OtherParts.pressed)
	$MDMManager.addToQueue(song,transition.instance())

func _on_UltraSoft_toggled(_button_pressed):
	var song = load("res://SomeToolTestings/Mixing desk/songs/scenes/Song1.tscn").instance()
	song.setPlayOnTrack("Piano", $UI/HBoxContainer/Song1/Tracks/Piano.pressed)
	song.setPlayOnTrack("UltraSoft", $UI/HBoxContainer/Song1/Tracks/UltraSoft.pressed)
	song.setPlayOnTrack("OtherParts", $UI/HBoxContainer/Song1/Tracks/OtherParts.pressed)
	$MDMManager.addToQueue(song,transition.instance())

func _on_OtherParts_toggled(_button_pressed):
	var song = load("res://SomeToolTestings/Mixing desk/songs/scenes/Song1.tscn").instance()
	song.setPlayOnTrack("Piano", $UI/HBoxContainer/Song1/Tracks/Piano.pressed)
	song.setPlayOnTrack("UltraSoft", $UI/HBoxContainer/Song1/Tracks/UltraSoft.pressed)
	song.setPlayOnTrack("OtherParts", $UI/HBoxContainer/Song1/Tracks/OtherParts.pressed)
	$MDMManager.addToQueue(song,transition.instance())
