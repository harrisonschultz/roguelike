extends Sprite

class_name Item

var itemName
var rarity
var value
var type
var damage
var itemRoot
var identity
var toolTip
var player
var details
var itemType
var equipmentType
	
func init(stats, worldPosition: Vector2):
	details = stats
	itemName = stats['itemName']
	identity = Globals.Things.Item
	rarity = stats['rarity']
	value = stats['value']
	type = stats['type']
	damage = stats['damage']
	itemType = stats['itemType']
	equipmentType = stats['equipmentType']
	var image = load(stats['sprite'])
	self.centered = false
	self.texture = image
	self.position = worldPosition
	Movement.centerMe(self)

func showDetails(show):
	if show:
		toolTip.popup()
	else:
		toolTip.visible = false
	pass

func _ready():
	toolTip = get_node("Popup")
	var root = get_tree().get_root()
	var core = root.get_node("Root")
	player = core.get_node("Player")
	itemRoot = core.get_node('ItemRoot')
	pass

func _on_ItemSprite_mouse_entered():
	showDetails(true)

func _on_ItemSprite_mouse_exited():
	showDetails(false)

func _on_ItemSprite_input_event(viewport, event, shape_idx):
	if event.is_action("LeftClick"):
		itemRoot.remove_child(self)
		player.addToInventory(self)

