extends Enemy

var lastWanderMove

# Called when the node enters the scene tree for the first time.
func _process(delta):
	lastWanderMove += delta
	if lastWanderMove > 5:
		wander()
	pass


func wander():
	lastWanderMove = 0
	# Choose a random direction to move
	var direction = Globals.rng.randi_range(0, Globals.directionsArray.size() - 1)
	moveAction = Globals.directionsArray[direction]
	
