extends MarginContainer

@onready var bkgmusic_check_box: CheckButton = $MarginContainer/PanelContainer/VBoxContainer/MarginContainer/TabContainer/Audio/ScrollContainer/VBoxContainer/BackgroundMusicButton/bkgmusic_CheckBox

func _ready() -> void:
	bkgmusic_check_box.button_pressed = GameManager.get_background_music_playing()

func _on_button_pressed() -> void:
	bkgmusic_check_box.button_pressed = !bkgmusic_check_box.button_pressed
	GameManager.set_background_music_playing(bkgmusic_check_box.button_pressed)

func _on_close_button_pressed() -> void:
	GameManager.back()
