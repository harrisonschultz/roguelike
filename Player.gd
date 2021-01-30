extends Unit

var visibleTiles = []
var FogMap 

func _init():
	actionAnimations = ["Idle", "Move", "Move"]
	animationDurations = [10, 0.3, 0.2]
	health = 10
	visionRange = 6
	identity = Globals.Things.Player
	defenses = { "physical": 0}
	actions = [{'speed': 25}, { "speed": 50 }, { "speed": 40 } ]
	attacks = {
		"basic": {
			"damage": [{ "type": "physical", "damage": 1}]
		}
	}

func _ready():
	FogMap = get_node("../Fog")
	setVision()

func _input(event):
	if actionsFinished:
		if event.is_action("Up"):
			move(Globals.Directions.Up)
			
		elif event.is_action("Left"):
			flip_h = true
			move(Globals.Directions.Left)
		
		elif event.is_action("Down"):
			move(Globals.Directions.Down)
		
		elif event.is_action("Right"):
			flip_h = false
			move(Globals.Directions.Right)
			
		#elif event.is_action("Wait"):
			#setAction(Action.wait)
				
func move(direction):
	destination = Movement.getDestTile(self, direction)
	if Movement.checkTileToMove(destination):
		setAction(Action.Move)
	else:
		var thing = Movement.whatIsOnTile(destination)
		if thing:
			if thing.identity == Globals.Things.Enemy:
				attack(direction, thing, 'basic')
				
func attack(direction, attackTarget, attack):
		chosenAttack = attack
		target = attackTarget
		previousPosition = self.position
		setAction(Action.Attack)
		
func setAction(act):
	.setAction(act)
	actionsFinished = false
	core.play()
	
func die():
	self.queue_free()
				
func setVision():
	if !destination:
		destination = Movement.worldToMap(self.position)
		
	var x = destination.x
	var y = destination.y 
	
	# Hide all shown tiles
	for point in visibleTiles:
		FogMap.set_cell(point.x, point.y, 0)
	
	# Reveal tile you are standing on
	FogMap.set_cell(x, y, -1)
	
	# Get vision.
	visibleTiles = vision.look(destination, visionRange)
	for point in visibleTiles:
		FogMap.set_cell(point.x, point.y, -1)
	
func finishedMove():
	setVision()
	actionsFinished = true
	animationFinished()
	finishTurn()

func finishedAttack():
	chosenAttack = null
	dealtDamage = false
	actionsFinished = true
	animationFinished()
	finishTurn()

