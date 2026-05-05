extends Node2D

@onready var shop_container: MarginContainer = $CanvasLayer/ShopContainer
@onready var crop_tile_map_layer: TileMapLayer = $CropPlotTileMapLayer
@onready var decoration_tile_map_layer: TileMapLayer = $DecorationTileMapLayer
@onready var player_decoration_inventory: CanvasLayer = $Player/DecorationInventory
@onready var decoration_button: Button = $CanvasLayer/ActionButtonsContainer/VBoxContainer/DecorationButton
@onready var player: CharacterBody2D = $Player
@onready var tool_drawer: CanvasLayer = $ToolDrawer
@onready var tools_button: Button = $CanvasLayer/ActionButtonsContainer/VBoxContainer/ToolsButton

signal plot_hoed

func _ready() -> void:
	player_decoration_inventory.item_selected.connect(_on_item_selected)
	tool_drawer.hoe_button_pressed.connect(_on_hoe_button_pressed)

func _unhandled_input(event) -> void:
	if not (event is InputEventMouseButton and event.pressed): return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		if GameManager.hoe_mode_active:
			if GameManager.hoe_durability >= 10:
				var map_pos = crop_tile_map_layer.local_to_map(crop_tile_map_layer.get_local_mouse_position()) 
				if crop_tile_map_layer.handle_hoe_action(map_pos):
					AudioManager.play("hoe")
					plot_hoed.emit()
					get_viewport().set_input_as_handled()
		elif GameManager.map_edit_mode_active:
			var map_pos = decoration_tile_map_layer.local_to_map(decoration_tile_map_layer.get_local_mouse_position()) 
			if decoration_tile_map_layer.handle_decoration_action(map_pos):
					AudioManager.play("button_click")
					get_viewport().set_input_as_handled()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if GameManager.hoe_mode_active:
			AudioManager.play("button_click_reverse")
			GameManager.flip_hoe_mode()
		elif GameManager.map_edit_mode_active:
			AudioManager.play("button_click_reverse")
			GameManager.flip_map_edit_mode()

func _on_store_button_pressed() -> void:
	AudioManager.play("button_click")
	GameManager.set_shop_open(true)
	shop_container.show()

func _on_hoe_button_pressed() -> void:
	AudioManager.play("button_click")
	GameManager.flip_hoe_mode() 

func _on_item_selected(selected_type: String) -> void:
	decoration_tile_map_layer.type = selected_type

func place_item(new_item) -> void:
	new_item.position.y = -48
	add_child(new_item)

func _on_tools_button_toggled(toggled_on: bool) -> void:
	if toggled_on: tool_drawer.show_at_position(tools_button.global_position)
	else: tool_drawer.hide()

func _on_decoration_button_toggled(toggled_on: bool) -> void:
	if toggled_on: player_decoration_inventory.show_at_position(decoration_button.global_position)
	else: player_decoration_inventory.hide()
