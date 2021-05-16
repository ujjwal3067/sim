extends Spatial
signal on_editor_mode_change();
export (String, "SELECT" , "TRANSALTE", "ROTATE", "SCALE") var editor_mode;

var is_in_freelook_mode = false;

# emit signal if the mode of the editor has been changed
func change_editor_mode(new_mode):
	editor_mode = new_mode;
	emit_signal("on_editor_mode_change")

func _input(event):
	get_node("Editor_Viewport").input(event)
