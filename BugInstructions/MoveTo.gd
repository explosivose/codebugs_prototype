extends AntInstruction

class_name MoveTo

func _init(
	_owner: Pawn,
	config = { # default config
		'destination': 'random_location'
	}).('Move to', _owner, config):
	pass

func _get_destination() -> Vector2:
	if config.destination == 'random_location':
		return _owner.terrain.get_random_point_world()
	elif config.destination == 'nearest_cake':
		return _owner.terrain.get_nearest_cake(_owner.position)
	else:
		return Vector2(0, 0)

func execute():
	_spin_up()
	_stop = false
	_exec = true
	if not _stop:
		yield(_owner.get_tree().create_timer(1.0), 'timeout')
	
	var destination = _get_destination()
	print(destination)
	Logger.debug('_exec=' + str(_exec) + ', _stop=' + str(_stop))
	if not _stop:
		Logger.debug('MoveTo call move_to')
		_owner.move_to(destination)
		yield(_owner, 'destination_reached')

	_spin_down()
	emit_signal('instruction_completed')
	_exec = false

