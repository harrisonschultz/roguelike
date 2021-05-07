extends Prop

class_name InteractableProp

var clickable = preload("res://../Clickable.tscn")
var interactRange = 1
var player

func init(name, loc):
	.init(name, loc)
	
	if 'interactRange' in details:
		interactRange = details['interactRange']
	if 'loot' in details:
		loot = details['loot']

func _ready():
	var root = get_tree().get_root()
	player = root.get_node("Root").get_node('Player')
	addClickArea()
	
func addClickArea():
	var clickable_instance = clickable.instance()
	self.add_child(clickable_instance)
	
func onInteract():
	playAnimation('interact')
	Globals.removePosition(self.position)
	collision = false
	if loot:
		Loot.dropLoot(self)

func onClick():
	if Movement.getDistance(self, player) < 2:		
		onInteract()

