tool
extends Node
class_name SceneTemplate

export(Array,Dictionary) var TEXT_NODES setget set_text_keys

func set_text_keys(text_nodes):
	for i in text_nodes.size():
		if(text_nodes[i].size() == 0):
			text_nodes[i] = {
				"path":NodePath(),
				"key":""
			}
	TEXT_NODES = text_nodes

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
