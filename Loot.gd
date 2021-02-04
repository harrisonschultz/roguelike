extends Node

var itemScene = preload("res://Item.tscn")

func dropLoot(node, rootNode):
	var items = getLoot(node)
	var gold = getGold(node)
	spawnGold(gold, node.position, rootNode)
	spawnItems(items, node.position, rootNode)
	
func getGold(node):
	return Globals.rng.randi_range(node.loot.gold[0], node.loot.gold[1])

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

func spawnItems(items, position, rootNode):
	for item in items:
		var instance = itemScene.instance()
		rootNode.add_child(instance)
		instance.init(item, position)
	
func spawnGold(gold, position, rootNode):
	rootNode.add_child(Gold.new(position, gold ))
