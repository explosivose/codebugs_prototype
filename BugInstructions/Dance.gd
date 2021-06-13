extends AntInstruction

class_name Dance

func _init(_owner: Pawn).('Dance!', _owner):
	pass

func execute():
	var exec_step = .execute()
	if exec_step is GDScriptFunctionState:
		yield(exec_step, "completed")
