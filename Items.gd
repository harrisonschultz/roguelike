extends Node

var items = [{
	'itemName': 'Sword',
	'rarity': 1,
	'value': 5,
	'sprite': "res://assets/items/sword.png",
	"type": Globals.WeaponType.OneHandedMelee,
	'itemType': Globals.ItemType.Equipment,
	'equipmentType': Globals.EquipmentType.MainHand,
	'basic': {
		"damage": [{ "type": Globals.DamageType.Physical , "damage": [1,3]}],
		"type": Globals.AttackType.Melee
	}
},
{
	'itemName': 'Shirt',
	'rarity': 1,
	'value': 3,
	'sprite': "res://assets/items/shirt.png",
	'itemType': Globals.ItemType.Equipment,
	'equipmentType': Globals.EquipmentType.Chest,
	"defenses": { Globals.DamageType.Physical: 1},
}]
