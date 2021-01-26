extends AnimatedSprite

class_name Unit

enum State { Idle, Move }

var animationTimeElapsed: float = 0;
var isActing: bool = false
var moveAction = null
var movementSpeed: float
var state = State.Idle
var destination
var Core
var Walls
var vision
var animationDurations
var stateAnimations
var visionRange
var attackRange
var player
var lastKnownPlayerPosition
var lastWanderMove = 0

func _ready():
	var Root = get_tree().get_root()
	Core = Root.get_node("Root")
	Walls = Core.get_node("Walls")
	player = Core.get_node("Player")
	vision = Vision.new(Walls)

func init(details, position):
	self.position.x = round(position.x / Globals.tile_size) * Globals.tile_size
	self.position.y = round(position.y / Globals.tile_size) * Globals.tile_size
	animationDurations = details['animationDurations']
	stateAnimations = details['stateAnimations']
	attackRange = details['attackRange']
	visionRange = details['visionRange']
	movementSpeed = Globals.tile_size / animationDurations[State.Move]

func getDestTile():
	destination = self.position
	if moveAction == Globals.Directions.Up:
		destination.y += -Globals.tile_size
	elif moveAction == Globals.Directions.Left:
		destination.x += -Globals.tile_size
	elif moveAction == Globals.Directions.Down:
		destination.y += Globals.tile_size
	elif moveAction == Globals.Directions.Right:
		destination.x += Globals.tile_size
	destination.x = round(destination.x / Globals.tile_size)
	destination.y = round(destination.y / Globals.tile_size)

func _process(delta):
	animationTimeElapsed += delta
	if moveAction != null && animationTimeElapsed < animationDurations[State.Move]:
		var distance = delta * movementSpeed
		if moveAction == Globals.Directions.Up:
			Core.move(self, destination,Vector2( 0, -distance))
		elif moveAction == Globals.Directions.Left:
			self.flip_h = true
			Core.move(self, destination, Vector2(-distance, 0))
		elif moveAction == Globals.Directions.Down:
			Core.move(self, destination, Vector2(0, distance))
		elif moveAction == Globals.Directions.Right:
			self.flip_h = false
			Core.move(self, destination, Vector2(distance, 0))
	if state == State.Move && animationTimeElapsed > animationDurations[State.Move]:
		finished_move()
		moveAction = null
		changeState(State.Idle)
		

func step():
	var action = determineAction()
	
func findPathToPlayer():
	var astar = AStar2D.new()
	var visibleTiles = []
	var myPosition = positionToTile(self.position)
	var visionVector = Vector2(visionRange, visionRange)
	var visionTopLeft = myPosition - visionVector
	
	# Add additional point for self position
	var visionBottomRight = myPosition + visionVector + Vector2(1,1)
	
	# Loop through all tiles in vision range
	# Determine if it is a walkable tile
	for y in range(visionTopLeft.y, visionBottomRight.y):
		for x in range(visionTopLeft.x, visionBottomRight.x):
			var position =  Vector2(x,y)
			if Core.checkTileToMove(position):
				visibleTiles.append(position)
				astar.add_point(positionToId(position), position, 1)
			else:
				visibleTiles.append(null)
					
	var tilePlayerPosition = positionToTile(player.position)
	for index in range(visibleTiles.size()):
		var tile = visibleTiles[index]
		# Determine if player is standing on a tile in aggro range
		if tile == tilePlayerPosition:
			lastKnownPlayerPosition = tilePlayerPosition
			break;
			
	# find path to player if player is in aggro range
	if lastKnownPlayerPosition: 
		for index in range(visibleTiles.size()):
			var tile = visibleTiles[index]
			
			# if invalid tile skip
			if !tile:
				continue
			
			# Connect a point to all of its neighbors in cardinal directions
			var id = positionToId(tile)
			var rowLength = (visionRange * 2 + 1)
			# Add Up
			if index - rowLength > 0 && visibleTiles[index - rowLength] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index - rowLength]))
			# Add Right
			if (index + 1) % rowLength != 0 && index + 1 < visibleTiles.size() && visibleTiles[index + 1] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index + 1]))
			# Add Left
			if (index - 1) % rowLength != 0 && index - 1 > -1 && visibleTiles[index - 1] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index - 1]))
			# Add down
			if index + rowLength < visibleTiles.size() && visibleTiles[index + rowLength] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index + rowLength]))
			
		var path = astar.get_point_path(positionToId(myPosition), positionToId(lastKnownPlayerPosition))
		return path
	else:
		return null
		
func positionToId(pos: Vector2):
	return int(str(pos.x) + str(pos.y))
	
			
func positionToTile(pos: Vector2):
	var x = round(pos.x / Globals.tile_size)
	var y = round(pos.y / Globals.tile_size)
	return Vector2(x,y)
		
func determineAction():
	var pathToPlayer = findPathToPlayer()
	if pathToPlayer:
		var adjacent = pathToPlayer.size() <= 1
		if !adjacent:
			move(pathToPlayer[1])
	else:
		wander()
	
func wander():
	if lastWanderMove > 3:
		# Choose a random direction to move
		var direction = Globals.rng.randi_range(0, Globals.directionsArray.size() - 1)
		moveAction = Globals.directionsArray[direction]
		getDestTile()
		changeState(State.Move)
	else:
		lastWanderMove += 1
		
func determineMoveDirection(destination):
	var pos = positionToTile(self.position)
	if pos.y > destination.y:
		return Globals.Directions.Up
	elif pos.x < destination.x:
		return Globals.Directions.Right
	elif pos.y < destination.y:
		return Globals.Directions.Down
	elif pos.x > destination.x:
		return Globals.Directions.Left
	

func move(destination):
	moveAction = determineMoveDirection(destination)
	var now = positionToTile(self.position)
	getDestTile()
	changeState(State.Move)
	

func changeState(newState):
	animationTimeElapsed = 0
	state = newState
	self.play(stateAnimations[newState])
	
func finished_move():
	# set the player position to the closest center of a tile
	# find nearest divisor of the tile_size
	self.position.x = round(self.position.x / Globals.tile_size) * Globals.tile_size
	self.position.y = round(self.position.y / Globals.tile_size) * Globals.tile_size
