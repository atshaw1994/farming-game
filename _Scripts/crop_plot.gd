extends StaticBody2D

@export var wheat_scene: PackedScene
@export var potato_scene: PackedScene
@export var tomato_scene: PackedScene

var current_crop = null
var inventory_ui = null
var clicked_location = null
var player = null

func _ready():
	# 1. Find the player node in the scene tree
	player = get_tree().root.find_child("Player", true, false)
	if player:
		# 2. Find the Inventory child inside the Player
		inventory_ui = player.find_child("Inventory", true, false)

func _on_input_event(_viewport, event, _shape_idx):
	# 1. STOP if the Hoe is active. We don't want to plant while tilling.
	if GameManager.hoe_mode_active: return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Prevent the click from "falling through" to the map or player movement
		get_viewport().set_input_as_handled()
		
		clicked_location = get_global_mouse_position()
		
		if inventory_ui and inventory_ui.visible: inventory_ui.hide()
		else:
			if player:
				# Use global_position since the plot is now a child of the TileMap
				player.target_position = global_position
				player.current_target_plot = self 
				
				if player.has_signal("arrived_at_plot"):
					if player.arrived_at_plot.is_connected(_open_ui_after_move):
						player.arrived_at_plot.disconnect(_open_ui_after_move)
					player.arrived_at_plot.connect(_open_ui_after_move, CONNECT_ONE_SHOT)

func _open_ui_after_move():
	if current_crop == null:
		for connection in inventory_ui.seed_selected.get_connections():
			inventory_ui.seed_selected.disconnect(connection.callable)
		# 1. Before showing the UI, connect the signal
		# Use CONNECT_ONE_SHOT so it automatically disconnects after planting once
		inventory_ui.seed_selected.connect(_on_seed_selected, CONNECT_ONE_SHOT)
		# 2. Show the UI as normal
		inventory_ui.show_at_position(global_position)
	elif current_crop.current_stage == current_crop.Stage.FULL:
		harvest()
	elif current_crop.current_stage == current_crop.Stage.WILTED:
		current_crop.queue_free()
		current_crop = null

func _on_seed_selected(type):
	var new_crop = null
	if type == "wheat":
		new_crop = wheat_scene.instantiate()
		new_crop.name = type
		plant_crop(new_crop)
	if type == "potato":
		new_crop = potato_scene.instantiate()
		new_crop.name = type
		plant_crop(new_crop)
	if type == "tomato":
		new_crop = tomato_scene.instantiate()
		new_crop.name = type
		plant_crop(new_crop)

func plant_crop(new_crop):
	new_crop.position.y = -48
	add_child(new_crop)
	current_crop = new_crop

func harvest():
	if player and current_crop:
		AudioManager.play("harvest")
		player.harvest_crop(current_crop)
		var tween = get_tree().create_tween()
		tween.set_parallel(true)
		tween.tween_property(current_crop, "position", current_crop.position + Vector2(0, -40), 0.2)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(current_crop, "modulate:a", 0.0, 0.2)
		tween.tween_property(current_crop, "scale", Vector2(1, 1), 0.2)\
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.chain().tween_callback(current_crop.queue_free)
		current_crop = null

func get_interaction_distance() -> float:
	return (get_plot_width() / 2.0) + 4.0

# Dynamic helper to get total world width
func get_plot_width() -> float:
	var shape = $CollisionShape2D.polygon
	if shape is Polygon2D:
		return shape.size.x * scale.x
	return 32.0 * scale.x # Fallback to default sprite size
