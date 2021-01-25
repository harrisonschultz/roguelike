extends AnimatedSprite


enum State { Idle, Run }
const stateAnimations = ["Idle", "Run"]
const animationDuration = [10, 0.3]

var animationTimeElapsed: float = 0;
var isActing: bool = false
var moveAction = false
var movementSpeed: float = Globals.tile_size / animationDuration[State.Run]
var state = State.Idle
var destination
var Core
var fogMap = []
var visionRange = 4
var FogMap 
var MainCamera
var Walls
var calledStepForLastAction = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Core = get_node('../')
	MainCamera = get_node("Camera2D")
	FogMap = get_node("../Fog")
	Walls = get_node("../Walls")

func _process(delta):
	animationTimeElapsed += delta
	if moveAction && animationTimeElapsed <  animationDuration[State.Run]:
		var distance = delta * movementSpeed
		if moveAction == "Up":
			Core.move(self, destination, 0, -distance)
			performAction()
			Core.step()
		elif moveAction == "Left":
			Core.move(self, destination, -distance, 0)
			performAction()
		elif moveAction == "Down":
			Core.move(self, destination, 0, distance)
			performAction()
		elif moveAction == "Right":
			Core.move(self, destination, distance, 0)
			performAction()
	if state == State.Run && animationTimeElapsed > animationDuration[State.Run]:
		finished_move()
		moveAction = null
		changeState(State.Idle)
		
func performAction():
	if !calledStepForLastAction:
		Core.step()
		calledStepForLastAction = true

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
		fogMap = Vision.look(Vector2(x, y), visionRange, Walls)
		for point in fogMap:
			FogMap.set_cell(point.x, point.y, -1)

		
	
	
			
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
	calledStepForLastAction = false


