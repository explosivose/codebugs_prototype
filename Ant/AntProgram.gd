extends Reference

class_name AntProgram

signal program_completed

var is_executing setget ,_get_is_executing
var current_instruction setget ,_get_current_instr

var _program: Array = []
var _current_instr: AntInstruction
var _exec = false
var _stop = false

func add_instruction(instr: AntInstruction):
	_program.append(instr)

func _get_current_instr() -> AntInstruction:
	return _current_instr as AntInstruction

func _get_is_executing() -> bool:
	return _exec

func run_program():
	_stop = false
	_exec = true
	for instr in _program:
		if _stop:
			break
		_current_instr = instr
		instr.execute()
		yield(instr, "instruction_completed")
	_exec = false
	emit_signal("program_completed")
	
func loop_program():
	while not _stop:
		run_program()
		yield(self, "program_completed")
	
func end_program():
	if _current_instr:
		_current_instr.stop()
	_stop = true
