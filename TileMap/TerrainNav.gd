extends AStar2D

class_name TerrainNav
signal nav_updated

var _terrain: TileMap

var _draw_debug: Node2D

func get_tile_size():
	return _terrain.cell_size

# walkable_tile_offsets: a dictionary of tile offsets which place the astar node on the tile 
# relative to their world pos (top left corner)
func create_nav_grid(walkable_tile_offsets: Dictionary):
	var map_points = _init_walkable_points(walkable_tile_offsets)
	_init_walkable_connections(map_points)
	emit_signal('nav_updated')

func _init(terrain: TileMap):
	_terrain = terrain
	_terrain.add_child(TerrainNavDebug.new(self))

func _get_tile_index(map_point: Vector2) -> int:
	var map_rect = _terrain.get_used_rect()
	# astar indices must be 0 or larger
	# to ensure this we offset everything by the map_rect position which
	# moves everything to be relative to (0, 0)
	# FIXME this code seems to produce some aliases. not sure why
	#var x = map_point.x - map_rect.position.x
	#var y = map_point.y - map_rect.position.y
	
	# ALTERNATIVE if the map coord values are negative then wrap them over beyond the map rect
	var x = map_point.x if map_point.x > 0 else 1 + abs(map_point.x) + map_rect.end.x
	var y = map_point.y if map_point.y > 0 else 1 + abs(map_point.y) + map_rect.end.y
	var index = int(round(x + map_rect.end.x * y))
	return index

func _init_walkable_points(walkable_tile_offsets: Dictionary) -> PoolVector2Array:
	var map_points: PoolVector2Array = []
	var rect = _terrain.get_used_rect()
	for y in range(rect.position.y, rect.end.y, 1):
		for x in range(rect.position.x, rect.end.x, 1):
			var cell_id = _terrain.get_cell(x, y)
			if walkable_tile_offsets.has(cell_id):
				var map_point = Vector2(x, y)
				map_points.append(map_point)
				var astar_index = _get_tile_index(map_point)
				if astar_index < 0:
					Logger.warn('Negative astar index: ' + str(astar_index))
				# convert to world point, then add the tile offset
				var point = _terrain.map_to_world(map_point) + walkable_tile_offsets[cell_id]
				add_point(astar_index, point)
	return map_points

func _init_walkable_connections(map_points: PoolVector2Array) -> void:
	for map_point in map_points:
		var astar_index = _get_tile_index(map_point)
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
			var adjacent_astar_index = _get_tile_index(adjacent_map_point)
			if not has_point(adjacent_astar_index):
				continue
			connect_points(astar_index, adjacent_astar_index, false)







