extends Unit

var InventoryItem = preload("res://InventoryItem.tscn")

const INVENTORY_SIZE = 16
const INPUT_DELAY = 0.1
const hudLeft = './Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/LeftSide/'
const hudRight = './Camera2D/HudLayer/CharacterSheet/Page/PageRows/InnerPage/PageColumns/RightSide/'
const equipmentUi = hudLeft + 'CharacterContainer/CenterContainer/Equipment/'
const details = hudRight + 'Details/'
const inventoryUi = hudRight + "InventoryBackground/MarginContainer/Inventory/"

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
var enemyClickAction = "Engulf"
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
	animationDurations = [10, 0.2, 0.2]
	health = 10
	maxHealth = 10
	visionRange = 6
	identity = Globals.Things.Player
	#Physical, Fire, Water, Holy, Arcane, Dark
	defenses = { Globals.DamageType.Physical: 0, Globals.DamageType.Fire: 0, Globals.DamageType.Water: 0, Globals.DamageType.Arcane: 0, Globals.DamageType.Holy: 0, Globals.DamageType.Unholy: 0}
	attacks = {
		"basic": {
			"damage": [{ "type": Globals.DamageType.Physical, "damage": [1,1] }],
			
			"type": Globals.AttackType.Melee
		}
	}
	
func setUnarmed(): 
	attacks['basic'] = {
		"damage": [{ "type": Globals.DamageType.Physical, "damage":[1,1] }],
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
		

		
func onEnemyClick(enemy: Enemy):
	if enemyClickAction: 
		core.performAbility(enemyClickAction, self, enemy)

func checkForSpace():
	return inventory.get_child_count() < INVENTORY_SIZE
	
func _ready():
	FogMap = get_node("../Fog")
	HealthBar = get_node("./Camera2D/HudLayer/Hud/Hud/HealthbarContainer/HealthGauge")
	inventory = get_node(inventoryUi)
	
	for i in Globals.EquipmentType: 
		equipmentNodeParent[i] = get_node(equipmentUi + i)

	updateSheet()
	
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
	updateSheet()
			
func setAttacks():
	attacks['basic'] = equipment[Globals.EquipmentType.MainHand]['details']['basic']
		
func updateStats():
	HealthBar.max_value = maxHealth
	HealthBar.value = health
	
func updateSheet(): 
	updateStats()
	updateAttributes()
	updateDetails()
	
func updateAttributes():
	for attr in attributeNames:
		var freePointsLabel = get_node(hudLeft + 'StatsContainer/VBoxContainer/HBoxContainer/points')
		var uiLabel = get_node(hudLeft + "StatsContainer/VBoxContainer/Stats/" + attr + "Container/" + attr + "Value")
		uiLabel.text = str(attributes[attr])
		freePointsLabel.text = str(attributePoints)
	
func updateDetails():
	var damage = get_node(details + 'row1/left/totalDamage/valueP/value')
	var totalDamageMin = 0
	var totalDamageMax = 0
	
	# Attack
	for i in Globals.DamageType.keys():
		var value_node = get_node(details + 'row1/left/Sub/' + i + '/Label')
		var damageRange = core.getDamageRange(self, attacks['basic'], i)
		value_node.text = str(damageRange[0]) + " - " + str(damageRange[1])
		totalDamageMin += damageRange[0]
		totalDamageMax += damageRange[1]
	
	# Defense 	
	for i in Globals.DamageType.keys():
		var value_node = get_node(details + 'row1/right/Sub/' + i + '/Label')
		value_node.text = str(defenses[i])
		
	damage.text = str(totalDamageMin) + " - " + str(totalDamageMax)
			
			
func findDamageType(dmgArray, damageType): 
	print(dmgArray)
	print(damageType)
	for i in dmgArray:
		if i['type'] == damageType:
			return i['damage']
	return null
	
func addAttribute(attr, value):
	if attributePoints > 0:
		attributePoints -= value
		attributes[attr] += value
		if attr == 'strength':
			calculateMaxHealth()
			heal(value)
	updateSheet()

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
			if thing.identity == Globals.Things.Enemy && thing.isCollidable():
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
