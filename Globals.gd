extends Node

enum WallTiles { Door, Wall, WallMissingBricks, WallWithGrate, Crack, Bottom, BottomLeft, BottomRight, Top, TopLeft, TopRight, Left, Right, TopInnerRight, TopInnerLeft, BottomInnerLeft, BottomInnerRight }
enum Map { Occupied, Edge, Hallway}
enum FogState { Hidden, Partial, Revealed }
enum Directions { Up, Right, Down, Left }
enum Things { Player, Enemy, Gold, Item }
enum WeaponType { OneHandedMelee, TwoHandedMelee, TwoHandedRanged }
enum EquipmentType { MainHand, OffHand, Head, Chest, Ranged, Pants, Hands, LeftRing, RightRing }
enum DamageType { Physical, Fire, Water, Holy, Arcane, Dark }
enum AttackType { Melee }
enum LootType { Any }
enum ItemType { Consumable, Equipment }

const tile_size = 16
const directionsArray = [ Directions.Up, Directions.Right, Directions.Down, Directions.Left ]
const LEVEL_SIZE = 320

var rng = RandomNumberGenerator.new()
