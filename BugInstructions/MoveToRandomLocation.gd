extends AntInstruction

class_name MoveToRandomLocation

func _init(_owner: Pawn).('Move to random location', _owner):
	pass

func execute():
	_spin_up()
	_stop = false
	_exec = true
	if _exec and not _stop:
		yield(_owner.get_tree().create_timer(1.0), "timeout")
	
	var random_destination = _owner.terrain.get_random_point_world()
	if _exec and not _stop:
		_owner.move_to(random_destination)
		yield(_owner, "destination_reached")

	_spin_down()
	emit_signal("instruction_completed")
	_exec = false

