extends TileMap

# confusingly there are three coord systems at play here
# 1) tile map coordinates
# 2) local coordinates
# 3) global coordinates

# the pathfinding uses astar
# for each walkable tilemap point there is an astar point
# the position of the astar point is the tile's world position + an offset
# the offset depends on the tile id
# the astar point indices are calculated from the tilemap point

class_name Terrain

const LINE_SCENE_PATH = "res://Line/Line.tscn"
const SQUARE_SCENE_PATH = "res://Square/Square.tscn"

enum TILE {
	CAKE = 36,
	BG_DIRT = 37,
	GRASS_TOP = 20,
}

const WALKABLE_TILE_OFFSETS = {}

const ASTAR_DEBUG = true
const ASTAR_LINE_WIDTH = 1
const ASTAR_LINE_COLOUR = '#66ffe2'

onready var _astar: AStar2D = AStar2D.new()
onready var _cells: PoolVector2Array = get_used_cells() # map coords
onready var _half_cell_size: Vector2 = cell_size / 2
onready var _line_res = load(LINE_SCENE_PATH)
onready var _square_res = load(SQUARE_SCENE_PATH)


func is_outside_map_boundaries(map_point: Vector2) -> bool:
	return not get_used_rect().has_point(map_point)

func get_random_point_world() -> Vector2:
	var points = _astar.get_points()
	return _astar.get_point_position(points[randi() % points.size()])

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
	var start_index = _astar.get_closest_point(from)
	var end_index = _astar.get_closest_point(to)
	if not _astar.has_point(start_index):
		Logger.warn('Start point in path does not exist in astar graph', 'pathfinding')
	if not _astar.has_point(end_index):
		Logger.warn('End point in path does not exist in astar graph', 'pathfinding')
	var path = _astar.get_point_path(start_index, end_index)
	if path.size() == 0:
		Logger.warn('No path found between ' + str(from) + str(to), 'pathfinding')
	return path

func _make_walkable_points() -> PoolVector2Array:
	var map_points: PoolVector2Array = []
	var rect = get_used_rect()
	for y in range(rect.position.y, rect.end.y, 1):
		for x in range(rect.position.x, rect.end.x, 1):
			var cell_id = get_cell(x, y)
			if WALKABLE_TILE_OFFSETS.has(cell_id):
				var map_point = Vector2(x, y)
				map_points.append(map_point)
				var astar_index = _get_point_index(map_point)
				# convert to world point then + tile offset
				var point = map_to_world(map_point) + WALKABLE_TILE_OFFSETS[cell_id]
				if cell_id == TILE.CAKE:
					Logger.debug('Adding cake at index ' + str(astar_index))
				_astar.add_point(astar_index, point)
	return map_points

func _connect_walkable_map_points(map_points: PoolVector2Array):
	for map_point in map_points:
		var astar_index = _get_point_index(map_point)
		var adjacents_map_points: PoolVector2Array = [
			map_point + Vector2.RIGHT,
			map_point + Vector2.LEFT,
			map_point + Vector2.UP,
			map_point + Vector2.DOWN,
			map_point + Vector2.UP + Vector2.LEFT,
			map_point + Vector2.UP + Vector2.RIGHT,
			map_point + Vector2.DOWN + Vector2.LEFT,
			map_point + Vector2.DOWN + Vector2.RIGHT
		];
		for adjacent_map_point in adjacents_map_points:
			var adjacent_astar_index = _get_point_index(adjacent_map_point)
			if not _astar.has_point(adjacent_astar_index):
				continue
			_astar.connect_points(astar_index, adjacent_astar_index, false)

func _draw_astar_debug():
	var points = _astar.get_points()
	for point in points:
		var square = _square_res.instance() as Polygon2D
		add_child(square)
		var point_position = _astar.get_point_position(point)
		square.position = point_position
		var other_points = _astar.get_point_connections(point)
		for other_point in other_points:
			# TODO check whether this connection has already been drawn
			# dont draw it twice
			var line = _line_res.instance() as Line2D
			add_child(line)
			line.width = ASTAR_LINE_WIDTH
			line.default_color = ASTAR_LINE_COLOUR
			var other_point_position = _astar.get_point_position(other_point)
			line.points = [point_position, other_point_position]

func _get_point_index(map_point: Vector2) -> int:
	var map_rect = get_used_rect()
	# if the map coord values are negative then wrap them over beyond the map rect
	# this is necessary because astar indices must be 0 or larger
	var x = map_point.x if map_point.x > 0 else 1 + abs(map_point.x) + map_rect.end.x
	var y = map_point.y if map_point.y > 0 else 1 + abs(map_point.y) + map_rect.end.y
	return int(round(x + map_rect.end.x * y))

# Called when the node enters the scene tree for the first time.
func _ready():
	Logger.debug('Terrain used rect: ' + str(get_used_rect()))
	_set_tile_walk_data()
	var points = _make_walkable_points()
	Logger.trace('Terrain points: ' + str(points), 'terrain')
	_connect_walkable_map_points(points)
	if ASTAR_DEBUG:
		_draw_astar_debug()

func _set_tile_walk_data():
	# tile offsets are from the world position of a tile (top left corner)
	var center = cell_size * Vector2(0.5, 0.5)
	var top_center = cell_size * Vector2(0.5, 0)
	WALKABLE_TILE_OFFSETS[TILE.CAKE] = center
	WALKABLE_TILE_OFFSETS[TILE.BG_DIRT] = center
	WALKABLE_TILE_OFFSETS[TILE.GRASS_TOP] = top_center
