extends Pawn

class_name Ant

var _attempting_to_move = false
var _program: AntProgram

# Called when the node enters the scene tree for the first time.
func _ready():
	_program = AntProgram.new()
	_program.add_instruction(MoveToNearestCake.new(self))
	_program.add_instruction(Dance.new(self))
	_program.add_instruction(MoveToRandomLocation.new(self))


func _process(delta):
	._process(delta)
	if not _program.is_executing:
		_program.run_program()


func move_randomly():
	_attempting_to_move = true
	var random_destination = terrain.get_random_point_world()
	move_to(random_destination)
	yield(get_tree().create_timer(1), "timeout")
	_attempting_to_move = false
