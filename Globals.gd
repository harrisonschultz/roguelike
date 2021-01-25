extends Node

var tile_size = 16
enum WallTiles { Door, Wall, WallMissingBricks, WallWithGrate, Crack, Bottom, BottomLeft, BottomRight, Top, TopLeft, TopRight, Left, Right, TopInnerRight, TopInnerLeft, BottomInnerLeft, BottomInnerRight }
enum Map { Occupied, Edge, Hallway}
enum FogState { Hidden, Partial, Revealed }
const LEVEL_SIZE = 320
