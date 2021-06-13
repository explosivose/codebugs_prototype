extends Reference

class_name AntInstruction
signal instruction_completed

var is_executing setget ,_get_is_executing
var instruction_name setget ,_get_name
# config is a set of options for this instruction
# the config can provide a lot of variation for a single instruction type
# for example: move_to can have the destination in the config
var config: Dictionary = {}

var _exec = false
var _stop = false
var _instr_name: String
var _owner: Pawn


func _get_is_executing() -> bool:
	return _exec

func _get_name() -> String:
	return _instr_name

func _init(instr_name: String, owner: Pawn, cfg: Dictionary = {}):
	_instr_name = instr_name
	_owner = owner
	config = cfg
	
func _spin_up():
	Logger.debug('[instr]> ' + _instr_name)
	Logger.debug('[instr] stop=' + str(_stop))
	Logger.debug('[instr] exec=' + str(_exec))

func _spin_down():
	Logger.debug('[instr] stop=' + str(_stop))
	Logger.debug('[instr] exec=' + str(_exec))
	Logger.debug('[instr]-- ' + _instr_name)

	
func stop():
	_stop = true

func execute():
	return
	#_spin_up()
	#_stop = false
	#_exec = true
	#var timer = _owner.get_tree().create_timer(1.0)
	#if _exec and not _stop:
	#	yield(timer, "timeout")
	#_spin_down()
	#emit_signal("instruction_completed")
	#_exec = false


