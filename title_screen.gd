extends Control

#-------------------------------------------------------------------------------
#------------------------------ CORE FUNCTIONS ---------------------------------
#-------------------------------------------------------------------------------

# Constructor when title screen initialised
func _ready():
	Global.size = 0
	Global.adjacent = 4
	Global.power = 4
	Global.force_euclidean = false
	$HSlider/Label.text = "Power = " + str(4)

# Start game when start button pressed
func _on_start_button_pressed() -> void:
	Global.initiate()
	get_tree().change_scene_to_file("res://game.tscn")

# Change power value based off slider
func _on_h_slider_value_changed(value: float) -> void:
	Global.power = int(value)
	$HSlider/Label.text = "Power = " + str(int(value))

# Change grid neighbours based off option selected
func _on_option_button_item_selected(index: int) -> void:
	if index == 0:
		Global.adjacent = 2
	elif index == 1:
		Global.adjacent = 3
	elif index == 2:
		Global.adjacent = 4
	elif index == 3:
		Global.adjacent = 6

# Change grid size based off spinning box selector
func _on_spin_box_value_changed(value: float) -> void:
	Global.size = int(value)


func _on_check_button_toggled(toggled_on: bool) -> void:
	Global.force_euclidean = toggled_on
