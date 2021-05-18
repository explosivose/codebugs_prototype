extends AntInstruction

class_name MoveToNearestCake

func _init(_owner: Pawn).('Move to nearest cake', _owner):
	pass

func execute():
	_spin_up()
	_stop = false
	_exec = true
	if _exec and not _stop:
		yield(_owner.get_tree().create_timer(1.0), "timeout")
	
	var nearest_cake = _owner.terrain.get_nearest_cake(_owner.position)
	if _exec and not _stop:
		_owner.move_to(nearest_cake)
		yield(_owner, "destination_reached")

	_spin_down()
	emit_signal("instruction_completed")
	_exec = false

