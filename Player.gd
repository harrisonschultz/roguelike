extends Unit

var InventoryItem = preload("res://InventoryItem.tscn")

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
var gold = 0
var inventory = []
var inventoryNode
var attributes = {
	"strength": 0,
	"agility": 0,
} 
var equipment = {
	Globals.EquipmentType.MainHand: null,
	Globals.EquipmentType.OffHand: null,
	Globals.EquipmentType.Head: null,
	Globals.EquipmentType.Chest: null,
	Globals.EquipmentType.Pants: null,
	Globals.EquipmentType.Ranged: null,
	Globals.EquipmentType.LeftRing: null,
	Globals.EquipmentType.RightRing: null,
}

var equipmentNode = {
	Globals.EquipmentType.MainHand: null,
	Globals.EquipmentType.OffHand: null,
	Globals.EquipmentType.Head: null,
	Globals.EquipmentType.Chest: null,
	Globals.EquipmentType.Pants: null,
	Globals.EquipmentType.Ranged: null,
	Globals.EquipmentType.LeftRing: null,
	Globals.EquipmentType.RightRing: null,
}

func _init():
	levelThreshold = calculateLevelThreshold()
	actionAnimations = ["Idle", "Move", "Move"]
	animationDurations = [10, 0.3, 0.2]
	health = 10
	maxHealth = 10
	visionRange = 6
	identity = Globals.Things.Player
	defenses = { Globals.DamageType.Physical: 0 }
	attacks = {
		"basic": {
			"damage": [{ "type": Globals.DamageType.Physical, "damage":[1,1]}]
		}
	}
	
func removeFromInventory(item):
	for i in range(inventory.size()):
		if inventory[i].get_instance_id() == item.get_instance_id():
			inventory.remove(i)
			inventoryNode.remove_child(item)
	
func addToInventory(item):
	inventory.append(item)
	var inventoryItem = InventoryItem.instance()
	inventoryItem.init(item.details)
	inventoryNode.add_child(inventoryItem)
	
	
func _ready():
	FogMap = get_node("../Fog")
	HealthBar = get_node("./Camera2D/HudLayer/Hud/HealthbarContainer/HealthGauge")
	inventoryNode = get_node("./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/RightSide/InventoryBackground/Inventory")
	equipmentNode[Globals.EquipmentType.MainHand] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/MainHand/Item')
	equipmentNode[Globals.EquipmentType.OffHand] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/OffHand/Item')
	equipmentNode[Globals.EquipmentType.Head] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/Head/Item')
	equipmentNode[Globals.EquipmentType.Chest] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/Chest/Item')
	equipmentNode[Globals.EquipmentType.Ranged] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/Ranged/Item')
	equipmentNode[Globals.EquipmentType.Pants] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/Pants/Item')
	equipmentNode[Globals.EquipmentType.LeftRing] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/LeftRing/Item')
	equipmentNode[Globals.EquipmentType.RightRing] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/Character/Equipment/RightRing/Item')
	updateStats()
	updateAttributes()
	
func setIsEnemyTurn(turn):
	isEnemyTurn = turn

func damageTaken():
	updateStats()
	
func unequip(item):
	addToInventory(equipment[item.equipmentType])
	equipmentNode[item.equipmentType].texture = null
	
func equipItem(item):
	if equipment[item.equipmentType]:
		unequip(equipment[item.equipmentType])
	equipment[item.equipmentType] = item
	equipmentNode[item.equipmentType].texture = item.image
	removeFromInventory(item)

func updateStats():
	HealthBar.max_value = maxHealth
	HealthBar.value = health
	
func updateAttributes():
	for attr in attributeNames:
		var uiLabel = get_node("Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/StatsContainer/Stats/" + attr + "Container/" + attr + "Value")
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
	var vantagePoint = destination
	if !destination:
		vantagePoint = Movement.worldToMap(self.position)
		
	var x = vantagePoint.x
	var y = vantagePoint.y 
	
	# Hide all shown tiles
	for point in visibleTiles:
		FogMap.set_cell(point.x, point.y, 0)
	
	# Reveal tile you are standing on
	FogMap.set_cell(x, y, -1)
	
	# Get vision.
	visibleTiles = vision.look(vantagePoint, visionRange)
	for point in visibleTiles:
		FogMap.set_cell(point.x, point.y, -1)
		
func finishTurn():
	.finishTurn()
	core.playEnemyTurn()
	
func finishedMove():
	setVision()
	actionsFinished = true
	.finishedMove()

func finishedAttack():
	chosenAttack = null
	actionsFinished = true
	.finishedAttack()
	
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
