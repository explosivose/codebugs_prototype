extends Node
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

# _config is the 'schema' for instruction config
# this is a useful definition for GUI (instruction source) to provide
# valid options to the player when they use this instruction
var _config = {
	'dance': {
		'instr': Dance,
		'config': {
			'duration': ['2', '4', '8']
		}
	},
	'move_to': {
		'instr': MoveTo,
		'config': {
			'destination': ['random_location', 'nearest_cake']
		}
	}
}

func get_instruction_names() -> PoolStringArray:
	return _config.keys() as PoolStringArray

func get_instruction(instruction_name: String) -> Dictionary:
	return _config[instruction_name]

func has_instruction(instruction_name: String) -> bool:
	return _config.has(instruction_name)
