extends Node

var Floor
const wallsWithCollision = [7,8,14,15]

# Called when the node enters the scene tree for the first time.
func _ready():
	Floor = get_node("Floor")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func move(node, destination: Vector2, x, y):
	if checkTileToMove(destination):
		node.position.x += x
		node.position.y += y
		
func checkTileToMove(destination):	
	var cell = Floor.get_cell(destination.x, destination.y)
	print(cell)
	if cell > -1:
		return true
	else:
		return false
