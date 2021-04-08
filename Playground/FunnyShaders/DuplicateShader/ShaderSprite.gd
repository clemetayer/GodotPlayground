extends Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	var mat = self.get_material()
	mat.set_shader_param("rand_val",randf()*4) # FIXME : global shader ?

