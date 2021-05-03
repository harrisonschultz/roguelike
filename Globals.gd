extends Node

enum WallTiles { Door, Wall, WallMissingBricks, WallWithGrate, Crack, Bottom, BottomLeft, BottomRight, Top, TopLeft, TopRight, Left, Right, TopInnerRight, TopInnerLeft, BottomInnerLeft, BottomInnerRight }
enum FloorTiles { Four, Full, Three, TwoHalf, DirtyBlank, BrokenOne, BrokenTwo, BrokenThree, BrokenFour, AltFourRight, AltFourLeft, AltThreeLeft, AltThreeRight, AltOneRight, AltFourTop, AltOneLeft }
enum Map { Occupied, Edge, Hallway}
enum FogState { Hidden, Partial, Revealed }
enum Directions { Up, Right, Down, Left }
enum Things { Player, Enemy, Gold, Item }
enum WeaponType { OneHandedMelee, TwoHandedMelee, TwoHandedRanged }

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

var PropsFolder = "res://assets/props/"
var Props = { "StairUp": PropsFolder + "stairUp.png",  "Prisoner": PropsFolder + "prisoner.png", "Barrel": PropsFolder + "barrel.png"}


var rng = RandomNumberGenerator.new()
