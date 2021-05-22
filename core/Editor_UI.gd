extends Control

var editor_controller
func _ready():
	editor_controller = get_parent()
	# when ever the button is pressed it will emit the signal to change the  editor mode
	get_node("Gizmo_Selection/HBoxContainer/Button_Select").connect("pressed", self, "on_mode_button_pressed", ["SELECT"]);
	get_node("Gizmo_Selection/HBoxContainer/Button_Translate").connect("pressed", self, "on_mode_button_pressed", ["TRANSLATE"]);
	get_node("Gizmo_Selection/HBoxContainer/Button_Rotate").connect("pressed", self, "on_mode_button_pressed", ["ROTATE"]);
	get_node("Gizmo_Selection/HBoxContainer/Button_Scale").connect("pressed", self, "on_mode_button_pressed", ["SCALE"]);

func on_mode_button_pressed(new_mode):
	editor_controller.change_editor_mode(new_mode)
