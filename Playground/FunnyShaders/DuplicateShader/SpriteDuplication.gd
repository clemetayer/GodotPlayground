extends Node2D

export(NodePath) var VIEWPORT_PATH
export(float) var CLONE_TIME = 0.5
export(float) var DECAY_TIME = 2

var customSprite
var spriteArray = []
var decayDone = false

# Called when the node enters the scene tree for the first time.
func _ready():
	customSprite = load("res://FunnyShaders/DuplicateShader/ShaderSprite.tscn")
	get_parent().get_node("AnimationPlayer").play("what")
	$CloneTimer.set_wait_time(CLONE_TIME)
	$CloneTimer.start()
	$DecayTimer.set_wait_time(DECAY_TIME)
	$DecayTimer.start()

# duplicates the sprite
func addSprite():
	var sprite = customSprite.instance()
	var img = get_node(VIEWPORT_PATH).get_texture().get_data()
	img.flip_y()
	var itex = ImageTexture.new()
	itex.create_from_image(img)
	sprite.texture = itex
	add_child(sprite)
	return sprite

func _on_CloneTimer_timeout():
	var sprite = addSprite()
	spriteArray.push_front(sprite)
	if(decayDone):
		spriteArray.pop_back().queue_free()

func _on_DecayTimer_timeout():
	decayDone = true
	$DecayTimer.stop()
