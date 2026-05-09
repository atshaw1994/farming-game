extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if PlayerManager.gender == "male":
		animated_sprite_2d.sprite_frames = GameManager.MALE_FRAMES
	else:
		animated_sprite_2d.sprite_frames = GameManager.FEMALE_FRAMES
	animated_sprite_2d.play("idle_right")

func _on_back_button_pressed() -> void:
	GameManager.back()

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
