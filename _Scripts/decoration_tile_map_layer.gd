extends TileMapLayer

@export var fence_SW_scene: PackedScene
@export var fence_SE_scene: PackedScene
@export var fence_NE_scene: PackedScene
@export var fence_NW_scene: PackedScene

@onready var ground_layer: TileMapLayer = $"../CropPlotTileMapLayer"

var occupied_tiles = {} 
var ghost_fence: Node2D 
var currently_highlighted_plot: Node2D = null 
var direction: String = "SW"

func _ready():
	if fence_SW_scene:
		# Create the translucent "ghost" for the isometric cursor
		ghost_fence = fence_SW_scene.instantiate()
		ghost_fence.modulate = Color(1, 1, 1, 0.5)
		ghost_fence.visible = false
		add_child(ghost_fence)
	
	GameManager.map_edit_mode_switched.connect(_on_map_edit_mode_switched)

func _process(_delta):
	if ghost_fence and GameManager.map_edit_mode_active:
		update_ghost_position()

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if GameManager.map_edit_mode_active:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					swap_orientation("up")
					get_viewport().set_input_as_handled()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					swap_orientation("dn")
					get_viewport().set_input_as_handled()

func swap_orientation(mouse_wheel_direction:String):
	if mouse_wheel_direction == "up":
		if direction == "SW": direction = "SE"
		elif direction == "SE": direction = "NE"
		elif direction == "NE": direction = "NW"
		else: direction = "SW"
	if mouse_wheel_direction == "dn":
		if direction == "SW": direction = "NW"
		elif direction == "NW": direction = "NE"
		elif direction == "NE": direction = "SE"
		else: direction = "SW"
	
	# Clean up old ghost
	if ghost_fence:
		ghost_fence.queue_free()
	
	# Instantiate the new ghost based on orientation
	var scene_to_use
	if direction == "SW": scene_to_use = fence_SW_scene
	elif direction == "SE": scene_to_use = fence_SE_scene
	elif direction == "NW": scene_to_use = fence_NW_scene
	else: scene_to_use = fence_NE_scene
	ghost_fence = scene_to_use.instantiate()
	ghost_fence.modulate = Color(1, 1, 1, 0.5)
	add_child(ghost_fence)

func update_ghost_position():
	var map_pos = local_to_map(get_local_mouse_position())
	ghost_fence.position = map_to_local(map_pos)
	
	# Reset highlights for previously hovered plots
	if currently_highlighted_plot:
		currently_highlighted_plot.modulate = Color(1, 1, 1, 1)
		currently_highlighted_plot = null
	
	if occupied_tiles.has(map_pos):
		ghost_fence.visible = false
		var existing_plot = occupied_tiles[map_pos]
		# Highlight red if hovering over an existing plot (deletion mode)
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
		var scene_to_use
		if direction == "SW": scene_to_use = fence_SW_scene
		elif direction == "SE": scene_to_use = fence_SE_scene
		elif direction == "NW": scene_to_use = fence_NW_scene
		else: scene_to_use = fence_NE_scene
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
