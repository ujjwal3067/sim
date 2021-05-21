extends Spatial
var editor_controller;
 
signal physics_object_selected(object);
 
const NORMAL_COLLISION_LAYER = 1;
 
const CONTROL_SPEED = 2;
const MOVE_SPEED = 10;
const SHIFT_SPEED = 20;
 
const MOUSE_SENSITIVTY = 0.05;
 
var view_camera = null;
 
const CAMERA_MAX_ROTATION_ANGLE = 70;
 
var send_raycast = false;
 
 
func _ready():
	editor_controller = get_parent();
	view_camera = get_node("View_Camera");
 
 
func _process(delta):

	# checking if the right mouse button is pressed and held

	if (Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

		# switch the editor mode to freelook for freelook camera movement.
		editor_controller.is_in_freelook_mode = true;
	
	else:
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		
		editor_controller.is_in_freelook_mode = false;
	
	if (editor_controller.is_in_freelook_mode == true):
		process_movement(delta);
 

# This process takes care of the movment during the freelook mode.
func process_movement(delta):
	var movement_vector = Vector3(0, 0, 0);
	var movement_speed = MOVE_SPEED;

	# W = editor_move_forward
	# S = editor_move_backward
	# D = editor_move_right
	# L = editor_move_left
	#
	#NOTE : camera node faces negatice z axis that means to move forward you have add negative vector

	if (Input.is_action_pressed("editor_move_forward") == true):
		movement_vector.z = 1;
	elif (Input.is_action_pressed("editor_move_backward") == true):
		movement_vector.z -= 1;
	if (Input.is_action_pressed("editor_move_right") == true):
		movement_vector.x = 1;
	elif (Input.is_action_pressed("editor_move_left") == true):
		movement_vector.x = -1;

	# checks if the shift key is held down or not
	if (Input.is_key_pressed(KEY_SHIFT)):
		movement_speed = SHIFT_SPEED;
	elif (Input.is_key_pressed(KEY_CONTROL)):
		movement_speed = CONTROL_SPEED;

	# add the new vectors to the global transform of the camera
	# global_transform.origin = camera global transform
	global_transform.origin += -view_camera.global_transform.basis.z * movement_vector.z * movement_speed * delta;
	
	global_transform.origin += view_camera.global_transform.basis.x * movement_vector.x * movement_speed * delta;

 
func _unhandled_input(event):
	if (editor_controller.is_in_freelook_mode == true):
		if (event is InputEventMouseMotion):
			# store the current rotation of the camera
			var camera_rotation = view_camera.rotation_degrees;

			# NOTE : event.realtive gives the position of the mouse relative to last position ( position in the last frame ) of type Vector2
			camera_rotation.x = clamp(camera_rotation.x + (-event.relative.y * MOUSE_SENSITIVTY), -CAMERA_MAX_ROTATION_ANGLE, CAMERA_MAX_ROTATION_ANGLE);
			
			# rotation_degrees.y += -event.relative.x * MOUSE_SENSITIVTY;
			camera_rotation.y += -event.relative.x * MOUSE_SENSITIVTY;
			
			view_camera.rotation_degrees = camera_rotation;
	
	else:
		# SELECT mode
		# This mode is used for selecting the object in the viewport

		if (event is InputEventMouseButton):
			if (event.button_index == BUTTON_LEFT and event.pressed == true):
				if (editor_controller.editor_mode == "SELECT"):
					send_raycast = true;
 
 
func _physics_process(delta):

	# send_raycast is only true when editor is in SELECT MODE
	if (send_raycast == true):
		# we send out single raycast per mouse click so turn it off
		send_raycast = false;
		var selected_node = null;
		var space_state = get_world().direct_space_state; # don't access this method out side physics process thread
		
		var raycast_from = view_camera.project_ray_origin(get_tree().root.get_mouse_position())
		var raycast_to = raycast_from + view_camera.project_ray_normal(get_tree().root.get_mouse_position()) * 100;

		# NORMAL_COLLISON_LAYER is collision mask
		# output of intersect query is a dictionary
		var result = space_state.intersect_ray(raycast_from, raycast_to, [self], NORMAL_COLLISION_LAYER);

		if (result.size() > 0):
			selected_node = result.collider;

		# emit signal also pass the collider details of the object selected
		# null will be emitted if no node are found by the raycast.
		emit_signal("physics_object_selected", selected_node);
