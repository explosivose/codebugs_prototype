extends TileMap


class_name Terrain

enum TILE {
	CAKE = 36,
	BG_DIRT = 37,
	GRASS_TOP = 20,
}

const WALKABLE_TILE_OFFSETS = {}

onready var _nav: TerrainNav = TerrainNav.new(self)

func is_outside_map_boundaries(map_point: Vector2) -> bool:
	return not get_used_rect().has_point(map_point)

func get_random_point_world() -> Vector2:
	var points = _nav.get_points()
	return _nav.get_point_position(points[randi() % points.size()])

func get_nearest_cake(p: Vector2) -> Vector2:
	var cake_cells = get_used_cells_by_id(TILE.CAKE)
	if cake_cells.size() <= 0:
		return p
	var nearest = map_to_world(cake_cells[0]) 
	for cake_cell in cake_cells:
		if nearest.distance_to(p) > map_to_world(cake_cell).distance_to(p):
			nearest = map_to_world(cake_cell)
	return nearest

# where from and to are world points
# the returned path are world points
func get_terrain_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	Logger.debug('get_terrain_path from ' + str(from) + ', to ' + str(to), 'pathfinding')
	if is_outside_map_boundaries(world_to_map(from)):
		Logger.warn('path starts out-of-bounds!', 'pathfinding')
		return [] as PoolVector2Array
	if is_outside_map_boundaries(world_to_map(to)):
		Logger.warn('path ends out-of-bounds!', 'pathfinding')
		return [] as PoolVector2Array
	var start_index = _nav.get_closest_point(from)
	var end_index = _nav.get_closest_point(to)
	if not _nav.has_point(start_index):
		Logger.warn('Start point in path does not exist in astar graph', 'pathfinding')
	if not _nav.has_point(end_index):
		Logger.warn('End point in path does not exist in astar graph', 'pathfinding')
	var path = _nav.get_point_path(start_index, end_index)
	if path.size() == 0:
		Logger.warn('No path found between ' + str(from) + str(to), 'pathfinding')
	return path

# Called when the node enters the scene tree for the first time.
func _ready():
	Logger.debug('Terrain used rect: ' + str(get_used_rect()))
	_set_tile_walk_data()
	_nav.create_nav_grid(WALKABLE_TILE_OFFSETS)

func _set_tile_walk_data():
	# tile offsets are from the world position of a tile (top left corner)
	var center = cell_size * Vector2(0.5, 0.5)
	var top_center = cell_size * Vector2(0.5, 0)
	WALKABLE_TILE_OFFSETS[TILE.CAKE] = center
	WALKABLE_TILE_OFFSETS[TILE.BG_DIRT] = center
	WALKABLE_TILE_OFFSETS[TILE.GRASS_TOP] = top_center
