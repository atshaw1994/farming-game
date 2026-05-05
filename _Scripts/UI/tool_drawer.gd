extends CanvasLayer

@onready var panel_container: PanelContainer = $PanelContainer

signal hoe_button_pressed

func show_at_position(show_position: Vector2) -> void:
	show()
	_setup_buttons() 
	await get_tree().process_frame
	var adjusted_show_position = Vector2(show_position.x - panel_container.size.x, show_position.y)
	var screen_pos = get_viewport().get_canvas_transform() * adjusted_show_position
	panel_container.global_position = screen_pos - panel_container.pivot_offset
	AudioManager.play("button_click")
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3).from(Vector2(0,1))
	tween.tween_property(panel_container, "position", screen_pos - panel_container.pivot_offset, 0.3).from(show_position)

func _setup_buttons() -> void:
	pass #TODO: Make this method when more tools are added.

func _on_hoe_button_pressed() -> void:
	hoe_button_pressed.emit()
