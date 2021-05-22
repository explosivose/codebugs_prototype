extends Camera2D

var _dragging = false
var _drag_from_mouse_pos: Vector2
var _drag_from_camera_pos: Vector2

const MIN_ZOOM = 0.5
const MAX_ZOOM = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		# Handle camera drag toggling
		if event.button_index == BUTTON_RIGHT:
			if not _dragging and event.pressed:
				Logger.trace('Start to drag camera')
				_dragging = true
				_drag_from_mouse_pos = event.position
				_drag_from_camera_pos = position
			elif _dragging and not event.pressed:
				Logger.trace('Stop dragging camera')
				_dragging = false
		if event.button_index == BUTTON_WHEEL_UP:
			zoom.x = max(zoom.x - 0.1, MIN_ZOOM)
			zoom.y = max(zoom.y - 0.1, MIN_ZOOM)
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom.x = min(zoom.x + 0.1, MAX_ZOOM)
			zoom.y = min(zoom.y + 0.1, MAX_ZOOM)
	# Handle camera dragging
	if event is InputEventMouseMotion and _dragging:
		position = _drag_from_camera_pos + zoom * (_drag_from_mouse_pos - event.position)
