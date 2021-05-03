extends AnimatedSprite

class_name Unit

enum Action { Idle, Move, Attack, Death }

var animationTimeElapsed: float = 0;
var action = Action.Idle
var destination
var core
var walls
var vision
var animationDurations
var actionAnimations
var visionRange
var attackRange
var exists = true
var stunned = false
var lastKnownPlayerPosition
var previousPosition
var actionsFinished = true
var defenses
var health
var attacks
var dealtDamage
var chosenAttack
var target
var identity
var takingTurn := false
var actions = [{'speed': 25}, { "speed": 50 }, { "speed": 40 } ]
var inCombat = false
var debuffs = []

func _ready():
	var root = get_tree().get_root()
	core = root.get_node("Root")
	walls = core.get_node("Walls")
	vision = Vision.new(walls)

func init(details, position):
	self.position = Movement.mapToWorld(position)
	animationDurations = details['animationDurations']
	actionAnimations = details['actionAnimations']
	attackRange = details['attackRange']
	visionRange = details['visionRange']
	defenses = details['defenses']
	health = details['health']
	attacks = details['attacks']
	
func addDebuff(debuff):
	debuffs.append(debuff)

func _process(delta):
	animationTimeElapsed += delta
	if action == Action.Death:
		if animationTimeElapsed >= animationDurations[Action.Death]:
			finishedDeath()
				
	if takingTurn and !stunned:
		# Movement
		if action == Action.Move:
			if animationTimeElapsed < animationDurations[Action.Move]:
				var distance = delta * Globals.tile_size / float(animationDurations[Action.Move])
				Movement.move(self, destination, distance)
			else:
				finishedMove()
		
		# Attacking
		if action == Action.Attack:
			if animationTimeElapsed < animationDurations[Action.Attack]:
				var distance = delta * Globals.tile_size / float(animationDurations[Action.Attack])
				var animationDamagePoint = animationTimeElapsed > float(animationDurations[Action.Attack]) / 2
				
				if animationDamagePoint && !dealtDamage:
					dealDamage()
					
				if animationDamagePoint:
					Movement.move(self, Movement.worldToMap(self.position), distance)
				else:
					Movement.move(self, destination, distance)
			else:
				finishedAttack()
				
		
		
func die():
	stunned = true
	setCollidable(false)
	setAction(Action.Death)
	setAnimation(actionAnimations[action])
	
	
func setCollidable(collide: bool):
	exists = collide
	
func isCollidable():
	return exists
	
func finishedDeath():
	self.queue_free()
	
func findPathToNode(goal):
	var astar = AStar2D.new()
	var visibleTiles = []
	var myPosition = Movement.worldToMap(self.position)
	var visionVector = Vector2(visionRange, visionRange)
	var visionTopLeft = myPosition - visionVector
	var tileGoalPosition = Movement.worldToMap(goal.position)
	var target = null
	
	# Add additional point for self position
	var visionBottomRight = myPosition + visionVector + Vector2(1,1)
	
	# Loop through all tiles in vision range
	# Determine if it is a walkable tile
	for y in range(visionTopLeft.y, visionBottomRight.y):
		for x in range(visionTopLeft.x, visionBottomRight.x):
			var position = Vector2(x,y)
			if position == myPosition || Movement.checkTileForPath(position) || position == lastKnownPlayerPosition || position == tileGoalPosition:
				visibleTiles.append(position)
				astar.add_point(positionToId(position), position, 1)
			else:
				visibleTiles.append(null)
					
	
	for index in range(visibleTiles.size()):
		var tile = visibleTiles[index]
		# Determine if player is standing on a tile in aggro range
		if tile == tileGoalPosition:
			lastKnownPlayerPosition = tileGoalPosition
			inCombat = true
			break;
			
	# find path to player if player is in aggro range
	if lastKnownPlayerPosition: 
		for index in range(visibleTiles.size()):
			var tile = visibleTiles[index]
			
			# if invalid tile skip
			if !tile:
				continue
			
			# Connect a point to all of its neighbors in cardinal directions
			var id = positionToId(tile)
			var rowLength = (visionRange * 2 + 1)
			# Add Up
			if index - rowLength > 0 && visibleTiles[index - rowLength] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index - rowLength]))
			# Add Right
			if (index + 1) % rowLength != 0 && index + 1 < visibleTiles.size() && visibleTiles[index + 1] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index + 1]))
			# Add Left
			if (index - 1) % rowLength != 0 && index - 1 > -1 && visibleTiles[index - 1] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index - 1]))
			# Add down
			if index + rowLength < visibleTiles.size() && visibleTiles[index + rowLength] != null:
				astar.connect_points(positionToId(tile), positionToId(visibleTiles[index + rowLength]))
			
		var path = astar.get_point_path(positionToId(myPosition), positionToId(lastKnownPlayerPosition))
		return path
	else:
		return null
		
func positionToId(pos: Vector2):
	return int(str(pos.x) + str(pos.y))

func damageTaken():
	pass
			
func dealDamage():
	core.combat(self, attacks[chosenAttack], target)
	dealtDamage = true

func handleDeath():
	if health < 1:
		die()
	
func move(dest):
	if Movement.checkTileToMove(dest):
		destination = dest
		setAction(Action.Move)

func attack(dest, attackTarget, attack):
	chosenAttack = attack
	target = attackTarget
	previousPosition = self.position
	destination = Movement.getDestTile(self, Movement.determineDirection(self, dest))
	setAction(Action.Attack)
	
func setAction(act):
	action = act

func takeTurn():
	takingTurn = true
	setAnimation(actionAnimations[action])
	
func setAnimation(nextAnimation):
	animationTimeElapsed = 0
	self.play(nextAnimation)

func animationFinished():
	# set the position to the closest center of a tile
	# find nearest divisor of the tile_size
	self.position.x = round(self.position.x / Globals.tile_size) * Globals.tile_size
	self.position.y = round(self.position.y / Globals.tile_size) * Globals.tile_size
	setAnimation(actionAnimations[Action.Idle])
	
func removeDebuff(debuff, index):
	if (debuff.duration && debuff.duration < 1):
		debuffs.remove(index)
		debuff.remove()
	
func progressDebuffs():
	for index in debuffs.size():
		var debuff = debuffs[index]
		debuff.affect()
		debuff.duration -= 1
		removeDebuff(debuff, index)
		
func hurt(dmg):
	health -= dmg
	damageTaken()
	handleDeath()
	
func finishTurn():
	progressDebuffs()
	takingTurn = false
	
func finishedMove():
	animationFinished()
	core.activateFloorInteractables(self)
	finishTurn()

func finishedAttack():
	dealtDamage = false;
	animationFinished()
	finishTurn()


