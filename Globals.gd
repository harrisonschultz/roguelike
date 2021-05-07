extends Node

enum WallTiles { Door, Wall, WallMissingBricks, WallWithGrate, Crack, Bottom, BottomLeft, BottomRight, Top, TopLeft, TopRight, Left, Right, TopInnerRight, TopInnerLeft, BottomInnerLeft, BottomInnerRight }
enum FloorTiles { Four, Full, Three, TwoHalf, DirtyBlank, BrokenOne, BrokenTwo, BrokenThree, BrokenFour, AltFourRight, AltFourLeft, AltThreeLeft, AltThreeRight, AltOneRight, AltFourTop, AltOneLeft }
enum Map { Occupied, Edge, Hallway}
enum FogState { Hidden, Partial, Revealed }
enum Directions { Up, Right, Down, Left }
enum Things { Player, Enemy, Gold, Item, Prop, DestroyableProp, InteractableProp, FloorInteractable }
enum WeaponType { OneHandedMelee, TwoHandedMelee, TwoHandedRanged }
enum Sides { Top, Right, Bottom, Left }

enum AttackType { Melee }
enum LootType { Any }
enum ItemType { Consumable, Equipment }

const tile_size = 16
const directionsArray = [ Directions.Up, Directions.Right, Directions.Down, Directions.Left ]
const LEVEL_SIZE = 320
const Layer = {
	Ability = 5,
	Enemy = 3,
	Player = 3,
	Prop = 2,
	Item = 4,
}
const DamageType = {
	Physical = 'Physical',
	Fire = 'Fire', 
	Water = 'Water', 
	Holy = 'Holy', 
	Arcane = 'Arcane', 
	Unholy = 'Unholy',
}
const EquipmentType = { 
	MainHand = 'MainHand',
	OffHand = 'OffHand',
	Head = 'Head',
	Chest = 'Chest', 
	Ranged = 'Ranged', 
	Pants = 'Pants', 
	Hands = 'Hands',
	LeftRing = 'LeftRing', 
	RightRing = 'RightRing'
}

const Props = {
	Prisoner = "Prisoner",
	StairUp = "StairUp",
	StairDown = "StairDown",
	Barrel = "Barrel",
	Chest = "Chest",
	Bookcase = "Bookcase",
	Torch = "Torch",
	TableRed = "TableRed",
	TableGreen = "TableGreen",
	FlagGreen = "FlagGreen",
	FlagRed = "FlagRed",
	Rug = 'Rug',
	RugRuined = 'RugRuined'
}

var rng = RandomNumberGenerator.new()

var collidableLocations = {}

func getPositionId(position):
	return str(position.x) + str(position.y)

func registerPosition(position: Vector2, mapPosition = false):
	if !mapPosition:
		position = Movement.worldToMap(position)
	
	collidableLocations[getPositionId(position)] = true

func removePosition(position: Vector2, mapPosition = false):
	if !mapPosition:
		position = Movement.worldToMap(position)
	collidableLocations.erase(getPositionId(position))
	
func movePosition(oldPos: Vector2, newPos: Vector2):
	removePosition(oldPos, true)
	registerPosition(newPos, true)
