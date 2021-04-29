extends Sprite

class_name Item

const tooltipContent = './CanvasLayer/Popup/NinePatchRect/MarginContainer/VBoxContainer/'

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
	# Turn off filter
	self.texture.set_flags(2)
	self.position = worldPosition
	Movement.centerMe(self)
	populateTooltip()
	
func populateTooltip():
	# Description
	var title = get_node(tooltipContent + "Title/Label")
	title.text = details['itemName']
	
	# Stats
	var totalDamageMin = 0
	var totalDamageMax = 0
	if 'basic' in details:
		var typesToRemove = Utilities.deep_copy(Globals.DamageType)
		for i in details['basic']['damage']:
			var value_node = get_node(tooltipContent + 'Stats/' + i.type + '/Label')
			value_node.text = str(i.damage[0]) + " - " + str(i.damage[1])
			totalDamageMin += i.damage[0]
			totalDamageMax += i.damage[1]
			typesToRemove.erase(i.type)
			
		# Remove elements from tooltip if not present
		for x in typesToRemove:
			get_node('CanvasLayer/Popup/NinePatchRect/MarginContainer/VBoxContainer/Stats/' + x).queue_free()
			
	if 'defenses' in details:
		var typesToRemove = Utilities.deep_copy(Globals.DamageType)
		for i in details['defenses'].keys():
			var value_node = get_node(tooltipContent + 'Stats/' + i + '/Label')
			value_node.text = str(details['defenses'][i])
			typesToRemove.erase(i)
			
		# Remove elements from tooltip if not present
		for x in typesToRemove:
			get_node('CanvasLayer/Popup/NinePatchRect/MarginContainer/VBoxContainer/Stats/' + x).queue_free()

func showDetails(show):
	toolTip.visible = show

func _ready():
	toolTip = get_node("./CanvasLayer/Popup")
	toolTip.visible = false
	var root = get_tree().get_root()
	var core = root.get_node("Root")
	player = core.get_node("Player")
	itemRoot = core.get_node('ItemRoot')


func _on_ItemSprite_mouse_entered():
	showDetails(true)

func _on_ItemSprite_mouse_exited():
	showDetails(false)

func _on_ItemSprite_input_event(viewport, event, shape_idx):
	if event.is_action("LeftClick") and !event.pressed:
		itemRoot.remove_child(self)
		player.addToInventory(player.convertToInventoryItem(self))

