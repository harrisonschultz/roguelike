extends FloorInteractable

var amount
var identity

class_name Gold

func _init(position, amt).(position, amt):
	identity = Globals.Things.Gold
	amount = amt

func activate(node):
	.activate(node)
	node.gold += amount
	self.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.texture = load("res://assets/items/bag_coins.png")
	pass # Replace with function body.

