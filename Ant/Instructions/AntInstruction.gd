extends Reference

class_name AntInstruction
signal instruction_completed

var is_executing setget ,_get_is_executing
var instruction_name setget ,_get_name

var _exec = false
var _stop = false
var _instr_name: String
var _owner: Pawn

func _get_is_executing() -> bool:
	return _exec

func _get_name() -> String:
	return _instr_name

func _init(instr_name: String, owner: Pawn):
	_instr_name = instr_name
	_owner = owner
	
func _spin_up():
	Logger.debug('[instr]> ' + _instr_name)

	
func _spin_down():
	Logger.debug('[instr]-- ' + _instr_name)
	
func stop():
	_stop = true

func execute():
	_spin_up()
	_stop = false
	_exec = true
	var timer = _owner.get_tree().create_timer(1.0)
	if _exec and not _stop:
		yield(timer, "timeout")
	_spin_down()
	emit_signal("instruction_completed")
	_exec = false


