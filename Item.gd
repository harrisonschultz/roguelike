extends Sprite

var itemName
var rarity
var value
var type
var damage
var itemRoot
var identity
var toolTip
var player
	
func init(details, worldPosition: Vector2):
	itemName = details['itemName']
	identity = Globals.Things.Item
	rarity = details['rarity']
	value = details['value']
	type = details['type']
	damage = details['damage']
	var image = load(details['sprite'])
	self.centered = false
	self.texture = image
	self.position = worldPosition
	Movement.centerMe(self)

func showDetails(show):
	toolTip.popup()
	pass

func _ready():
	toolTip = get_node("Popup")
	var root = get_tree().get_root()
	var core = root.get_node("Root")
	player = core.get_node("Player")
	pass

func _on_ItemSprite_mouse_entered():
	print('askdjflaksdf')
	showDetails(true)


func _on_ItemSprite_mouse_exited():
	showDetails(false)

func _on_ItemSprite_input_event(viewport, event, shape_idx):
	if event.is_action("LeftClick"):
		player.addToInventory(self)
