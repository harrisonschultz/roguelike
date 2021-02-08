extends Unit

var InventoryItem = preload("res://InventoryItem.tscn")

const INVENTORY_SIZE = 16
const INPUT_DELAY = 0.1

var inputWait = 0
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
var inventory 
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

var equipmentNodeParent = {
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
			"damage": [{ "type": Globals.DamageType.Physical, "damage":[1,1]}],
			"type": Globals.AttackType.Melee
		}
	}
	
func setUnarmed(): 
	attacks['basic'] = {
		"damage": [{ "type": Globals.DamageType.Physical, "damage":[1,1]}],
		"type": Globals.AttackType.Melee
	}

func addDefenses(item):
	for i in item['details']['defenses']:
		defenses[i] += item['details']['defenses'][i]

func removeDefenses(item):
	for i in item['details']['defenses']:
		defenses[i] -= item['details']['defenses'][i]
	
func removeFromInventory(item):
	var itemsInInventory = inventory.get_children()
	for i in range(itemsInInventory.size()):
		if itemsInInventory[i].get_instance_id() == item.get_instance_id():
			inventory.remove_child(item)
			
func convertToInventoryItem(item):
	var inventoryItem = InventoryItem.instance()
	inventoryItem.init(item.details)
	return inventoryItem
	
func addToInventory(item):
	if checkForSpace():
		inventory.add_child(item)
	
func checkForSpace():
	return inventory.get_child_count() < INVENTORY_SIZE
	
func _ready():
	FogMap = get_node("../Fog")
	HealthBar = get_node("./Camera2D/HudLayer/Hud/HealthbarContainer/HealthGauge")
	inventory = get_node("./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/RightSide/InventoryBackground/MarginContainer/Inventory")
	equipmentNodeParent[Globals.EquipmentType.MainHand] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/MainHand')
	equipmentNodeParent[Globals.EquipmentType.OffHand] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/OffHand')
	equipmentNodeParent[Globals.EquipmentType.Ranged] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/Ranged')
	equipmentNodeParent[Globals.EquipmentType.Head] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/Head')
	equipmentNodeParent[Globals.EquipmentType.Chest] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/Chest')
	equipmentNodeParent[Globals.EquipmentType.Hands] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/Hands')
	equipmentNodeParent[Globals.EquipmentType.Pants] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/Pants')
	equipmentNodeParent[Globals.EquipmentType.LeftRing] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/LeftRing')
	equipmentNodeParent[Globals.EquipmentType.RightRing] = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/CharacterContainer/CenterContainer/Equipment/RightRing')
	updateStats()
	updateAttributes()
	
func setIsEnemyTurn(turn):
	isEnemyTurn = turn

func damageTaken():
	updateStats()
	
func removeFromEquipment(item):
	equipmentNodeParent[item.equipmentType].remove_child(item)
	
func unequip(item):
	if checkForSpace():
		removeFromEquipment(item)
		addToInventory(item)
		item.equipped = false
		if item.equipmentType == Globals.EquipmentType.MainHand:
			setUnarmed()
		elif item.equipmentType == Globals.EquipmentType.Chest:
			removeDefenses(item)
	
	
func equipItem(item):
	if equipment[item.equipmentType]:
		unequip(equipment[item.equipmentType])
	removeFromInventory(item)
	item.equipped = true
	equipment[item.equipmentType] = item
	item.rect_position = Vector2(0,0)
	equipmentNodeParent[item.equipmentType].add_child(item)
	
	if item.equipmentType == Globals.EquipmentType.MainHand:
		setAttacks()
	if item.equipmentType == Globals.EquipmentType.Chest:
		addDefenses(item)
			
func setAttacks():
	attacks['basic'] = equipment[Globals.EquipmentType.MainHand]['details']['basic']
		
func updateStats():
	HealthBar.max_value = maxHealth
	HealthBar.value = health
	
func updateAttributes():
	for attr in attributeNames:
		var freePointsLabel = get_node('./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/StatsContainer/VBoxContainer/HBoxContainer/points')
		var uiLabel = get_node("./Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/StatsContainer/VBoxContainer/Stats/" + attr + "Container/" + attr + "Value")
		uiLabel.text = str(attributes[attr])
		freePointsLabel.text = str(attributePoints)
	
func addAttribute(attr, value):
	if attributePoints > 0:
		attributePoints -= value
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
	
func isValidAction(event):
	if event.is_action("Up"):
		return true
	elif event.is_action("Left"):
		return true
	elif event.is_action("Down"):
		return true
	elif event.is_action("Right"):
		return true
	return false

func _input(event):
	if actionsFinished && !isEnemyTurn && isValidAction(event) && inputWait > INPUT_DELAY:
		inputWait = 0
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
	isEnemyTurn = core.checkForEnemyTurnFinished()

func finishedAttack():
	chosenAttack = null
	actionsFinished = true
	.finishedAttack()
	isEnemyTurn = core.checkForEnemyTurnFinished()
	
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
		updateAttributes()
	
func receiveExperience(receivedExperience):
	experience += receivedExperience
	levelUp()

func receive(awards):
	if awards['experience']:
		receiveExperience(awards['experience'])
	
func _process(delta):
	inputWait += delta

func _on_StrPlus_pressed():
	addAttribute('strength', 1)

func _on_AgiPlus_pressed():
	addAttribute('agility', 1)
