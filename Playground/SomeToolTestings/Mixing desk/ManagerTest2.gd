extends Node2D


var song_1_load = preload("res://SomeToolTestings/Mixing desk/Decorator/Song1.tscn") 
var transition_1_load = preload("res://SomeToolTestings/Mixing desk/Decorator/FadeTransition.tscn")
var song_2_load = preload("res://SomeToolTestings/Mixing desk/Decorator/Song2.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Song1Button_pressed():
	$MDMManager.addToQueue(song_1_load.instance(),transition_1_load.instance())

func _on_Loop1_pressed():
	pass # Replace with function body.

func _on_Loop2_pressed():
	pass # Replace with function body.

func _on_Loop3_pressed():
	pass # Replace with function body.

func _on_Song2Button_pressed():
	$MDMManager.addToQueue(song_2_load.instance(),transition_1_load.instance())
