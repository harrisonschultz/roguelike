extends Sprite

class_name Item

var itemName
var rarity
var value
var type
var itemRoot
var identity
var toolTip
var player
var details
var itemType
var equipmentType
var imagePath
	
func init(stats, worldPosition: Vector2):
	details = stats
	itemName = stats['itemName']
	identity = Globals.Things.Item
	rarity = stats['rarity']
	value = stats['value']
	itemType = stats['itemType']
	equipmentType = stats['equipmentType']
	imagePath = load(stats['sprite'])
	self.centered = false
	self.texture = imagePath
	# turn off filter
	self.texture.set_flags(2)
	self.position = worldPosition
	Movement.centerMe(self)

func showDetails(show):
	toolTip.visible = show

func _ready():
	toolTip = get_node("./CanvasLayer/Popup")
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
		player.addToInventory(player.convertToInventoryItem(self))

