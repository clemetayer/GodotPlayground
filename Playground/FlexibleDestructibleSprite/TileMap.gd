extends TileMap

export(String,FILE) var DESTRUCTIBLE_SPRITE_PATH = "res://FlexibleDestructibleSprite/blocks/DestructibleSprite.tscn"
export(String,FILE) var BLOCK_PATH = "res://FlexibleDestructibleSprite/blocks/BlockArea.tscn" 
export(int) var TILE_SIZE_POW = 8
export(int) var MIN_SIZE_POW = 2

var viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	var TileMapRect = computeTileMapBounds()
	var TileMapPosition = position
	viewport = createViewport(TileMapPosition,TileMapRect.size)
	addTilemapToViewport(TileMapRect)
	yield(VisualServer, 'frame_post_draw') # waits one frame before getting the texture, otherwise, some unexpected behaviours happens
	# Note : TileMapRect.position is the offset from the center position to the first pixel on the top left
	createDestructibleSprite(TileMapRect.position)
	get_parent().get_parent().get_parent().remove_child(get_parent().get_parent())
#	get_parent().get_parent().call_deferred("queue_free") # FIXME : The texture of the viewport is linked in memory to the one in the sprite, so freeing the viewport will free the texture

# creates the destructible sprite corresponding to the viewport of the tilemap
func createDestructibleSprite(pos):
	var destructible_instance = load(DESTRUCTIBLE_SPRITE_PATH).instance()
	var img = viewport.get_texture()
	img.get_data().flip_y()
	img.get_data().save_png("res://FlexibleDestructibleSprite/test.png") # debug
	destructible_instance.position = pos
	destructible_instance.SPRITE = img
	destructible_instance.BLOCK_PATH = BLOCK_PATH
	destructible_instance.TILE_SIZE_POW = TILE_SIZE_POW
	destructible_instance.MIN_SIZE_POW = MIN_SIZE_POW
	get_parent().get_parent().get_parent().add_child(destructible_instance)
	destructible_instance.connect("destructible_sprite_loaded",get_tree().get_current_scene(),"destructibleLoaded")
	destructible_instance.parseSprite()

# adds tilemap as a child of the viewport
func addTilemapToViewport(tilemapRect):
	get_parent().call_deferred("remove_child",self)
	viewport.call_deferred("add_child", self)
	# offsets the tilemap position to the first pixel on the top left
	position = Vector2(0,0) - tilemapRect.position

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
	viewport.set_usage(0)
	viewport.render_target_v_flip = true
	viewportC.add_child(viewport)
	get_parent().call_deferred("add_child",viewportC)
	return viewport
