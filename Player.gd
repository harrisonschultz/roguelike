extends AnimatedSprite


enum State {Idle, Run}
const stateAnimations = ["Idle", "Run"]
const animationDuration = [10, 0.3]

var animationTimeElapsed: float = 0;
var isActing: bool = false
var moveAction = false
var movementSpeed: float = Globals.tile_size / animationDuration[State.Run]
var state = State.Idle
var destination
var Core

# Called when the node enters the scene tree for the first time.
func _ready():
	Core = get_node('../')

func _process(delta):
	animationTimeElapsed += delta
	if moveAction && animationTimeElapsed <  animationDuration[State.Run]:
		var distance = delta * movementSpeed
		if moveAction == "Up":
			Core.move(self, destination, 0, -distance)
		elif moveAction == "Left":
			Core.move(self, destination, -distance, 0)
		elif moveAction == "Down":
			Core.move(self, destination, 0, distance)
		elif moveAction == "Right":
			Core.move(self, destination, distance, 0)
	if state == State.Run && animationTimeElapsed > animationDuration[State.Run]:
		finished_move()
		moveAction = null
		changeState(State.Idle)

func _input(event):
	if state == State.Idle:
		if event.is_action("Up"):
			moveAction = "Up"
			getDestTile()
			if Core.checkTileToMove(destination):
				changeState(State.Run)
			
		elif event.is_action("Left"):
			flip_h = true
			moveAction = "Left"
			getDestTile()
			if Core.checkTileToMove(destination):
				changeState(State.Run)
		
		elif event.is_action("Down"):
			moveAction = "Down"
			getDestTile()
			if Core.checkTileToMove(destination):
				changeState(State.Run)
		
		elif event.is_action("Right"):
			flip_h = false
			moveAction = "Right"
			getDestTile()
			if Core.checkTileToMove(destination):
				changeState(State.Run)
			
func getDestTile():
	destination = self.position
	if moveAction == "Up":
		destination.y += -Globals.tile_size
	elif moveAction == "Left":
		destination.x += -Globals.tile_size
	elif moveAction == "Down":
		destination.y += Globals.tile_size
	elif moveAction == "Right":
		destination.x += Globals.tile_size
	destination.x = round(destination.x / Globals.tile_size)
	destination.y = round(destination.y / Globals.tile_size)
		
func changeState(newState):
	animationTimeElapsed = 0
	state = newState
	self.play(stateAnimations[newState])
	
func finished_move():
	# set the player position to the closest center of a tile
	# find nearest divisor of the tile_size
	self.position.x = round(self.position.x / Globals.tile_size) * Globals.tile_size
	self.position.y = round(self.position.y / Globals.tile_size) * Globals.tile_size

