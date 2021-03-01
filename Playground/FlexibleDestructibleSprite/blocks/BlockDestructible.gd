extends StaticBody2D

# So here it how it works
# when a dig area is colliding with this block, 
# if it is already at the minimum size, then it is destroy
# otherwise, it is divided in 4 new blocks (one check if the new block will collide with the area or not before creating, to avoid it being painfully slow)

var Size = 32 # current size of this destructible block
var spriteTexture = Texture # texture of this block

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
func recurCreate(curSize, Pos, body):
	if(isNewBlockColliding(Pos, body)):
		if(curSize > get_parent().minSize):
			var newPos = Pos
			for _row in range(2):
				for _col in range(2):
					recurCreate(curSize/2, newPos, body)
					newPos.x += curSize
				newPos.x = position.x
				newPos.y += curSize
		else:
			return
	else:
		get_parent().createNewBlockArea(curSize, Pos)

# Returns true if the collider (as a circleShape) is colliding with a block at position blockPos with size Size
func isNewBlockColliding(blockPos, body):
	var globalBlockPos = blockPos + get_parent().position
	var bodyRadius = body.getCollisionRadius()
	return((sqrt(pow((body.position.x - globalBlockPos.x), 2) + pow((body.position.y - globalBlockPos.y), 2))) < bodyRadius)

# Function to subdivide the block, or remove it if it is too small
func createDivideBlocks(body):
	var newPos = position
	if(Size > get_parent().minSize):
		for _row in range(2):
			for _col in range(2):
				if(not isNewBlockColliding(newPos, body)):
					get_parent().createNewBlockArea(Size/2, newPos)
				else:
					recurCreate(Size/2, newPos, body)
				newPos.x += Size
			newPos.x = position.x
			newPos.y += Size
	queue_free()

# when something that can dig is colliding with the block, subdivide it
func _on_Area2D_area_entered(area):
	if(area.is_in_group("Terraform")):
		createDivideBlocks(area)
