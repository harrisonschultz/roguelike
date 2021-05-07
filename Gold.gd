extends FloorInteractable

var amount
var identity

class_name Gold

func _init(position, amt).(position, amt):
	identity = Globals.Things.FloorInteractable
	amount = amt
	

func activate(node):
	.activate(node)
	if (Movement.getDistance(self, node) < 1):		
		node.gold += amount
		self.queue_free()

func _ready():
	self.texture = load("res://assets/items/bag_coins.png")
	self.texture.set_flags(2)


