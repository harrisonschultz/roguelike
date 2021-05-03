extends Node

var root
var player
var enemyRoot
var propRoot
var floors
var walls

func _ready():
	root = get_tree().get_root().get_node("Root")
	enemyRoot = root.get_node('EnemyRoot')
	propRoot = root.get_node('PropRoot')
	player = root.get_node("Player")
	floors = root.get_node("Floor")
	walls = root.get_node("Walls")
	
func mapToWorld(point):
	return Vector2(point.x * Globals.tile_size, point.y * Globals.tile_size)

func determineDirection(node, destination):
	destination = mapToWorld(destination)
	if node.position.y > destination.y:
		return Globals.Directions.Up
	elif node.position.x < destination.x:
		return Globals.Directions.Right
	elif node.position.y < destination.y:
		return Globals.Directions.Down
	elif node.position.x > destination.x:
		return Globals.Directions.Left
	
func move(node, destination: Vector2, distance: float):
	var direction = determineDirection(node, destination)
	var newPoint = Vector2(0, 0)
	if direction ==  Globals.Directions.Up:
		newPoint = Vector2(0, -distance)
	elif direction ==  Globals.Directions.Right:
		newPoint = Vector2(distance, 0)
	elif direction ==  Globals.Directions.Down:
		newPoint = Vector2(0, distance)
	elif direction ==  Globals.Directions.Left:
		newPoint = Vector2( -distance, 0)
		
	node.position += newPoint

func worldToMap(pos: Vector2):
	var x = round(pos.x / Globals.tile_size)
	var y = round(pos.y / Globals.tile_size)
	return Vector2(x,y)
	
func whatIsOnTile(tile):
	var nodes = enemyRoot.get_children()
	nodes.append(player)
	for node in nodes:
		if worldToMap(node.position) == tile:
			return node
	return null
		
func checkTileToMove(destination):
	# Wall Collision Check
	var cell = floors.get_cell(destination.x, destination.y)
	if cell < 0:
		return false
	
	# Unit Collision Check
	var unitOnDestination = false
	var nodes = enemyRoot.get_children()
	nodes.append(player)
	for node in nodes:
		if node.isCollidable() and worldToMap(node.position) == destination:
			unitOnDestination = true
			break;
	
	if unitOnDestination:
		return false
		
	
	# Prop Collision Check
	var collidingPropOnDestination = false
	var props = propRoot.get_children()
	for prop in props:
		if prop.isCollidable() and worldToMap(prop.position) == destination:
			collidingPropOnDestination = true
			break;
	
	if collidingPropOnDestination:
		return false
		
	return true
		
func checkTileForPath(destination):
	# Wall Collision Check
	var cell = floors.get_cell(destination.x, destination.y)
	
	# Unit Collision Check
	var unitOnDestination = false
	var nodes = enemyRoot.get_children()
	nodes.append(player)
	for node in nodes:
		if worldToMap(node.position) == destination:
			unitOnDestination = true
			break;
	
	if cell > -1 && !unitOnDestination:
		return true
	else:
		return false
		
func getDestTile(node, direction):
	var destination = node.position
	if direction == Globals.Directions.Up:
		destination.y += -Globals.tile_size
	elif direction == Globals.Directions.Left:
		destination.x += -Globals.tile_size
	elif direction == Globals.Directions.Down:
		destination.y += Globals.tile_size
	elif direction == Globals.Directions.Right:
		destination.x += Globals.tile_size
	destination.x = round(destination.x / Globals.tile_size)
	destination.y = round(destination.y / Globals.tile_size)
	return destination
	
func centerMe(node):
	node.position.x = round(node.position.x / Globals.tile_size) * Globals.tile_size
	node.position.y = round(node.position.y / Globals.tile_size) * Globals.tile_size
