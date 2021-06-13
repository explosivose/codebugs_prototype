extends VBoxContainer

# the bug program editor will convert the child InstructionNodes into
# AntInstruction objects and add them to the AntProgram in order

# to map InstructionNodes (GUI) to AntInstruction (Reference) we need
# a Global instruction set object (singleton)
# this singleton defines the mapping between instruction names and the
# actual instructions that will be executed by the ants
# it can also define any configuration needed for each instruction
# such as inputs 
# instruction_set: InstructionName[] = global.get_instruction_names()
# add_instruction (name: InstructionName) -> InstructionNode.instance()
#   InstructionNode.input_options = global.get_instruction_inputs(name: InstructionName)
#
# compile()
# 	for child in children
#		if child is instanceof (InstructionNode)
#			instruction = global.fetch_instruction(child.name)
#			instruction.input = child.input
#			program.add_instruction(instruction)
#
# we also need to reorganise the folder structure
#	directory for instruction GUI
#	directory for instructions

onready var _add_instruction_button: OptionButton = $AddInstruction
onready var _instruction_src = preload("res://BugInstructions/Process.tscn")
onready var _instruction_src_input = preload("res://BugInstructions/Input.tscn")
onready var _instruction_names = InstructionSet.get_instruction_names()

func _ready():
	_add_instruction_button.add_item('Select an instruction')
	for instr in _instruction_names:
		_add_instruction_button.add_item(instr)
	_add_instruction_button.connect("item_selected", self, "_on_instruction_add")

func _on_instruction_add(index):
	if index == 0:
		return
	var instruction_name = _add_instruction_button.get_item_text(index)
	# add new instruction_src node
	var instruction_src = _instruction_src.instance() as GraphNode
	instruction_src.title = instruction_name
	add_child(instruction_src)
	 # raise() will keep this button at the bottom of the UI
	_add_instruction_button.raise()
	_add_instruction_button.selected = 0
	# get instruction config and apply to instruction_src
	var instruction = InstructionSet.get_instruction(instruction_name)
	for input in instruction.config:
		# add input option to instruction
		var instruction_src_input = _instruction_src_input.instance()
		instruction_src.add_child(instruction_src_input)
		var instruction_src_input_option = instruction_src_input.get_node("OptionButton")
		var instruction_src_input_label = instruction_src_input.get_node("Label")
		instruction_src_input_label.text = input
		# add options for this input
		for input_option in instruction.config[input]:
			instruction_src_input_option.add_item(input_option)

func serialize():
	var program = []
	for instruction_src in get_children():
		if not instruction_src is GraphNode:
			continue
		if not InstructionSet.has_instruction(instruction_src.title):
			Logger.warn('Tried to serialize non-existant instruction ' + instruction_src.title)
			continue
		var instruction = InstructionSet.get_instruction(instruction_src.title)
		var config = {}
		for instruction_src_input in instruction_src.get_children():
			var instruction_src_input_label = instruction_src_input.get_node("Label")
			var instruction_src_input_option = instruction_src_input.get_node("OptionButton")
			var selection = instruction_src_input_option.get_item_text(instruction_src_input_option.selected)
			config[instruction_src_input_label.text] = selection
		program.append({
			'instr': instruction.instr,
			'config': config
		})
	return program


