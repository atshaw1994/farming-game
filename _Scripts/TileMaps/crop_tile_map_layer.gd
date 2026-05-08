extends TileMapLayer

@export var crop_plot_scene: PackedScene
var occupied_tiles = {} 
var ghost_plot: Node2D 
var currently_highlighted_plot: Node2D = null 

func _ready() -> void:
	add_to_group("crop_layer")
	if crop_plot_scene:
		# Create the translucent "ghost" for the isometric cursor [cite: 79]
		ghost_plot = crop_plot_scene.instantiate()
		ghost_plot.modulate = Color(1, 1, 1, 0.5)
		ghost_plot.visible = false
		add_child(ghost_plot)
	
	GameManager.hoe_mode_switched.connect(_on_hoe_mode_switched)
	restore_state()

func _process(_delta) -> void:
	if ghost_plot and GameManager.hoe_mode_active:
		update_ghost_position()

func update_ghost_position() -> void:
	var map_pos = local_to_map(get_local_mouse_position())
	ghost_plot.position = map_to_local(map_pos)
	
	# Reset highlights for previously hovered plots [cite: 79]
	if currently_highlighted_plot:
		currently_highlighted_plot.modulate = Color(1, 1, 1, 1)
		currently_highlighted_plot = null
	
	if occupied_tiles.has(map_pos):
		ghost_plot.visible = false
		var existing_plot = occupied_tiles[map_pos]
		# Highlight red if hovering over an existing plot (deletion mode) [cite: 79]
		existing_plot.modulate = Color(1, 0.3, 0.3, 1) 
		currently_highlighted_plot = existing_plot
	else:
		# Only show ghost if the mouse is over a valid tile in the atlas 
		ghost_plot.visible = get_cell_source_id(map_pos) != -1
		ghost_plot.modulate = Color(1, 1, 1, 0.5)

func handle_hoe_action(map_pos: Vector2i) -> bool:
	# Ignore clicks on empty space outside the map 
	if get_cell_source_id(map_pos) == -1:
		return false
		
	if occupied_tiles.has(map_pos):
		var plot_to_remove = occupied_tiles[map_pos]
		occupied_tiles.erase(map_pos)
		plot_to_remove.queue_free()
		return true 
	else:
		var new_crop = crop_plot_scene.instantiate()
		add_child(new_crop)
		GameManager.lower_hoe_durability()
		# Snap exactly to the center of the isometric tile 
		new_crop.position = map_to_local(map_pos) 
		occupied_tiles[map_pos] = new_crop
		return true

func _on_hoe_mode_switched() -> void:
	if not GameManager.hoe_mode_active and ghost_plot:
		ghost_plot.visible = false

func save_state() -> void:
	GameManager.crop_layer_state.clear()
	for map_pos in occupied_tiles:
		var plot = occupied_tiles[map_pos]
		var entry = { "pos": map_pos }
		if plot.current_crop != null:
			entry["crop_type"] = plot.current_crop.crop_type
			entry["crop_stage"] = plot.current_crop.current_stage
		GameManager.crop_layer_state.append(entry)

func restore_state() -> void:
	if GameManager.crop_layer_state.is_empty():
		return
	for entry in GameManager.crop_layer_state:
		var map_pos: Vector2i = entry.pos
		var new_plot = crop_plot_scene.instantiate()
		add_child(new_plot)
		new_plot.position = map_to_local(map_pos)
		occupied_tiles[map_pos] = new_plot
		if entry.has("crop_type"):
			new_plot.restore_crop(entry.crop_type, entry.crop_stage)
	GameManager.crop_layer_state.clear()
