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
	
	
	if moveAction && animationTimeElapsed < animationDurations[State.Move]:
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
	print('Unit step')
	var action = determineAction()
	
func findPathToPlayer():
	var astar = AStar2D.new()
	var visibleTiles = []
	var pos = positionToTile(self.position)
	# Loop through all tiles in vision range
	# Determine if it is a walkable tile
	for octant in 8:
		for y in range(1, visionRange):
			var horizontalRange = y + 1
			if horizontalRange == visionRange:
				horizontalRange -= 2
			for x in horizontalRange:
				# Skip the last value on each odd octant
				if !(octant % 2) && (x == y || x == 0):
					continue
				var position = pos + vision.transformOctant(x, y, octant)
				if Core.checkTileToMove(position):
					visibleTiles.append(position)
					astar.add_point(positionToId(position),Vector2(position.x, position.y), 1)
					
	# Determine if player is standing on a tile in aggro range
	var tilePlayerPosition = positionToTile(player.position)
	var myPosition = positionToTile(self.position)
	for tile in visibleTiles:
		if tile == tilePlayerPosition:
			lastKnownPlayerPosition = tilePlayerPosition
			break;
	if lastKnownPlayerPosition: 
		astar.connect_points(positionToId(myPosition), positionToId(lastKnownPlayerPosition))
		var points = astar.get_points()
		return astar.get_point_path(positionToId(myPosition), positionToId(lastKnownPlayerPosition))
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
