extends StaticBody2D

var current_crop = null
var clicked_location = null
var player_crop_inventory = null
var player_decoration_inventory = null

func _ready() -> void:
	if GameManager.player:
		# 2. Find the Inventory child inside the Player
		player_crop_inventory = GameManager.player.find_child("CropInventory", true, false)

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if GameManager.hoe_mode_active: return # STOP if the Hoe is active. We don't want to plant while tilling.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled() # Prevent the click from "falling through" to the map or player movement
		clicked_location = get_global_mouse_position()
		if player_crop_inventory and player_crop_inventory.visible: player_crop_inventory.hide()
		else:
			if GameManager.player:
				# Use global_position since the plot is now a child of the TileMap
				GameManager.player.target_position = global_position
				GameManager.player.current_target_plot = self 
				
				if GameManager.player.has_signal("arrived_at_plot"):
					if GameManager.player.arrived_at_plot.is_connected(_open_ui_after_move):
						GameManager.player.arrived_at_plot.disconnect(_open_ui_after_move)
					GameManager.player.arrived_at_plot.connect(_open_ui_after_move, CONNECT_ONE_SHOT)

func _open_ui_after_move() -> void:
	if current_crop == null:
		for connection in player_crop_inventory.seed_selected.get_connections():
			player_crop_inventory.seed_selected.disconnect(connection.callable)
		# 1. Before showing the UI, connect the signal
		# Use CONNECT_ONE_SHOT so it automatically disconnects after planting once
		player_crop_inventory.seed_selected.connect(_on_seed_selected, CONNECT_ONE_SHOT)
		# 2. Show the UI as normal
		player_crop_inventory.show_at_position(global_position)
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
	if GameManager.player and current_crop:
		AudioManager.play("harvest")
		GameManager.player.harvest_crop(current_crop)
		current_crop.play_harvest_animation()
		current_crop = null

func get_interaction_distance() -> float:
	return (get_plot_width() / 2.0) + 4.0

# Dynamic helper to get total world width
func get_plot_width() -> float:
	var shape = $CollisionShape2D.polygon
	if shape is Polygon2D:
		return shape.size.x * scale.x
	return 32.0 * scale.x # Fallback to default sprite size
