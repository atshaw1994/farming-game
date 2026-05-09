extends Control

@export var Level1: PackedScene

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var male_button: Button = $CanvasLayer/MaleButton

func _on_play_button_pressed() -> void:
	if Level1:
		get_tree().change_scene_to_packed(Level1)
	else:
		push_error("Level1 scene is not assigned in the Inspector!")

func _on_options_button_pressed() -> void:
	GameManager.change_scene("res://_Prefabs/UI/settings_menu.tscn", true)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_male_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		animated_sprite_2d.sprite_frames = GameManager.MALE_FRAMES
		animated_sprite_2d.play("idle_right")
		PlayerManager.set_gender("male")

func _on_female_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		animated_sprite_2d.sprite_frames = GameManager.FEMALE_FRAMES
		animated_sprite_2d.play("idle_right")
		PlayerManager.set_gender("female")
