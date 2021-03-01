extends TileMap

export(String,FILE) var DESTRUCTIBLE_SPRITE_PATH = "res://FlexibleDestructibleSprite/blocks/DestructibleSprite.tscn"

var viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	var destructible_instance = load(DESTRUCTIBLE_SPRITE_PATH).instance()
	var TileMapRect = computeTileMapBounds()
	var TileMapStartPos = TileMapRect.position
	var TileMapSize = TileMapRect.size
	viewport = createViewport(TileMapStartPos,TileMapSize)
	get_parent().call_deferred("remove_child",self)
	viewport.call_deferred("add_child", self)
	position.x = TileMapSize.x/2
	yield(VisualServer, 'frame_post_draw') # waits one frame before getting the texture, otherwise, some unexpected behaviours happens
	var img = viewport.get_texture()
	img.get_data().flip_y()
#	img.get_data().save_png("res://FlexibleDestructibleSprite/test.png") # debug
	destructible_instance.position = TileMapStartPos
	destructible_instance.SPRITE = img
	get_parent().get_parent().get_parent().add_child(destructible_instance)
	destructible_instance.connect("destructible_sprite_loaded",get_tree().get_current_scene(),"destructibleLoaded")
	destructible_instance.parseSprite()
	get_parent().get_parent().visible = false
	
# function by CKO on godot forum : https://godotengine.org/qa/3276/tilemap-size
func computeTileMapBounds():
	var cell_bounds = get_used_rect()
	# create transform
	var cell_to_pixel = Transform2D(Vector2(cell_size.x * scale.x, 0), Vector2(0, cell_size.y * scale.y), Vector2())
	# apply transform
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)

func createViewport(position,size):
	var viewportC = ViewportContainer.new()
	viewportC.rect_size = size
	viewportC.rect_position = position
	viewport = Viewport.new()
	viewport.transparent_bg = true
	viewport.size = size
	viewport.render_target_v_flip = true
	viewportC.add_child(viewport)
	get_parent().call_deferred("add_child",viewportC)
	return viewport

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	if(Input.is_action_just_pressed("next_dialog")):
#		var img = viewport.get_texture().get_data()
#		img.flip_y()
#		img.save_png("res://FlexibleDestructibleSprite/test.png")
