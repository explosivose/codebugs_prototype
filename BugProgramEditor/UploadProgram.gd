extends Button

onready var _program_editor = get_parent().get_parent().get_node("Body")

func _ready():
	connect("pressed", self, "_upload_program")
	pass

func _upload_program():
	var program = _program_editor.serialize()
	BugProgramRepo.add_program(program)
