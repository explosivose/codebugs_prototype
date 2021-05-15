extends TileMap

# confusingly there are three coord systems at play here
# 1) tile map coordinates
# 2) local coordinates
# 3) global coordinates

class_name Terrain

onready var _astar: AStar2D = AStar2D.new()
onready var _cells: PoolVector2Array = get_used_cells() # map coords
onready var _half_cell_size: Vector2 = cell_size / 2
onready var _map_size: Vector2 = _get_map_size() # map coords

func is_outside_map_boundaries(p: Vector2) -> bool:
	return p.x < 0 or p.y < 0 or p.x > _map_size.x or p.y > _map_size.y

func get_random_point() -> Vector2:
	var points = _astar.get_points()
	return _astar.get_point_position(points[randi() % points.size()])
	
func get_random_point_world() -> Vector2:
	var point = get_random_point()
	return map_to_world(point)

func get_terrain_path_world(from: Vector2, to: Vector2) -> PoolVector2Array:
	var from_map = world_to_map(from)
	var to_map = world_to_map(to)
	return get_terrain_path(from_map, to_map)

func get_terrain_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	print('Terrain.get_terrain_path: ', from, to)
	if is_outside_map_boundaries(from):
		print('Terrain.get_terrain_path: path_starts out-of-bounds!', _map_size, from)
		return [] as PoolVector2Array
	if is_outside_map_boundaries(to):
		print('Terrain.get_terrain_path: path ends out-of-bounds!', _map_size, to)
		return [] as PoolVector2Array
	var start_index = _get_point_index(from)
	var end_index = _get_point_index(to)
	if not _astar.has_point(start_index):
		print('Start point in path does not exist in astar')
	if not _astar.has_point(end_index):
		print('End point in path does not exist in astar!')
	var path = _astar.get_point_path(start_index, end_index)
	if path.size() == 0:
		print('No path found between ', from, to)
	# print('Terrain.get_terrain_path: Path from astar: ', path, ', ', start_index, ', ', end_index)
	var terrain_path: PoolVector2Array = []
	for point in path:
		var terrain_point = map_to_world(point) + _half_cell_size
		terrain_path.append(terrain_point)
	return terrain_path

func _make_walkable_points(cells: PoolVector2Array) -> PoolVector2Array:
	var points: PoolVector2Array = []
	for y in range(ceil(_map_size.y)):
		for x in range(ceil(_map_size.x)):
			var point = Vector2(x, y)
			if point in cells:
				# TODO discover appropriate point offset for partial blocking and non-blocking cells
				continue
			# TODO don't add points that have no tiles ...
			# TODO only add walkable tiles, and add points precisely on their walkable space
			points.append(point)
			var point_index = _get_point_index(point)
			_astar.add_point(point_index, point)
	return points

func _connect_walkable_points(points: PoolVector2Array):
	for point in points:
		var point_index = _get_point_index(point)
		var adjacents: PoolVector2Array = [
			point + Vector2.RIGHT,
			point + Vector2.LEFT,
			point + Vector2.UP,
			point + Vector2.DOWN
		];
		for adjacent_point in adjacents:
			if is_outside_map_boundaries(adjacent_point):
				continue
			var adjacent_point_index = _get_point_index(adjacent_point)
			if not _astar.has_point(adjacent_point_index):
				continue
			_astar.connect_points(point_index, adjacent_point_index, false)

func _get_point_index(point: Vector2) -> int:
	return int(round(point.x)) + int(ceil(_map_size.x)) * int(round(point.y));

func _get_map_size() -> Vector2:
	var map_size = Vector2(0, 0)
	for cell in _cells:
		map_size.x = max(map_size.x, cell.x)
		map_size.y = max(map_size.y, cell.y)
	return map_size;

# Called when the node enters the scene tree for the first time.
func _ready():
	print('Terrain._map_size', _map_size)
	var points = _make_walkable_points(_cells)
	print('Terrain points ', points)
	_connect_walkable_points(points)