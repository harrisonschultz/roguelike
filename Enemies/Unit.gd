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
var stateAnimations = ["Idle", "Run"]
var visionRange 

func _ready():
	Core = get_node('../')
	Walls = get_node("../Walls")
	vision = Vision.new(Walls)

func _init(details):
	animationDurations = details['animationDurations']
	stateAnimations = details['stateAnimations']
	visionRange = details['visionRange']
	movementSpeed = Globals.tile_size / animationDurations[State.Move]

func _process(delta):
	animationTimeElapsed += delta
	if moveAction && animationTimeElapsed < animationDurations[State.Move]:
		var distance = delta * movementSpeed
		if moveAction == "Up":
			Core.move(self, destination, 0, -distance)
		elif moveAction == "Left":
			Core.move(self, destination, -distance, 0)
		elif moveAction == "Down":
			Core.move(self, destination, 0, distance)
		elif moveAction == "Right":
			Core.move(self, destination, distance, 0)
	if state == State.Move && animationTimeElapsed > animationDurations[State.Move]:
		finished_move()
		moveAction = null
		changeState(State.Idle)

func changeState(newState):
	animationTimeElapsed = 0
	state = newState
	self.play(stateAnimations[newState])
	
func finished_move():
	# set the player position to the closest center of a tile
	# find nearest divisor of the tile_size
	self.position.x = round(self.position.x / Globals.tile_size) * Globals.tile_size
	self.position.y = round(self.position.y / Globals.tile_size) * Globals.tile_size
