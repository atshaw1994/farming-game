extends Control

@export var Level1: PackedScene


func _on_play_button_pressed() -> void:
	if Level1:
		get_tree().change_scene_to_packed(Level1)
	else:
		push_error("Level1 scene is not assigned in the Inspector!")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
