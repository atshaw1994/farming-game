extends StaticBody2D

@onready var crop_inventory: CanvasLayer = $CropInventory

var current_crop = null
var clicked_location = null

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if GameManager.hoe_mode_active: return # STOP if the Hoe is active. We don't want to plant while tilling.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled() 
		clicked_location = get_global_mouse_position()
		if crop_inventory.visible: crop_inventory.hide()
		else:
			PlayerManager.target_position = global_position
			PlayerManager.current_target_plot = self 
			
			if not PlayerManager.player_arrived_at_plot.is_connected(_open_ui_after_move):
				PlayerManager.player_arrived_at_plot.connect(_open_ui_after_move, CONNECT_ONE_SHOT)

func _open_ui_after_move(arrived_target) -> void:
	if arrived_target == self:
		if current_crop == null:
			for connection in crop_inventory.seed_selected.get_connections():
				crop_inventory.seed_selected.disconnect(connection.callable)
			crop_inventory.seed_selected.connect(_on_seed_selected, CONNECT_ONE_SHOT)
			crop_inventory.show_at_position(global_position)
		elif current_crop.current_stage == current_crop.Stage.FULL:
			harvest()
		elif current_crop.current_stage == current_crop.Stage.WILTED:
			current_crop.queue_free()
			current_crop = null

func _on_seed_selected(type: String) -> void:
	var new_crop = ShopManager.create_scene_by_name(type)
	if new_crop:
		plant_crop(new_crop)

func plant_crop(new_crop) -> void:
	add_child(new_crop)
	current_crop = new_crop

func harvest() -> void:
	if current_crop:
		AudioManager.play("harvest")
		PlayerManager.harvest_crop(current_crop)
		current_crop.play_harvest_animation()
		current_crop = null

func restore_crop(p_crop_type: ShopManager.CropType, p_stage: int) -> void:
	var data = ShopManager.shop_registry[ShopManager.Category.CROPS][p_crop_type]
	var new_crop = data.scene.instantiate()
	new_crop._restore_stage = p_stage
	plant_crop(new_crop)

func get_interaction_distance() -> float:
	return (get_plot_width() / 2.0) + 4.0

# Dynamic helper to get total world width
func get_plot_width() -> float:
	var shape = $CollisionShape2D.polygon
	if shape is Polygon2D:
		return shape.size.x * scale.x
	return 32.0 * scale.x # Fallback to default sprite size
