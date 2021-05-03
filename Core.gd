extends Node

var Floor
var Walls
var Player
var DebugTileMap
var rooms = []
var map = []
var EnemyRoot
var ItemRoot
var PropRoot
var FogMap
var step = 0
var stepLabel
var Maps
var turnQueue = []
var actionCount = 0
var inputDelay = 0
const wallsWithCollision = [7,8,14,15]
const MIN_ROOM_SIZE = 8
const MAX_ROOM_SIZE = 12
const EXIT_SIZE = 5

var Slime = load("res://Enemies/Slime/Slime.tscn")
var MapClass = preload('res://Map.gd')

func _ready():
	OS.set_window_size(Vector2(1280, 720))
	Globals.rng.randomize()
	Floor = get_node("Floor")
	Walls = get_node("Walls")
	FogMap = get_node("Fog")
	DebugTileMap = get_node("Debug")
	Player = get_node('Player')
	EnemyRoot = get_node("EnemyRoot")
	ItemRoot = get_node("ItemRoot")
	PropRoot = get_node("PropRoot")
	Maps = MapClass.new()
	Maps.init(Floor, Walls, FogMap, EnemyRoot, ItemRoot, PropRoot, DebugTileMap)
	Maps.loadLevel()
	Player.position = Vector2(240,240)
	Player.setVision()
		
func _input(event):
	if inputDelay > 0.15:
		inputDelay = 0
		if event.is_action('reset'):
			Maps.reloadLevel()
		if event.is_action('C') :
			showCharacterSheet()
		
func _process(delta):
	inputDelay += delta
	
func playPlayerTurn():
	Player.takeTurn()
		
func playEnemyTurn():
	var units = EnemyRoot.get_children()
	for unit in units:
		if unit.exists:
			unit.takeTurn()
		
func finishEnemyTurn():
	# Allow player to act.
	Player.setIsEnemyTurn(checkForEnemyTurnFinished())

func checkForEnemyTurnFinished():
	var isTakingTurn = false
	var units = EnemyRoot.get_children()
	for unit in units:
		if unit.takingTurn == true && unit.inCombat && !unit.stunned:
			isTakingTurn = true
			break
	return isTakingTurn	

func finishedActions():
	var nodes = EnemyRoot.get_children()
	Player.step()
	for node in nodes:
		node.step()

	
func combat(source, attack, victim):
	var totalDamage = 0
	for damages in attack['damage']:
		var chosenDamage = Globals.rng.randi_range(damages['damage'][0], damages['damage'][1])
		
		# Add Bonuses
		if 'type' in attack && attack['type'] == Globals.AttackType.Melee:
			if source.attributes:
				chosenDamage += source.attributes['strength']
		var defense = 0 
		if damages['type'] in victim.defenses:
			defense = victim.defenses[damages['type']]
		var damageTaken = round(chosenDamage - defense)
		if damageTaken < 0:
			damageTaken = 0
		totalDamage += damageTaken
		
	victim.health -= totalDamage
	if totalDamage > 0:
		victim.damageTaken()
	
	if victim.health <= 0:
		victim.die()
		
func getDamageRange(source, attack, type = null):
	var damageRange = [0, 0]
	
	for damages in attack['damage']:
		if !type || (type && type == damages['type']):
			damageRange[0] += damages['damage'][0]
			damageRange[1] += damages['damage'][1]
			var chosenDamage = Globals.rng.randi_range(damages['damage'][0], damages['damage'][1])
			
			# Add Bonuses
			if 'type' in attack && attack['type'] == Globals.AttackType.Melee && damages['type'] == Globals.DamageType.Physical:
				if source.attributes:
					damageRange[0] += source.attributes['strength']
					damageRange[1] += source.attributes['strength']
	
	return damageRange
				
func getRandomDamage(source, attack):
	var damageRange = getDamageRange(source, attack)
	return Globals.rng.randi_range(damageRange[0], damageRange[1])
		
func activateFloorInteractables(node: Unit):
	for item in ItemRoot.get_children():
		if node.identity == Globals.Things.Player:
			if item.identity == Globals.Things.Gold:
				item.activate(node)
				
func showCharacterSheet():
	var hud = get_node("Player/Camera2D/HudLayer/Hud")
	var characterSheet = get_node("Player/Camera2D/HudLayer/CharacterSheet")
	hud.visible = characterSheet.visible;
	characterSheet.visible = !characterSheet.visible

func _on_Button_pressed():
	get_node("Player/Camera2D/HudLayer/Hud").visible = false;
	get_node("Player/Camera2D/HudLayer/CharacterSheet").visible = true;
	
func _on_ExitCharacterSheet_pressed():
	get_node("Player/Camera2D/HudLayer/Hud").visible = true;
	get_node("Player/Camera2D/HudLayer/CharacterSheet").visible = false

func loadAbility(ability: String):
	return load("res://Abilities/" + ability + ".tscn")		

func performAbility(abilityName: String, source, target):
		var abilityScene = loadAbility(abilityName)
		var ability = abilityScene.instance()
		ability.init(source, target)
		self.add_child(ability)
		ability.play()
