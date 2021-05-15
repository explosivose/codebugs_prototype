extends Node2D

class_name Pawn

onready var terrain: Terrain = get_tree().current_scene.get_node("terrain")
var moving = false
var _destination: Vector2 = position
var _path: PoolVector2Array


func _ready():
	pass # Replace with function body.

func move_to(destination: Vector2):
	_destination = destination
	_path = terrain.get_terrain_path_world(position, destination)
	print('Pawn.move_to', _path)

func _process(delta: float):
	if _path.size() > 1:
		var d: float = position.distance_to(_path[1])
		if d > 5:
			moving = true
			position = position.linear_interpolate(_path[1], (200 * delta) / d)
			look_at(_path[1])
		else:
			moving = false
