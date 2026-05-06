extends Node2D

func _on_go_outside_button_pressed() -> void:
	GameManager.back()

func _on_wardrobe_button_pressed() -> void:
	GameManager.change_scene("res://_Scenes/Wardrobe.tscn", true)
