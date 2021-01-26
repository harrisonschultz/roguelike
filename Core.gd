extends Node

var Floor
var Walls
var Player
var DebugTileMap
var rooms = []
var map = []
var EnemyRoot
var FogMap
const wallsWithCollision = [7,8,14,15]
const MIN_ROOM_SIZE = 8
const MAX_ROOM_SIZE = 12
const EXIT_SIZE = 5

var Slime = load("res://Enemies/Slime/Slime.tscn")

func _ready():
	Globals.rng.randomize()
	Floor = get_node("Floor")
	Walls = get_node("Walls")
	FogMap = get_node("Fog")
	DebugTileMap = get_node("Debug")
	Player = get_node('Player')
	EnemyRoot = get_node("EnemyRoot")
	loadLevel()
	step()

func move(node, destination: Vector2, point):
	if checkTileToMove(destination):
		node.position += point

		
func checkTileToMove(destination):
	# Wall Collision Check
	var cell = Floor.get_cell(destination.x, destination.y)
	if cell > -1:
		return true
	else:
		return false
		
func _input(event):
	if event.is_action('reset'):
		reloadLevel()
		
func step():
	var nodes = EnemyRoot.get_children()
	Player.step()
	for node in nodes:
		print(node.visionRange)
		node.step()
		
func reloadLevel():
	initializeMap()
	Walls.clear()
	Floor.clear()
	DebugTileMap.clear()
	loadLevel()
	
func initializeMap():
	map = []
	for r in rooms:
		r.free()
	rooms = []
	for x in Globals.LEVEL_SIZE:
		map.append([])
		for y in Globals.LEVEL_SIZE:
			if x < 10 || y < 10 || x > Globals.LEVEL_SIZE -10 || y > Globals.LEVEL_SIZE -10:
				map[x].append(0)
			else:
				map[x].append(-1)
			FogMap.set_cell(x,y, 0)

func buildFirstRoom():
	var height = Globals.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	var width = Globals.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		
	# Force only odd numbers for height and width
	height += height % 2 + 1
	width += width % 2 + 1
	
	var bottomLeft = Vector2(10, 10 + height - 1)
	var room = Room.new(bottomLeft, height, width, map, Walls, Floor, DebugTileMap, EXIT_SIZE)
	room.buildRoom()
	return room

func loadLevel():
	initializeMap()
			
	# Generate Rooms
	var roomCount = 20
	
	# Build first room
	rooms.append(buildFirstRoom())
	var count = 1;
	while rooms.size() < roomCount:
		if rooms.size() >= roomCount:
			break	
		var height = Globals.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		var width = Globals.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
		if count >= rooms.size() -1:
			count -= 1
		var room = rooms[count]
		
		# Force only odd numbers for height and width
		height += height % 2 + 1
		width += width % 2 + 1
		
		for exit in range(room.exits.size()):
			var finalExit = 0
			var exitExists = false
			for e in range(room.exits.size()):
				if room.exits[e]:
					finalExit = e
			if room.exits[exit] != null && rooms.size() <= roomCount:
				
				if !Globals.rng.randi_range(0, 3) && (exitExists || !(exit >= finalExit)):
					continue
				
				var bottomLeft = Room.getBottomLeftFromExit(room.exits[exit], exit, height, width, EXIT_SIZE)
				var connectingRoom = tryToFitRoom(bottomLeft, height, width)
				if connectingRoom:
					# If a room can fit then build the exits between rooms
					room.buildExit(exit)
					connectingRoom.buildRoom()
					connectingRoom.buildExit(room.ExitCounterpart[exit])
					rooms.append(connectingRoom)
					count +=1
					exitExists = true
					
					if rooms.size() == 2:
						# Add enemies to room
						var slime = Slime.instance()
						slime.init(EnemyDetails.enemies['slime'], getRandomRoomLocation(bottomLeft,height, width))
						EnemyRoot.add_child(slime)

		
	# DEBUG
	for x in range(map.size()):
		for y in range(map[x].size()):
			DebugTileMap.set_cell(x,y, map[x][y])
			
func getRandomRoomLocation(bottomLeft, height, width):
	bottomLeft = bottomLeft * Globals.tile_size
	height = (height - 3) * Globals.tile_size
	width = (width - 3) * Globals.tile_size
	var x = Globals.rng.randi_range(bottomLeft.x, bottomLeft.x + width)
	var y = Globals.rng.randi_range(bottomLeft.y, bottomLeft.y - height)
	var loc = Vector2(round(x),round(y))
	return loc
			
func tryToFitRoom(bottomLeft, height, width):
	if height < MIN_ROOM_SIZE || width < MIN_ROOM_SIZE:
		return null
	var room = Room.new(bottomLeft, height, width, map, Walls, Floor, DebugTileMap, EXIT_SIZE)
	var fit = room.canFit()
	if fit == 'width':
		tryToFitRoom(bottomLeft, height, width -2 )
	elif fit == 'height':
		tryToFitRoom(bottomLeft, height -2, width)
	else: 
		return room

func buildRoom(h = 0, w = 0):
	var height =  Globals.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	if h: 
		height = h
	var width = Globals.rng.randi_range(MIN_ROOM_SIZE, MAX_ROOM_SIZE)
	if w:
		width = w
	var bottomLeft = findEmptySpace(height, width)
	
	# If available then fill those spaces
	if bottomLeft:
		var topLeft = bottomLeft
		var topRight = bottomLeft
		var bottomRight = bottomLeft
		var verticalHallwayStart = round((bottomRight.x - bottomLeft.x) / 2) + bottomLeft.x -2
		var horizontalHallwayStart = round((bottomLeft.y - topLeft.y) / 2) + topLeft.y -2
		var yRange = range(topRight.y, bottomRight.y + 1)
		var xRange = range(topLeft.x, topRight.x + 1)
		
		for x in xRange:
			for y in yRange:
				changeMapTile(x, y, Globals.Map.Occupied)
				# Fill the top of the top wall (top walls are 2 cells tall)
				if y == topRight.y:
					changeMapTile(x, y, Globals.Map.Edge)
					if x == topLeft.x:
						Walls.set_cell(x, y, Globals.WallTiles.TopLeft)
						continue
					elif x == topRight.x:
						Walls.set_cell(x, y, Globals.WallTiles.TopRight)
						continue
					else:
						if verticalHallwayStart == x:
							setHallway(x, y, "up")
						if changeMapTile(x, y, Globals.Map.Edge):
							Walls.set_cell(x,y, Globals.WallTiles.Top)
						continue
						
				# Bottom Walls
				elif y == bottomLeft.y:
					changeMapTile(x, y, Globals.Map.Edge)
					if x == bottomLeft.x:
						Walls.set_cell(x, y, Globals.WallTiles.BottomLeft)
						continue
					elif x == bottomRight.x:
						Walls.set_cell(x, y, Globals.WallTiles.BottomRight)
						continue
					else:
						Floor.set_cell(x, y, 1)
						Walls.set_cell(x, y, Globals.WallTiles.Bottom)
						continue
				
				else:
					# Side Walls
					if x == topLeft.x:
						# Check for adjacent rooms
						if horizontalHallwayStart == y:
							setHallway(x, y, "left")
						if changeMapTile(x, y, Globals.Map.Edge):
							Walls.set_cell(x,y, Globals.WallTiles.Left)
						continue
					elif x == topRight.x:
						changeMapTile(x, y, Globals.Map.Edge)
						Walls.set_cell(x,y, Globals.WallTiles.Right)
						continue
					# Top Walls
					elif y == topRight.y + 1 && x > topLeft.x && x < topRight.x && changeMapTile(x, y, Globals.Map.Edge):
						Walls.set_cell(x,y, Globals.WallTiles.Wall)
						continue
					# Everything else
					else:
						Floor.set_cell(x, y, 1)
		return true
	else:
		if height <= MIN_ROOM_SIZE || width <= MIN_ROOM_SIZE:
			return false
		buildRoom(height -1, width -1)
							
func changeMapTile(x, y, type):
	if map[x][y] != Globals.Map.Hallway:
		map[x][y] = type
		return true
	return false
						
func setHallway(col, row, direction):
	var hallWayGirth = 4
	var hallWayLength = 1
	var rowToCheck = row
	var colToCheck = col
	
	if direction == 'up':
		rowToCheck = row - 1
		# Check all spots to add a valid hallway
		for x in range(col, col + hallWayGirth + 2):
			if x < 0 || x > map.size() -1 || rowToCheck < 0 || rowToCheck > map[0].size() - 1 || map[x][rowToCheck] != Globals.Map.Edge:
				return false
				
	elif direction == 'right':
		colToCheck = col + 1
		# Check all spots to add a valid hallway
		for y in range(row, row + hallWayGirth + 2):
			if colToCheck < 0 || colToCheck > map.size() -1 || y < 0 || y > map[0].size() - 1 || map[colToCheck][y] != Globals.Map.Edge:
				return false
					
	elif direction == 'down':
		rowToCheck = row + 1
		# Check all spots to add a valid hallway
		for x in range(col, col + hallWayGirth + 2):
			if x < 0 || x > map.size() -1 || rowToCheck < 0 || rowToCheck > map[0].size() - 1 || map[x][rowToCheck] != Globals.Map.Edge:
				return false
	elif direction == 'left':
		colToCheck = col -1
		# Check all spots to add a valid hallway
		for y in range(row, row + hallWayGirth + 2):
			if colToCheck < 0 || colToCheck > map.size() -1 || y < 0 || y > map[0].size() - 1 || map[colToCheck][y] != Globals.Map.Edge:
				return false
		
	if map[colToCheck][rowToCheck] == Globals.Map.Hallway:
			return true
	
	if direction == 'up':
		var topRight = Vector2(col + hallWayGirth, row - hallWayLength)
		var topLeft = Vector2(col, row - hallWayLength)
		var bottomRight = Vector2(col + hallWayGirth, row)
		var bottomLeft = Vector2(col, row)
		
		if map[topRight.x][topRight.y] == Globals.Map.Hallway:
			return true
		elif map[topLeft.x][topLeft.y] == Globals.Map.Hallway:
			return true
		elif map[bottomRight.x][bottomRight.y] == Globals.Map.Hallway:
			return true
		elif map[bottomLeft.x][bottomRight.y] == Globals.Map.Hallway:
			return true
		
		Walls.set_cell(topRight.x, topRight.y,  Globals.WallTiles.BottomInnerLeft)
		Walls.set_cell(topLeft.x, topLeft.y, Globals.WallTiles.BottomInnerRight)
		Walls.set_cell(bottomRight.x, bottomRight.y,Globals.WallTiles.TopInnerLeft)
		Walls.set_cell(bottomLeft.x, bottomLeft.y, Globals.WallTiles.TopInnerRight)
		
		map[topRight.x][topRight.y] = Globals.Map.Hallway
		map[topLeft.x][topLeft.y] = Globals.Map.Hallway
		map[bottomRight.x][bottomRight.y] = Globals.Map.Hallway
		map[bottomLeft.x][bottomLeft.y] = Globals.Map.Hallway
		
		for x in range(bottomLeft.x+1, topRight.x):
			for y in range(topLeft.y, bottomLeft.y +2):
				print(str(x)+", "+str(y))
				map[x][y] = Globals.Map.Hallway
				Walls.set_cell(x, y, -1)
				Floor.set_cell(x, y, 1)
				
	elif direction == 'right':
		var topRight = Vector2(col + hallWayLength, row)
		var topLeft= Vector2(col, row)
		var bottomRight= Vector2(col + hallWayLength, row + hallWayGirth)
		var bottomLeft= Vector2(col , row + hallWayGirth)
		
		if map[topRight.x][topRight.y] == Globals.Map.Hallway:
			return true
		if map[topLeft.x][topLeft.y] == Globals.Map.Hallway:
			return true
		elif map[bottomRight.x][bottomRight.y] == Globals.Map.Hallway:
			return true
		elif map[bottomLeft.x][bottomRight.y] == Globals.Map.Hallway:
			return true
		elif map[topLeft.x][topLeft.y + 1] == Globals.Map.Hallway:
			return true
		elif map[topRight.x][topRight.y + 1] == Globals.Map.Hallway:
			return true
		
		Walls.set_cell(topRight.x, topRight.y, Globals.WallTiles.TopInnerRight)
		Walls.set_cell(topLeft.x, topLeft.y, Globals.WallTiles.TopInnerLeft)
		Walls.set_cell(topLeft.x, topLeft.y +1, Globals.WallTiles.Wall)
		Walls.set_cell(topRight.x, topRight.y +1, Globals.WallTiles.Wall)
		
		map[topRight.x][topRight.y] = Globals.Map.Hallway
		map[topLeft.x][topLeft.y] = Globals.Map.Hallway
		map[bottomRight.x][bottomRight.y] = Globals.Map.Hallway
		map[bottomLeft.x][bottomRight.y] = Globals.Map.Hallway
		map[topLeft.x][topLeft.y + 1] = Globals.Map.Hallway
		map[topRight.x][topRight.y + 1] = Globals.Map.Hallway
		
		for x in range(bottomLeft.x, topRight.x+1):
			for y in range(topLeft.y + 2, bottomLeft.y + 1):
				map[x][y] = Globals.Map.Hallway
				Walls.set_cell(x, y, -1)
				Floor.set_cell(x, y, 1)
				
		Walls.set_cell(bottomRight.x, bottomRight.y, Globals.WallTiles.BottomInnerRight)
		Walls.set_cell(bottomLeft.x, bottomLeft.y, Globals.WallTiles.BottomInnerLeft)
				
	elif direction == 'down':
		var bottomRight = Vector2(col + hallWayGirth, row + hallWayLength)
		var bottomLeft = Vector2(col, row + hallWayLength)
		var topRight= Vector2(col + hallWayGirth, row)
		var topLeft = Vector2(col, row)
		
		Walls.set_cell(topRight.x, topRight.y, Globals.WallTiles.BottomInnerRight)
		Walls.set_cell(topLeft.x, topLeft.y, Globals.WallTiles.BottomInnerLeft)
		Walls.set_cell(bottomRight.x, bottomRight.y, Globals.WallTiles.TopInnerRight)
		Walls.set_cell(bottomLeft.x, bottomLeft.y, Globals.WallTiles.TopInnerLeft)
		
		for x in range(bottomLeft.x, topRight.x):
			for y in range(topLeft.y, bottomLeft.y):
				Floor.set_cell(x, y, 1)
	elif direction == 'left':
		var topRight = Vector2(col, row)
		var topLeft = Vector2(col - hallWayLength, row)
		var bottomRight = Vector2(col, row + hallWayGirth)
		var bottomLeft = Vector2(col - hallWayLength, row + hallWayGirth)
		
		if map[topRight.x][topRight.y] == Globals.Map.Hallway:
			return true
		if map[topLeft.x][topLeft.y] == Globals.Map.Hallway:
			return true
		elif map[bottomRight.x][bottomRight.y] == Globals.Map.Hallway:
			return true
		elif map[bottomLeft.x][bottomRight.y] == Globals.Map.Hallway:
			return true
		elif map[topLeft.x][topLeft.y + 1] == Globals.Map.Hallway:
			return true
		elif map[topRight.x][topRight.y + 1] == Globals.Map.Hallway:
			return true
		
		Walls.set_cell(topRight.x, topRight.y, Globals.WallTiles.TopInnerRight)
		Walls.set_cell(topLeft.x, topLeft.y, Globals.WallTiles.TopInnerLeft)
		Walls.set_cell(topLeft.x, topLeft.y +1, Globals.WallTiles.Wall)
		Walls.set_cell(topRight.x, topRight.y +1, Globals.WallTiles.Wall)
		
		map[topRight.x][topRight.y] = Globals.Map.Hallway
		map[topLeft.x][topLeft.y] = Globals.Map.Hallway
		map[bottomRight.x][bottomRight.y] = Globals.Map.Hallway
		map[bottomLeft.x][bottomRight.y] = Globals.Map.Hallway
		map[topLeft.x][topLeft.y + 1] = Globals.Map.Hallway
		map[topRight.x][topRight.y + 1] = Globals.Map.Hallway
		
		for x in range(bottomLeft.x, topRight.x+1):
			for y in range(topLeft.y + 2, bottomLeft.y + 1):
				map[x][y] = Globals.Map.Hallway
				Walls.set_cell(x, y, -1)
				Floor.set_cell(x, y, 1)
				
		Walls.set_cell(bottomRight.x, bottomRight.y, Globals.WallTiles.BottomInnerRight)
		Walls.set_cell(bottomLeft.x, bottomLeft.y, Globals.WallTiles.BottomInnerLeft)
	return true
	
func findEmptySpace(height, width):
	print(height, width)
	var emptyLength = 0
	# Look for a spot in the row column array of empty spots
	for x in range(map.size()):
		for y in range(map[x].size()):
			if map[x][y] == -1:
				emptyLength += 1
				if emptyLength == height:
					if checkMapSquare(height, width, x, y):
						return Vector2(x, y)
					else:
						emptyLength = 0
			else:
				emptyLength = 0
	return null
	
# Given the bottom left of a room
# Checks for a spot in map large enough to hold the room.
# Starting from the top left and iterating through
func checkMapSquare(height, width, x, y):
		var endX = x + (width -1)
		var startY = y - (height-1)
		
		if endX < 0 || endX > map.size() - 1:
			return false
		if startY < 0 || startY > map[0].size() - 1:
			return false
		
		for xPos in range(x, endX):
			for yPos in range(startY, y):
				if map[xPos][yPos] != -1:
					return false
		return true

