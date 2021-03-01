extends Node2D

# TODO : check with a sprite with odd size

# Here is how it works
# first, the sprite is converted to a bitmap, to detect the transparent and not transparent parts
# then, one divide this sprite in max size blocks (2^TILE_SIZE_POW)
# if this block is completely transparent, then one does not put a destructible block in it
# else if this block is completely full, then one put a destructible block in it
# else if it is not entirely full/transparent, one divide the block in 4, and redo the if-else section for each block

signal destructible_sprite_loaded()

export var TILE_SIZE_POW = 6 # Starting tile size (as a power of 2, i.e 2^6 = 64)
export var MIN_SIZE_POW = 2 # Minimal tile size (as a power of 2, i.e 2^2 = 4)
export var MIN_FPS = 15 # Minimal goal FPS
export var GOAL_FPS = 30 # Desired average FPS

export(Texture) var SPRITE # General texture of the destructible block (only non transparent part will have a Destructible block)
export(String) var BLOCK_PATH = "res://FlexibleDestructibleSprite/blocks/BlockArea.tscn" # Path of an instance of BlockDestructible
																		   # By default, it is a BlockArea, but you can also set it up to "BlockPysics" if you want to toast your CPU

var stepFPS = (GOAL_FPS - MIN_FPS)/3 # Number of "steps" of FPS states (ex: 60-40-20)
var blockArea # load of BLOCK_PATH
var bitmap = BitMap # bitmap of the SPRITE
var minSize = pow(2,MIN_SIZE_POW) # true value of minimal size (2^MIN_SIZE_POW)
var started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	started = false

func parseSprite():
	blockArea = load(BLOCK_PATH)
	bitmap = BitMap.new()
	bitmap.create_from_image_alpha(SPRITE.get_data())
	subdivideOriginalSprite()
	started = true
	emit_signal("destructible_sprite_loaded")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(started):
		checkFPS()

# Check FPS, and changes the minimal block size if it is too low
func checkFPS():
	var avgFps = Performance.get_monitor(Performance.TIME_FPS)
	if(avgFps > GOAL_FPS):
		minSize = 4
	elif((avgFps < GOAL_FPS) and (avgFps >= MIN_FPS + 2*stepFPS)):
		minSize = 8
	elif((avgFps < MIN_FPS + 2*stepFPS) and (avgFps >= MIN_FPS + stepFPS)):
		minSize = 16
	elif((avgFps < MIN_FPS + stepFPS) and (avgFps >= MIN_FPS)):
		minSize = 32
	else:
		minSize = 64

# Returns an array : ret[0] => is empty; ret[1] => is full
func isTransparentOrFull(size, position):
	var retArray = [true,true]
	for row in range(size):
		for col in range(size):
			if(bitmap.get_bit((position + Vector2(row,col)))):
				retArray[0] = false
			else:
				retArray[1] = false
	return retArray

# Subdivides a block in 4, then check if each sublock is transparent or not
func subdivideBlock(Size, position):
	var newPos = position
	if(Size > minSize):
		for _row in range(2):
			for _col in range(2):
				var isTransparentFullArray = isTransparentOrFull(Size/2, newPos)
				if(not isTransparentFullArray[0]): # is not entirely transparent
					if(not isTransparentFullArray[1]): # is not entirely full
						subdivideBlock(Size/2, newPos)
					else: # is entirely full
						createNewBlockArea(Size/2, newPos)
				newPos.x += Size/2
			newPos.x = position.x
			newPos.y += Size/2

# First subdivision of the sprite
func subdivideOriginalSprite():
	var spriteSize = SPRITE.get_size()
	var xPos = 0
	var yPos = 0
	var xPosTexture = 0
	var yPosTexture = 0
	for _row in range(spriteSize.y/pow(2,TILE_SIZE_POW)):
		for _col in range(spriteSize.x/pow(2,TILE_SIZE_POW)):
			var area = blockArea.instance()
			area.spriteTexture = SPRITE
			area.position = Vector2(xPos,yPos)
			var isTransparentFullArray = isTransparentOrFull(pow(2,TILE_SIZE_POW), Vector2(xPos,yPos))
			if(not isTransparentFullArray[0]): # is not entirely transparent
				if(not isTransparentFullArray[1]): # is not entirely full
					subdivideBlock(pow(2,TILE_SIZE_POW), Vector2(xPos,yPos))
				else: # is entirely full
					area.setRegionTexture(Vector2(xPosTexture,yPosTexture))
					self.call_deferred("add_child",area)
			xPos += pow(2,TILE_SIZE_POW)
			xPosTexture += pow(2,TILE_SIZE_POW)
		xPos = 0
		xPosTexture = 0
		yPos += pow(2,TILE_SIZE_POW)
		yPosTexture += pow(2,TILE_SIZE_POW)

# Creates a new blockArea at position newPos, with size Size. Used in blockArea.tscn
func createNewBlockArea(Size, newPos):
	var area = blockArea.instance()
	area.position = newPos
	area.Size = Size
	area.spriteTexture = SPRITE
	area.setRegionTexture(newPos)
	self.call_deferred("add_child",area)
