extends AnimatedSprite

enum State { Idle, Move, Attack }
const stateAnimations = ["Idle", "Move", "Move"]
const animationDuration = [10, 0.3, 0.2]

var animationTimeElapsed: float = 0;
var isActing: bool = false
var moveAction = false
var movementSpeed: float = Globals.tile_size / animationDuration[State.Move]
var state = State.Idle
var destination
var Core
var fogMap = []
var visionRange = 6
var FogMap 
var MainCamera
var Walls
var calledStepForLastAction = false
var vision
var identity = Globals.Things.Player
var previousPosition = null
var target
var health = 10
var dealtDamage
var chosenAttack
var defenses = { "physical": 0}
var attacks = {
	"basic": {
		"damage": [{ "type": "physical", "damage": 1}]
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Core = get_node('../')
	MainCamera = get_node("Camera2D")
	FogMap = get_node("../Fog")
	Walls = get_node("../Walls")
	vision = Vision.new(Walls)
	self.play('Idle')

func _process(delta):
	animationTimeElapsed += delta
	if state == State.Move && moveAction != null && animationTimeElapsed < animationDuration[State.Move]:
		var distance = delta * movementSpeed
		if moveAction == "Up":
			Core.move(self, destination, Vector2(0, -distance))
		elif moveAction == "Left":
			Core.move(self, destination, Vector2( -distance, 0))
		elif moveAction == "Down":
			Core.move(self, destination, Vector2(0, distance))
		elif moveAction == "Right":
			Core.move(self, destination, Vector2(distance, 0))
	if state == State.Move && animationTimeElapsed > animationDuration[State.Move]:
		finishedMove()
	if state == State.Attack && moveAction != null && animationTimeElapsed < animationDuration[State.Attack]:
		var distance = delta * movementSpeed
		var pastHalf = animationTimeElapsed > animationDuration[State.Attack] /2
		if pastHalf && !dealtDamage:
			dealDamage()
		if moveAction == "Up":
			if (pastHalf):
				Core.move(self, destination, Vector2(0, distance))
			else:
				Core.move(self, destination, Vector2(0, -distance))
		elif moveAction == "Left":
			if (pastHalf):
				Core.move(self, destination, Vector2( distance, 0))
			else:
				Core.move(self, destination, Vector2( -distance, 0))
		elif moveAction == "Down":
			if (pastHalf):
				Core.move(self, destination,  Vector2(0, -distance))
			else:
				Core.move(self, destination,  Vector2(0, distance))
		elif moveAction == "Right":
			if (pastHalf):
				Core.move(self, destination, Vector2(-distance, 0))
			else:
				Core.move(self, destination, Vector2(distance, 0))
	if state == State.Attack && animationTimeElapsed > animationDuration[State.Attack]:
		finishedAttack()
		
func performAction():
	if !calledStepForLastAction:
		Core.step()
		calledStepForLastAction = true
		
func dealDamage():
	Core.combat(self, attacks[chosenAttack], target)
	dealtDamage = true

func _input(event):
	if state == State.Idle && !moveAction:
		if event.is_action("Up"):
			move("Up")
			
		elif event.is_action("Left"):
			flip_h = true
			move("Left")
		
		elif event.is_action("Down"):
			move("Down")
		
		elif event.is_action("Right"):
			flip_h = false
			move("Right")
				
func move(direction):
	getDestTile(direction)
	if Core.checkTileToMove(destination):
		moveAction = direction
		changeState(State.Move)
	else:
		var thing = Core.whatIsOnTile(destination)
		if thing.identity == Globals.Things.Enemy:
			# attack	
			attack(direction, thing, 'basic')
				
func attack(direction, attackTarget, attack):
		chosenAttack = attack
		target = attackTarget
		moveAction = direction
		previousPosition = self.position
		changeState(State.Attack)

func die():
	self.queue_free()
				
func step():
	if !calledStepForLastAction:
		if !destination:
			destination = Vector2(round(self.position.x / Globals.tile_size),round(self.position.y / Globals.tile_size))
		var x = destination.x
		var y = destination.y 
		
		# Hide all shown tiles
		for point in fogMap:
			FogMap.set_cell(point.x, point.y, 0)
		
		# Get vision.
		FogMap.set_cell(x, y, -1)
		fogMap = vision.look(Vector2(x, y), visionRange)
		for point in fogMap:
			FogMap.set_cell(point.x, point.y, -1)
	
			
func getDestTile(direction):
	destination = self.position
	if direction == "Up":
		destination.y += -Globals.tile_size
	elif direction == "Left":
		destination.x += -Globals.tile_size
	elif direction == "Down":
		destination.y += Globals.tile_size
	elif direction == "Right":
		destination.x += Globals.tile_size
	destination.x = round(destination.x / Globals.tile_size)
	destination.y = round(destination.y / Globals.tile_size)
		
func changeState(newState):
	animationTimeElapsed = 0
	state = newState
	self.play(stateAnimations[newState])
	
func finishedMove():
	moveAction = null
	# set the player position to the closest center of a tile
	# find nearest divisor of the tile_size
	self.position.x = round(self.position.x / Globals.tile_size) * Globals.tile_size
	self.position.y = round(self.position.y / Globals.tile_size) * Globals.tile_size
	calledStepForLastAction = false
	changeState(State.Idle)
	performAction()

func finishedAttack():
	chosenAttack = null
	dealtDamage = false
	moveAction = null
	# set the player position to the closest center of a tile
	# find nearest divisor of the tile_size
	self.position = previousPosition
	calledStepForLastAction = false
	changeState(State.Idle)
	performAction()

