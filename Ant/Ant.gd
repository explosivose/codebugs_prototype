extends Pawn

var _attempting_to_move = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	._process(delta)
	if (not _attempting_to_move):
		move_randomly()

func move_randomly():
	_attempting_to_move = true
	if not moving:
		var random_destination = terrain.get_random_point_world()
		move_to(random_destination)
	yield(get_tree().create_timer(1), "timeout")
	_attempting_to_move = false
	
