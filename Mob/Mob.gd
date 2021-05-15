extends RigidBody2D

export var min_speed = 150
export var max_speed = 250

# Called when the node enters the scene tree for the first time.
func _ready():
	var anim = $AnimatedSprite as AnimatedSprite
	var mob_types = anim.frames.get_animation_names()
	anim.animation = mob_types[randi() % mob_types.size()]

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
