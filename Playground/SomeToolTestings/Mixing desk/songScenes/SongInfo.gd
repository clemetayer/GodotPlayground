tool
extends Node

enum fadeTypes {volume,filter}
enum fadeTimeTypes {instant,transitionBeat}

export(Resource) var songInfo setget set_songInfo

func set_songInfo(info):
	if not info : # sets default song informations
		info = {
			"songName" : "",
			"songPath" : NodePath(),
			"fade" : {
				"fadeIn" : {
					"enabled" : false,
					"type":fadeTypes,
					"time":fadeTimeTypes
				},
				"fadeOut": {
					"enabled" : false,
					"type":fadeTypes,
					"time":fadeTimeTypes
				}
			},
			
		}
	songInfo = info

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
