extends Pawn

class_name Ant

var _attempting_to_move = false
var _program: AntProgram

# Called when the node enters the scene tree for the first time.
func _ready():
	BugProgramRepo.connect("program_added", self, "_get_program")
	_program = AntProgram.new()

func _get_program():
	Logger.debug('Getting new program')
	if _program.is_executing:
		_program.end_program()
	_program.clear()
	var src_program = BugProgramRepo.get_program()
	for src in src_program:
		_program.add_instruction(src.instr.new(self, src.config))
	_program.loop_program()

func _process(delta):
	._process(delta)

func move_randomly():
	_attempting_to_move = true
	var random_destination = terrain.get_random_point_world()
	move_to(random_destination)
	yield(get_tree().create_timer(1), "timeout")
	_attempting_to_move = false
