extends Spatial

# the editor_controller_controller parent node
var editor_controller

signal physics_object_selected(object)

# class variables
const NORMAL_COLLISION_LAYER  = -1
const MOVE_SPEED = 2
const SHIFT_SPEED = 20
const MOUSE_SENSITIVITY = 0.05
var view_camera = null
const CAMER_MAX_ROTATION_ANGLE = 70
var send_raycast = false;

func _ready():
	editor_controller = get_parent()
	view_camera = get_node("View_Camera")

func _process(delta):
	if (Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		if(Input.get_mouse_mode()!= Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		editor_controller.is_in_freelook_mode = true # editor in the freelook mode
	else:
		if (Input.get_mouse_mode()!= Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		editor_controller.is_in_freelook_mode = false  # editor no longer in the freelook mode

	if (editor_controller.is_in_freelook_mode == true):
		process_movement(delta)

func process_movement(delta):
	var movement_vector = Vector3(0,0,0)
	var movement_speed = MOVE_SPEED  # scalar

	# freelook camera input
	if (Input.is_action_just_pressed("editor_move_backward")== true):
