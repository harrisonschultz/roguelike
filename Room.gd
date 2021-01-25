extends Object


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
class_name Room

var topLeft: Vector2
var topRight: Vector2
var bottomLeft: Vector2
var bottomRight: Vector2
var exitSize: int
var height: int 
var width: int
var gridMaxX: int
var gridMaxY: int
var exits = [null,null,null,null]
var map
var walls
var floors
var debugTileGlobals

enum Sides { Top, Right, Bottom, Left }
var ExitCounterpart = [Sides.Bottom, Sides.Left, Sides.Top, Sides.Right]


func _init(bl, h, w, Map, WallsTileMap, FloorTileMap, DebugTileMap, ExitSize):
	bottomLeft = bl
	map = Map
	walls = WallsTileMap
	floors = FloorTileMap
	gridMaxX = map.size() -1
	gridMaxY = map[0].size() -1
	exitSize = ExitSize
	height = h
	width = w
	topLeft = Vector2(bottomLeft.x, bottomLeft.y - (height - 1))
	topRight = Vector2(bottomLeft.x + width - 1, bottomLeft.y - (height - 1))
	bottomRight = Vector2(bottomLeft.x + width - 1, bottomLeft.y)
	determinePossibleExits()

	
static func getBottomLeftFromExit(point, direction, height, width, exitSize):
		var centerHeight = round(height/2)
		var centerWidth = round(width/2)
		
		if direction == Sides.Top:
			var centerPoint = Vector2(point.x + round(exitSize/2), point.y -1)
			return Vector2(centerPoint.x - centerWidth, centerPoint.y)
		if direction == Sides.Right:
			var centerPoint = Vector2(point.x + 1, point.y + round(exitSize/2))
			return Vector2(centerPoint.x, centerPoint.y + centerHeight)
		if direction == Sides.Bottom:
			var centerPoint = Vector2(point.x + round(exitSize/2), point.y + height)
			return Vector2(centerPoint.x - centerWidth, centerPoint.y)
		if direction == Sides.Left:
			var centerPoint = Vector2(point.x - 1, point.y + round(exitSize/2))
			return Vector2(centerPoint.x, centerPoint.y + centerHeight)

func canFit():
	var prevX = topLeft.x -1
	for x in range(topLeft.x, bottomRight.x + 1):
		for y in range(topLeft.y, bottomRight.y + 1):
			if map[x][y] != -1:
				if prevX != x:
					return 'width'
				else:
					return 'height'
			prevX = x
	return 'fit'	
	
func changeMapTile(x, y, type):
	if map[x][y] != Globals.Map.Hallway:
		map[x][y] = type
		return true
	return false
	
func buildRoom():
		var yRange = range(topRight.y, bottomRight.y + 1)
		var xRange = range(topLeft.x, topRight.x + 1)
	
		for x in xRange:
			for y in yRange:
				changeMapTile(x, y, Globals.Map.Occupied)
				# Fill the top of the top wall (top walls are 2 cells tall)
				if y == topRight.y:
					changeMapTile(x, y, Globals.Map.Edge)
					if x == topLeft.x:
						walls.set_cell(x, y, Globals.WallTiles.TopLeft)
						continue
					elif x == topRight.x:
						walls.set_cell(x, y, Globals.WallTiles.TopRight)
						continue
					else:
						walls.set_cell(x,y, Globals.WallTiles.Top)
						continue
						
				# Bottom Walls
				elif y == bottomLeft.y:
					changeMapTile(x, y, Globals.Map.Edge)
					if x == bottomLeft.x:
						walls.set_cell(x, y, Globals.WallTiles.BottomLeft)
						continue
					elif x == bottomRight.x:
						walls.set_cell(x, y, Globals.WallTiles.BottomRight)
						continue
					else:
						floors.set_cell(x, y, 1)
						walls.set_cell(x, y, Globals.WallTiles.Bottom)
						continue
				
				else:
					# Side Walls
					if x == topLeft.x:
						changeMapTile(x, y, Globals.Map.Edge)
						walls.set_cell(x,y, Globals.WallTiles.Left)
						continue
					elif x == topRight.x:
						changeMapTile(x, y, Globals.Map.Edge)
						walls.set_cell(x,y, Globals.WallTiles.Right)
						continue
					# Top Walls
					elif y == topRight.y + 1 && x > topLeft.x && x < topRight.x && changeMapTile(x, y, Globals.Map.Edge):
						walls.set_cell(x,y, Globals.WallTiles.Wall)
						continue
					# Everything else
					else:
						floors.set_cell(x, y, 1)
	
func determinePossibleExits():
	# Look at each side of the room and determine if an exit can exist
	# Dont include corners in the length
	var topWallLength = topRight.x - topLeft.x -2
	var	rightWallLength = bottomRight.y - topRight.y -2
	var bottomWallLength = bottomRight.x - bottomLeft.x -2
	var	leftWallLength = bottomLeft.y - topLeft.y -2
	
	# Check Top
	if !topLeft.y <= 10 && topWallLength >= exitSize:
		exits[Sides.Top] = Vector2(topLeft.x + round(width/2) - round(exitSize/2) , topLeft.y)
		
	# Check Right
	if !topRight.x == gridMaxY && rightWallLength >= exitSize:
		exits[Sides.Right] = Vector2(topRight.x, topRight.y + round(height/2) - round(exitSize/2))
		
	# Check Bottom
	if !bottomLeft.y == gridMaxY && bottomWallLength >= exitSize:
		exits[Sides.Bottom] = Vector2(topLeft.x + round(width/2) - round(exitSize/2) , bottomLeft.y)
		
	# Check Left
	if !topLeft.x <= 10 && leftWallLength >= exitSize:
		exits[Sides.Left] = Vector2(topLeft.x, topLeft.y + round(height/2) - round(exitSize/2))
	
func buildExit(direction, point = null):
	# Translate if given an another rooms exit origin
	if point:
		if direction == Sides.Top:
			exits[Sides.Top] = Vector2(point.x, point.y + 1)
		if direction == Sides.Right:
			exits[Sides.Right] = Vector2(point.x - 1, point.y)
		if direction == Sides.Bottom:
			exits[Sides.Bottom] = Vector2(point.x, point.y - 1)
		if direction == Sides.Left:
			exits[Sides.Left] = Vector2(point.x + 1, point.y)

	if direction == Sides.Top:
		var farEdge = Vector2(exits[Sides.Top].x + exitSize -1, exits[Sides.Top].y)
		
		# Set corner tiles of exit
		walls.set_cell(exits[Sides.Top].x, exits[Sides.Top].y, Globals.WallTiles.TopInnerRight)
		walls.set_cell(farEdge.x, farEdge.y, Globals.WallTiles.TopInnerLeft)
		
		# Record location
		map[exits[Sides.Top].x][exits[Sides.Top].y] = Globals.Map.Hallway
		map[farEdge.x][farEdge.y] = Globals.Map.Hallway
		
		# Set floor tiles, and remove walls
		for x in range(exits[Sides.Top].x+1, farEdge.x ):
			for y in range(exits[Sides.Top].y, farEdge.y + 2 ):
				map[x][y] = Globals.Map.Hallway
				walls.set_cell(x, y, -1)
				floors.set_cell(x, y, 1)
				
	if direction == Sides.Right:
		var farEdge = Vector2(exits[Sides.Right].x, exits[Sides.Right].y + exitSize -1)

		# Set corner tiles of exit and top wall
		walls.set_cell(exits[Sides.Right].x, exits[Sides.Right].y, Globals.WallTiles.TopInnerLeft)
		walls.set_cell(exits[Sides.Right].x, exits[Sides.Right].y + 1,  Globals.WallTiles.Wall)
		
		map[exits[Sides.Right].x][exits[Sides.Right].y] = Globals.Map.Hallway
		map[exits[Sides.Right].x][exits[Sides.Right].y + 1] = Globals.Map.Hallway
		map[farEdge.x][farEdge.y] = Globals.Map.Hallway
		
		for y in range(exits[Sides.Right].y + 2, farEdge.y + 1):
			map[exits[Sides.Right].x][y] = Globals.Map.Hallway
			walls.set_cell(exits[Sides.Right].x, y, -1)
			floors.set_cell(exits[Sides.Right].x, y, 1)
			
		walls.set_cell(farEdge.x, farEdge.y, Globals.WallTiles.BottomInnerLeft)

	if direction == Sides.Bottom:
		var farEdge = Vector2(exits[Sides.Bottom].x + exitSize -1, exits[Sides.Bottom].y)
		
		# Set corner tiles of exit
		walls.set_cell(exits[Sides.Bottom].x, exits[Sides.Bottom].y, Globals.WallTiles.BottomInnerRight)
		walls.set_cell(farEdge.x, farEdge.y, Globals.WallTiles.BottomInnerLeft)
		
		# Record location
		map[exits[Sides.Bottom].x][exits[Sides.Bottom].y] = Globals.Map.Hallway
		map[farEdge.x][farEdge.y] = Globals.Map.Hallway
		
		# Set floor tiles, and remove walls
		for x in range(exits[Sides.Bottom].x+1, farEdge.x ):
				map[x][exits[Sides.Bottom].y] = Globals.Map.Hallway
				walls.set_cell(x, exits[Sides.Bottom].y, -1)
				floors.set_cell(x, exits[Sides.Bottom].y, 1)
				
	if direction == Sides.Left:
		var farEdge = Vector2(exits[Sides.Left].x, exits[Sides.Left].y + exitSize -1)

		# Set corner tiles of exit and top wall
		walls.set_cell(exits[Sides.Left].x, exits[Sides.Left].y, Globals.WallTiles.TopInnerRight)
		walls.set_cell(exits[Sides.Left].x, exits[Sides.Left].y + 1,  Globals.WallTiles.Wall)

		map[exits[Sides.Left].x][exits[Sides.Left].y] = Globals.Map.Hallway
		map[exits[Sides.Left].x][exits[Sides.Left].y + 1] = Globals.Map.Hallway
		map[farEdge.x][farEdge.y] = Globals.Map.Hallway
		

		for y in range(exits[Sides.Left].y+2, farEdge.y + 1):
			map[exits[Sides.Left].x][y] = Globals.Map.Hallway
			walls.set_cell(exits[Sides.Left].x, y, -1)
			floors.set_cell(exits[Sides.Left].x, y, 1)
			
		walls.set_cell(farEdge.x, farEdge.y, Globals.WallTiles.BottomInnerRight)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
