extends TileMapLayer

@export var fence_left_scene: PackedScene
@export var fence_right_scene: PackedScene

@onready var ground_layer: TileMapLayer = $"../CropPlotTileMapLayer"

var occupied_tiles = {} 
var ghost_fence: Node2D 
var currently_highlighted_plot: Node2D = null 
var direction: String = "left"

func _ready():
	if fence_left_scene and fence_right_scene:
		# Create the translucent "ghost" for the isometric cursor [cite: 79]
		ghost_fence = fence_left_scene.instantiate()
		ghost_fence.modulate = Color(1, 1, 1, 0.5)
		ghost_fence.visible = false
		add_child(ghost_fence)
	
	GameManager.map_edit_mode_switched.connect(_on_map_edit_mode_switched)

func _process(_delta):
	if ghost_fence and GameManager.map_edit_mode_active:
		update_ghost_position()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if GameManager.map_edit_mode_active:
				swap_orientation()
				get_viewport().set_input_as_handled()

func swap_orientation():
	if direction == "left": direction = "right"
	else: direction = "left"
	print("direction = " + direction)
	
	# Clean up old ghost[cite: 8]
	if ghost_fence:
		ghost_fence.queue_free()
	
	# Instantiate the new ghost based on orientation
	var scene_to_use = fence_right_scene if direction == "right" else fence_left_scene
	ghost_fence = scene_to_use.instantiate()
	ghost_fence.modulate = Color(1, 1, 1, 0.5)
	add_child(ghost_fence)

func update_ghost_position():
	var map_pos = local_to_map(get_local_mouse_position())
	ghost_fence.position = map_to_local(map_pos)
	
	# Reset highlights for previously hovered plots [cite: 79]
	if currently_highlighted_plot:
		currently_highlighted_plot.modulate = Color(1, 1, 1, 1)
		currently_highlighted_plot = null
	
	if occupied_tiles.has(map_pos):
		ghost_fence.visible = false
		var existing_plot = occupied_tiles[map_pos]
		# Highlight red if hovering over an existing plot (deletion mode) [cite: 79]
		existing_plot.modulate = Color(1, 0.3, 0.3, 1) 
		currently_highlighted_plot = existing_plot
	else:
		# Only show ghost if the mouse is over a valid tile in the atlas 
		var has_ground = ground_layer.get_cell_source_id(map_pos) != -1
		ghost_fence.visible = has_ground
		ghost_fence.modulate = Color(1, 1, 1, 0.5)

func handle_fence_action(map_pos: Vector2i) -> bool:
	if ground_layer.get_cell_source_id(map_pos) == -1:
		return false
	
	if occupied_tiles.has(map_pos):
		var plot_to_remove = occupied_tiles[map_pos]
		occupied_tiles.erase(map_pos)
		plot_to_remove.queue_free()
		return true 
	else:
		# Use the current orientation for placement
		var scene_to_use = fence_right_scene if direction == "right" else fence_left_scene
		var new_fence = scene_to_use.instantiate()
		add_child(new_fence)
		new_fence.position = map_to_local(map_pos)
		occupied_tiles[map_pos] = new_fence
		return true

func _on_map_edit_mode_switched():
	if not GameManager.map_edit_mode_active and ghost_fence:
		ghost_fence.visible = false
	elif GameManager.map_edit_mode_active and ghost_fence:
		ghost_fence.visible = true
