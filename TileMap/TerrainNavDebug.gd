extends Node2D

class_name TerrainNavDebug

const OPACITY = 0.5
var NODE_COLOR = ColorN('cyan', OPACITY)
var CONNECTION_COLOR = ColorN('cyan', OPACITY)
const GRID_THICKNESS = 4
const CONNECTION_WIDTH = GRID_THICKNESS

var _nav: AStar2D;

func _init(nav):
	_nav = nav
	_nav.connect('nav_updated', self, '_on_nav_updated')

func _on_nav_updated():
	show()
	update()

func _draw():
	var points = _nav.get_points()
	var tile_size = _nav.get_tile_size()
	var point_size = tile_size / (16 / GRID_THICKNESS)
	for point in points:
		var point_position = _nav.get_point_position(point)
		var rect = Rect2(point_position - point_size / 2, point_size)
		draw_rect(rect, NODE_COLOR)
		var other_points = _nav.get_point_connections(point)
		for other_point in other_points:
			var other_point_position = _nav.get_point_position(other_point)
			draw_line(point_position, other_point_position, CONNECTION_COLOR, CONNECTION_WIDTH)
