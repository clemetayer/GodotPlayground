extends RigidBody2D

var temp = 0
var Size = 32
var spriteTexture = Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	createShape()

# Sets the shape of the block (areaCollision and staticBlockCollision)
func createShape():
	var areaCollision = get_node("Area2D/AreaCollision")
	var solidCollision = get_node("SolidCollision")
	var newCol = RectangleShape2D.new()
	newCol.set_extents(Vector2(Size,Size))
	areaCollision.set_shape(newCol)
	areaCollision.position = Vector2(Size,Size)
	solidCollision.set_shape(newCol)
	solidCollision.position = Vector2(Size,Size)

# Sets the subpart texture on the block
func setRegionTexture(pos):
	var spriteArea = Rect2(pos, Vector2(Size*2,Size*2))
	get_node("Sprite").set_region(true)
	get_node("Sprite").set_texture(spriteTexture)
	get_node("Sprite").set_region_rect(spriteArea)

# Function to subdivide a block, and check if each block is not colliding before creating
# (to save resources)
func recurCreate(Size, Pos, body):
	if(isNewBlockColliding(Pos, Size, body)):
		if(Size > get_parent().minSize):
			var newPos = Pos
			for row in range(2):
				for col in range(2):
					recurCreate(Size/2, newPos, body)
					newPos.x += Size
				newPos.x = position.x
				newPos.y += Size
		else:
			return
	else:
		get_parent().createNewBlockArea(Size, Pos)

# Returns true if the collider (as a circleShape) is colliding with a block at position blockPos with size Size
func isNewBlockColliding(blockPos, Size, body):
	var globalBlockPos = blockPos + get_parent().position
	var bodyRadius = body.getCollisionRadius()
	return((sqrt(pow((body.position.x - globalBlockPos.x), 2) + pow((body.position.y - globalBlockPos.y), 2))) < bodyRadius)

# Function to subdivide the block, or remove it if it is too small
func createDivideBlocks(body):
	var newPos = position
	if(Size > get_parent().minSize):
		for row in range(2):
			for col in range(2):
				if(not isNewBlockColliding(newPos, Size, body)):
					get_parent().createNewBlockArea(Size/2, newPos)
				else:
					recurCreate(Size/2, newPos, body)
				newPos.x += Size
			newPos.x = position.x
			newPos.y += Size
	queue_free()

# Subdivides the block if a dig area entered
func _on_Area2D_area_entered(area):
	if(area.is_in_group("Terraform")):
		createDivideBlocks(area)
