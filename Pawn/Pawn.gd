extends Node2D

class_name Pawn

signal destination_reached

const LINE_SCENE_PATH = "res://Line/Line.tscn"

onready var terrain: Terrain = get_tree().current_scene.get_node("terrain")
var moving = false
var at_destination = false
var _destination: Vector2 = position
var _path: PoolVector2Array
onready var _line = {
	intent = load(LINE_SCENE_PATH).instance() as Line2D,
	path = load(LINE_SCENE_PATH).instance() as Line2D,
}

func _ready():
	_line['intent'].width = 2
	_line['intent'].default_color= '#ff6678'
	get_parent().call_deferred('add_child', _line['intent'])
	get_parent().call_deferred('add_child', _line['path'])

func _hide_line(name: String):
	_line[name].hide()
	
func _show_line(name: String, points: PoolVector2Array):
	if points:
		_line[name].points = points
	_line[name].show()

func move_to(destination: Vector2):
	_destination = destination
	_show_line('intent', [position, _destination])
	_path = terrain.get_terrain_path(position, destination)
	_show_line('path', _path)
	at_destination = false
	Logger.fine('Pawn move to ' + str(_path))

func _process(delta: float):
	if _path.size() > 1:
		_show_line('intent', [position, _path[1]])
		var d: float = position.distance_to(_path[1])
		if d > 5:
			moving = true
			position = position.linear_interpolate(_path[1], (200 * delta) / d)
			look_at(_path[1])
		else:
			_path.remove(1)
		_path[0] = position
		_show_line('path', _path)
	else:
		if not at_destination:
			at_destination = true
			_hide_line('path')
			emit_signal('destination_reached')
		moving = false
