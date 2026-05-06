extends StaticBody2D

@export var door_open_texture: Texture2D
@export var door_closed_texture: Texture2D
@export_file("*.tscn") var inside_house_scene_path: String

@onready var door_node: Sprite2D = $sprites/DoorNode

var door_open: bool = false

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		door_open = !door_open
		door_node.texture = door_open_texture if door_open else door_closed_texture
		if door_open and inside_house_scene_path:
			await get_tree().create_timer(0.2).timeout
			GameManager.change_scene(inside_house_scene_path, true)
