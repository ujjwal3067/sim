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
	if (Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
		
		editor_controller.is_in_freelook_mode = true;
	
	else:
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		
		editor_controller.is_in_freelook_mode = false;
	
	if (editor_controller.is_in_freelook_mode == true):
		process_movement(delta);
 
 
func process_movement(delta):
	var movement_vector = Vector3(0, 0, 0);
	var movement_speed = MOVE_SPEED;
	
	if (Input.is_action_pressed("editor_move_forward") == true):
		movement_vector.z = 1;
	elif (Input.is_action_pressed("editor_move_backward") == true):
		movement_vector.z -= 1;
	
	if (Input.is_action_pressed("editor_move_right") == true):
		movement_vector.x = 1;
	elif (Input.is_action_pressed("editor_move_left") == true):
		movement_vector.x = -1;
	
	if (Input.is_key_pressed(KEY_SHIFT)):
		movement_speed = SHIFT_SPEED;
	elif (Input.is_key_pressed(KEY_CONTROL)):
		movement_speed = CONTROL_SPEED;
	
	global_transform.origin += -view_camera.global_transform.basis.z * movement_vector.z * movement_speed * delta;
	
	global_transform.origin += view_camera.global_transform.basis.x * movement_vector.x * movement_speed * delta;
 
 
func _unhandled_input(event):
	if (editor_controller.is_in_freelook_mode == true):
		if (event is InputEventMouseMotion):
			var camera_rotation = view_camera.rotation_degrees;
			
			camera_rotation.x = clamp(camera_rotation.x + (-event.relative.y * MOUSE_SENSITIVTY), -CAMERA_MAX_ROTATION_ANGLE, CAMERA_MAX_ROTATION_ANGLE);
			
			rotation_degrees.y += -event.relative.x * MOUSE_SENSITIVTY;
			
			view_camera.rotation_degrees = camera_rotation;
	
	else:
		if (event is InputEventMouseButton):
			if (event.button_index == BUTTON_LEFT and event.pressed == true):
				if (editor_controller.editor_mode == "SELECT"):
					send_raycast = true;
 
 
func _physics_process(delta):
	if (send_raycast == true):
		send_raycast = false;
		
		var selected_node = null;
		
		var space_state = get_world().direct_space_state;
		
		var raycast_from = view_camera.project_ray_origin(get_tree().root.get_mouse_position())
		var raycast_to = raycast_from + view_camera.project_ray_normal(get_tree().root.get_mouse_position()) * 100;
		
		var result = space_state.intersect_ray(raycast_from, raycast_to, [self], NORMAL_COLLISION_LAYER);
		
		if (result.size() > 0):
			selected_node = result.collider;
		
		emit_signal("physics_object_selected", selected_node);
