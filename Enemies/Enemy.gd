extends Unit

class_name Enemy

var player
var lastWanderMove = 0
var awards
var itemRoot
var loot = {}


func _init():
	identity = Globals.Things.Enemy
	
func init(details, position):
	.init(details, position)
	awards = details['awards']
	loot = details['loot']

func _ready():
	player = core.get_node("Player")
	itemRoot = core.get_node("ItemRoot")
	selectAction()

func takeTurn():
	.takeTurn()
	selectAction()
	
func finishTurn():
	.finishTurn()
	core.finishEnemyTurn()
	
func die():
	.die()
	if awards:
		player.receive(awards)
	Loot.dropLoot(self, itemRoot)

func selectAction():
	var pathToPlayer = findPathToNode(player)
	if pathToPlayer:
		var adjacent = pathToPlayer.size() <= 2
		if !adjacent:
			move(pathToPlayer[1])
		elif pathToPlayer.size() == 2:
			attack(pathToPlayer[1], player, 'basic')
	else:
		wander()
	
func wander():
	if lastWanderMove > 3:
		# Choose a random direction to move
		var direction = Globals.rng.randi_range(0, Globals.directionsArray.size() - 1)
		var goal = Movement.getDestTile(self, direction)
		if Movement.checkTileToMove(goal):
			move(goal)
		else:
			setAction(Action.Idle)
			finishTurn()
	else:
		lastWanderMove += 1
		setAction(Action.Idle)
		finishTurn()
