extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Idle")

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.play(anim_name)
