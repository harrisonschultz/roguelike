extends Node

var Floor
var Walls
var map = []
var rng = RandomNumberGenerator.new()
const wallsWithCollision = [7,8,14,15]
const LEVEL_SIZE = 80
const MIN_ROOM_SIZE = 11
const MAX_ROOM_SIZE = 14
enum WallTiles { Door, Wall, WallMissingBricks, WallWithGrate, Crack, Bottom, BottomLeft, BottomRight, Top, TopLeft, TopRight, Left, Right, TopInnerRight, TopInnerLeft, BottomInnerLeft, BottomInnerRight }
enum Map { Occupied, Edge, Hallway}
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	Floor = get_node("Floor")
	Walls = get_node("Walls")
	loadLevel()

func move(node, destination: Vector2, x, y):
	if checkTileToMove(destination):
		node.position.x += x
		node.position.y += y
		
func checkTileToMove(destination):
	var cell = Floor.get_cell(destination.x, destination.y)
	if cell > -1:
		return true
	else:
		return false

func loadLevel():
	# initialize map
	for col in 40:
		map.append([])
		for row in 200:
			map[col].append(0)
			
	# Generate Rooms
	var roomCount = 5
	for count in roomCount:
		buildRoom()
		
func buildRoom():
	var height = rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	var width = rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	var topRight = findEmptySpace(height, width)
	
	# If available then fill those spaces
	if topRight:
		var topLeft = Vector2(topRight.x - width +1, topRight.y)
		var bottomLeft = Vector2(topRight.x - width +1, topRight.y + height -1)
		var bottomRight = Vector2(topRight.x, topRight.y+height -1)
		
		var rowRange = range(topRight.y, bottomRight.y + 1)
		var colRange =  range(topLeft.x, topRight.x + 1)
		for row in rowRange:
			for col in colRange:
				map[col][row] = Map.Occupied
				# Fill the top of the top wall (top walls are 2 cells tall)
				if row == topRight.y:
					map[col][row] = Map.Edge
					# Check for adjacent rooms
					if col == topLeft.x:
						Walls.set_cell(col, row, WallTiles.TopLeft)
						continue
					elif col == topRight.x:
						Walls.set_cell(col, row, WallTiles.TopRight)
						continue
					else:
						Walls.set_cell(col, row, WallTiles.Top)
						continue
						
				# Bottom Walls
				elif row == bottomLeft.y:
					map[col][row] = Map.Edge
					if col == bottomLeft.x:
						Walls.set_cell(col, row, WallTiles.BottomLeft)
						continue
					elif col == bottomRight.x:
						Walls.set_cell(col, row, WallTiles.BottomRight)
						continue
					else:
						Floor.set_cell(col,row, 1)
						Walls.set_cell(col, row, WallTiles.Bottom)
						continue
				
				else:
					# Side Walls
					if col == topLeft.x:
						# Check for adjacent rooms
						if !setHallway(row, col, "left", bottomLeft.y / 2):
							if map[col][row] != Map.Hallway:
								map[col][row] = Map.Edge
								Walls.set_cell(col,row, WallTiles.Left)
						continue
					elif col == topRight.x:
						map[col][row] = Map.Edge
						Walls.set_cell(col,row, WallTiles.Right)
						continue
					# Top Walls
					elif row == topRight.y + 1 && col > topLeft.x && col < topRight.x:
						map[col][row] = Map.Edge
						Walls.set_cell(col,row, WallTiles.Wall)
						continue
					# Everything else
					else:
						Floor.set_cell(col, row, 1)
						
func setHallway(row, col, direction, center):
	var hallWayGirth = 4
	var hallWayLength = 1
	var wallToCheckForCenter
	var hallWayRange = range(center - 1, center  +2)
	var points = []
	var rowToCheck = row
	var colToCheck = col
	
	if direction == 'up':
		rowToCheck = row - 1
		wallToCheckForCenter = col
	elif direction == 'right':
		colToCheck = col + 1
		wallToCheckForCenter = row
	elif direction == 'down':
		rowToCheck = row + 1
		wallToCheckForCenter = col
	elif direction == 'left':
		colToCheck = col -1
		wallToCheckForCenter = row
		
	if map[colToCheck][rowToCheck] == Map.Hallway:
		return true
	
	if map[colToCheck][rowToCheck] == Map.Edge && hallWayRange.has(wallToCheckForCenter):
		if direction == 'up':
			var topRight = Vector2(col + hallWayGirth, row - hallWayLength)
			var topLeft= Vector2(col, row - hallWayLength)
			var bottomRight= Vector2(col + hallWayGirth, row)
			var bottomLeft= Vector2(col, row)
			
			Walls.set_cell(topRight.x, topRight.y, WallTiles.BottomInnerRight)
			Walls.set_cell(topLeft.x, topLeft.y, WallTiles.BottomInnerLeft)
			Walls.set_cell(bottomRight.x, bottomRight.y, WallTiles.TopInnerRight)
			Walls.set_cell(bottomLeft.x, bottomLeft.y, WallTiles.TopInnerLeft)
			
			for x in range(bottomLeft.x, topRight.x):
				for y in range(topLeft.y, bottomLeft.y):
					Floor.set_cell(x, y, 1)
					
		elif direction == 'right':
			var topRight = Vector2(col + hallWayLength, row)
			var topLeft= Vector2(col, row)
			var bottomRight= Vector2(col + hallWayLength, row + hallWayGirth)
			var bottomLeft= Vector2(col, row + hallWayGirth)
			
			Walls.set_cell(topRight.x, topRight.y, WallTiles.BottomInnerRight)
			Walls.set_cell(topLeft.x, topLeft.y, WallTiles.BottomInnerLeft)
			Walls.set_cell(bottomRight.x, bottomRight.y, WallTiles.TopInnerRight)
			Walls.set_cell(bottomLeft.x, bottomLeft.y, WallTiles.TopInnerLeft)
			Walls.set_cell(topLeft.x, topLeft.y +1, WallTiles.Wall)
			Walls.set_cell(topRight.x, topRight.y +1, WallTiles.Wall)
			
			for x in range(bottomLeft.x, topRight.x):
				for y in range(topLeft.y + 1, bottomLeft.y + 1):
					Floor.set_cell(x, y, 1)
					
		elif direction == 'down':
			var bottomRight = Vector2(col + hallWayGirth, row + hallWayLength)
			var bottomLeft = Vector2(col, row + hallWayLength)
			var topRight= Vector2(col + hallWayGirth, row)
			var topLeft = Vector2(col, row)
			
			Walls.set_cell(topRight.x, topRight.y, WallTiles.BottomInnerRight)
			Walls.set_cell(topLeft.x, topLeft.y, WallTiles.BottomInnerLeft)
			Walls.set_cell(bottomRight.x, bottomRight.y, WallTiles.TopInnerRight)
			Walls.set_cell(bottomLeft.x, bottomLeft.y, WallTiles.TopInnerLeft)
			
			for x in range(bottomLeft.x, topRight.x):
				for y in range(topLeft.y, bottomLeft.y):
					Floor.set_cell(x, y, 1)
		elif direction == 'left':
			var topRight = Vector2(col, row)
			var topLeft= Vector2(col - hallWayLength, row)
			var bottomRight= Vector2(col, row + hallWayGirth)
			var bottomLeft= Vector2(col - hallWayLength, row + hallWayGirth)
			
			if map[topRight.x][topRight.y] == Map.Hallway:
				return true
			if map[topLeft.x][topLeft.y] == Map.Hallway:
				return true
			elif map[bottomRight.x][bottomRight.y] == Map.Hallway:
				return true
			elif map[bottomLeft.x][bottomRight.y] == Map.Hallway:
				return true
			elif map[topLeft.x][topLeft.y + 1] == Map.Hallway:
				return true
			elif map[topRight.x][topRight.y + 1] == Map.Hallway:
				return true
			
			Walls.set_cell(topRight.x, topRight.y, WallTiles.TopInnerRight)
			Walls.set_cell(topLeft.x, topLeft.y, WallTiles.TopInnerLeft)
			Walls.set_cell(topLeft.x, topLeft.y +1, WallTiles.Wall)
			Walls.set_cell(topRight.x, topRight.y +1, WallTiles.Wall)
			
			map[topRight.x][topRight.y] = Map.Hallway
			map[topLeft.x][topLeft.y] = Map.Hallway
			map[bottomRight.x][bottomRight.y] = Map.Hallway
			map[bottomLeft.x][bottomRight.y] = Map.Hallway
			map[topLeft.x][topLeft.y + 1] = Map.Hallway
			map[topRight.x][topRight.y + 1] = Map.Hallway
			
			for x in range(bottomLeft.x, topRight.x+1):
				for y in range(topLeft.y + 2, bottomLeft.y + 1):
					map[x][y] = Map.Hallway
					Walls.set_cell(x, y, -1)
					Floor.set_cell(x, y, 1)
					
			Walls.set_cell(bottomRight.x, bottomRight.y, WallTiles.BottomInnerRight)
			Walls.set_cell(bottomLeft.x, bottomLeft.y, WallTiles.BottomInnerLeft)
				
		return true
	else:
		return false
	
func findEmptySpace(height, width):
	var emptyLength = 0
	# Look for a spot in the row column array of empty spots
	for row in range(map.size()):
		for col in range(map.size()):
			print(col)
			if map[col][row] == 0:
				emptyLength += 1
				if emptyLength == width && checkMapSquare(height, width, row, col):
					return Vector2(col, row)
			else:
				emptyLength = 0
	return null
	
# Checks for a spot in map large enough to hold the room.
# Starting from the top left and iterating through
func checkMapSquare(height, width, x, y):
		for row in range(y, y+height-1):
			for col in range(x-width+1, x):
				if map[col][row] == 1:
					return false
		return true
		
	
