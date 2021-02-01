extends Unit

var visibleTiles = []
var attributeNames = ['strength', 'agility']
var FogMap 
var isEnemyTurn = false
var experience = 0
var level = 1
var HealthBar
var maxHealth = 10
var levelThreshold = 0
var attributePoints = 0
var attributes = {
	"strength": 0,
	"agility": 0,
} 

func _init():
	levelThreshold = calculateLevelThreshold()
	actionAnimations = ["Idle", "Move", "Move"]
	animationDurations = [10, 0.3, 0.2]
	health = 10
	maxHealth = 10
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
	HealthBar = get_node("./Camera2D/HudLayer/Hud/HealthbarContainer/HealthGauge")
	setVision()
	updateStats()
	updateAttributes()
	
func setIsEnemyTurn(turn):
	isEnemyTurn = turn

func damageTaken():
	updateStats()
	
func updateStats():
	#print(health)
	#print(maxHealth)
	HealthBar.max_value = maxHealth
	HealthBar.value = health
	pass
	
func updateAttributes():
	pass
	for attr in attributeNames:
		var uiLabel = get_node("Camera2D/HudLayer/CharacterSheet/MarginContainer/VBoxContainer/StatsContainer/Stats/" + attr + "Container/" + attr + "Value")
		uiLabel.text = str(attributes[attr])
	
func addAttribute(attr, value):
	attributes[attr] += value
	updateAttributes()
	if attr == 'strength':
		calculateMaxHealth()
		heal(value)
		updateStats()

func heal(value):
	var newHealthValue = health + value
	if newHealthValue > maxHealth:
		newHealthValue = maxHealth
	health = newHealthValue 

func calculateMaxHealth():
	maxHealth = 10 + attributes['strength']

func _input(event):
	if actionsFinished && !isEnemyTurn:
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
	core.playPlayerTurn()

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
		
func finishTurn():
	.finishTurn()
	core.playEnemyTurn()
	
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
	
func calculateLevelThreshold():
	return 1 * level
	
func levelUp():
	if experience >= levelThreshold:
		experience -= levelThreshold
		level += 1
		levelThreshold = calculateLevelThreshold()
		attributePoints += 3
		# if there recevied enough exp at once to level more than once.
		levelUp()
	
func receiveExperience(receivedExperience):
	experience += receivedExperience
	levelUp()

func receive(awards):
	if awards['experience']:
		receiveExperience(awards['experience'])
	

func _on_StrPlus_pressed():
	addAttribute('strength', 1)


func _on_AgiPlus_pressed():
	addAttribute('agility', 1)
