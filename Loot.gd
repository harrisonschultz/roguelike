extends Node

var itemScene = preload("res://Item.tscn")
var ItemRoot 
var PropRoot


func init(itemRoot, propRoot):
	ItemRoot = itemRoot
	PropRoot = propRoot

func dropLoot(node):
	if 'randomItems' in node.loot:
		var items = getLoot(node)
		spawnItems(items, node.position)
	
	if 'gold' in node.loot:
		var gold = getGold(node.loot.gold)
		spawnGold(gold, node.position)
	
func getGold(gold):
	var goldCount = Globals.rng.randi_range(gold[0], gold[1])
	
	# Check for random spawn
	if gold.size() > 2:
		if Globals.rng.randi_range(0, 100) <= gold[2]:
			return goldCount
		
	return goldCount

func getLoot(node):
	var items = []
	for i in Globals.rng.randi_range(node.loot.randomItems[0], node.loot.randomItems[1]):
		items.append(chooseItem(node.loot.rarity[0], node.loot.rarity[1]))
	return items

func chooseItem(minRarity, maxRarity, type = Globals.LootType.Any):
	var chosenRarity = Globals.rng.randi_range(minRarity, maxRarity)
	var filteredItemPool = []
	for item in Items.items:
		# filter by rarity
		if item['rarity'] == chosenRarity:
			filteredItemPool.append(item)
			
	# Choose a random item from the filteredItemPool
	return Items.items[Globals.rng.randi_range(0, filteredItemPool.size() - 1)]

func spawnItems(items, position):
	for item in items:
		var instance = itemScene.instance()
		ItemRoot.add_child(instance)
		instance.init(item, position)
	
func spawnGold(gold, position):
	if gold > 0:
		PropRoot.add_child(Gold.new(position, gold))
