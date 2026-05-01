extends Node2D

@onready var shop_container: MarginContainer = $CanvasLayer/ShopContainer
@onready var hoe_durability_bar: ProgressBar = $CanvasLayer/ActionButtonsContainer/VBoxContainer/HoeButton/HoeDurabilityBar
@onready var hoe_broken_overlay: Label = $CanvasLayer/ActionButtonsContainer/VBoxContainer/HoeButton/HoeBrokenOverlay
@onready var crop_tile_map_layer: TileMapLayer = $CropPlotTileMapLayer
@onready var decoration_tile_map_layer: TileMapLayer = $DecorationTileMapLayer


func _ready() -> void:
	# Connect global signals for hoe status
	GameManager.hoe_broken.connect(_on_hoe_broken)
	GameManager.hoe_restored.connect(_on_hoe_restored)
	# Initialize the durability bar UI 
	hoe_durability_bar.value = (GameManager.hoe_durability / 80.0) * 100

func _on_hoe_button_pressed():
	AudioManager.play("button_click")
	GameManager.flip_hoe_mode() 

func _unhandled_input(event):
	if not (event is InputEventMouseButton and event.pressed): return
	
	if event.button_index == MOUSE_BUTTON_LEFT:
		if GameManager.hoe_mode_active:
			if GameManager.hoe_durability >= 10:
				var map_pos = crop_tile_map_layer.local_to_map(crop_tile_map_layer.get_local_mouse_position()) 
				if crop_tile_map_layer.handle_hoe_action(map_pos):
					AudioManager.play("hoe")
					update_durability()
					get_viewport().set_input_as_handled()
		elif GameManager.map_edit_mode_active:
			var map_pos = decoration_tile_map_layer.local_to_map(decoration_tile_map_layer.get_local_mouse_position()) 
			if decoration_tile_map_layer.handle_fence_action(map_pos):
					AudioManager.play("button_click")
					get_viewport().set_input_as_handled()
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		if GameManager.hoe_mode_active:
			AudioManager.play("button_click_reverse")
			GameManager.flip_hoe_mode()
		elif GameManager.map_edit_mode_active:
			AudioManager.play("button_click_reverse")
			GameManager.flip_map_edit_mode()

func update_durability():
	GameManager.lower_hoe_durability()
	# Sync the UI bar with the new durability value [cite: 74]
	hoe_durability_bar.value = (GameManager.hoe_durability / 80.0) * 100

func _on_hoe_broken() -> void:
	hoe_broken_overlay.show()

func _on_hoe_restored() -> void:
	hoe_broken_overlay.hide()
	hoe_durability_bar.value = 100

func _on_store_button_pressed() -> void:
	AudioManager.play("button_click")
	GameManager.set_shop_open(true)
	shop_container.open()

func _on_decoration_button_pressed() -> void:
	AudioManager.play("button_click")
	GameManager.flip_map_edit_mode()
