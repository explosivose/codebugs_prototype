extends GraphNode

class_name Process

func _ready():
	connect("close_request", self, '_on_close')
	pass

func _on_close():
	queue_free()
