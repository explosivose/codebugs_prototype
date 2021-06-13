extends Node

signal program_added

var _programs = {}

func add_program(program: Array) -> void:
	_programs['my_program'] = program
	emit_signal("program_added")

func get_program(name = 'my_program') -> Array:
	return _programs[name]

func _ready():
	pass
