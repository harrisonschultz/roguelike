extends TextureRect

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
	
func init(stats):
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
	self.texture = image

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

func _on_InventoryItem_mouse_entered():
	showDetails(true)

func _on_InventoryItem_mouse_exited():
	showDetails(false)

func _on_InventoryItem_gui_input(event):
	if event.is_action("LeftClick"):
		if self.itemType == Globals.ItemType.Equipment:
			player.equipItem(self)
		elif self.itemType == Globals.ItemType.Consumable:
			pass

