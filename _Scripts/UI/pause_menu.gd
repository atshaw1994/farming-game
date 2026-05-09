extends MarginContainer

@onready var are_you_sure_container: PanelContainer = $AreYouSureContainer

func _ready() -> void:
	hide()

func _on_resume_button_pressed() -> void:
	hide()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_reset_button_pressed() -> void:
	are_you_sure_container.show()

func _on_accept_reset_button_pressed() -> void:
	GameManager.reset_crop_data()
	hide()
	are_you_sure_container.hide()

func _on_decline_reset_button_pressed() -> void:
	are_you_sure_container.hide()

func _on_options_button_pressed() -> void:
	GameManager.change_scene("res://_Prefabs/UI/settings_menu.tscn", true)
