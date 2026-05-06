extends Node

var player = null
var hoe_mode_active: bool = false
var map_edit_mode_active: bool = false
var shop_open: bool = false
var hoe_durability: int = 80

var total_gold: int = 100: #TODO: set this back to 4
	set(value):
		total_gold = value
		money_changed.emit(total_gold)

var scene_stack = []

signal hoe_mode_switched
signal map_edit_mode_switched
signal money_changed(new_amount)
signal hoe_broken
signal hoe_restored
signal plot_hoed

func flip_hoe_mode() -> void:
	hoe_mode_active = !hoe_mode_active
	hoe_mode_switched.emit()

func flip_map_edit_mode() -> void:
	map_edit_mode_active = !map_edit_mode_active
	map_edit_mode_switched.emit()

func set_shop_open(value: bool) -> void:
	if value:
		shop_open = value
		hoe_mode_active = false
		map_edit_mode_active = false
		hoe_mode_switched.emit()
		map_edit_mode_switched.emit()

func can_afford(amount: int) -> bool:
	return total_gold >= amount

func spend_money(amount: int) -> void:
	if can_afford(amount):
		total_gold -= amount
		AudioManager.play("purchase")

func lower_hoe_durability() -> void:
	hoe_durability -= 10
	
	if hoe_durability <= 0:
		hoe_durability = 0
		hoe_broken.emit()
		hoe_mode_active = false
	
	plot_hoed.emit()

func reset_hoe_durability() -> void:
	hoe_durability = 80
	hoe_restored.emit()

func change_scene(scene_path: String, keep_current: bool = false):
	var current_scene = get_tree().current_scene
	if current_scene:
		if keep_current:
			scene_stack.push_back(current_scene.scene_file_path)
		current_scene.queue_free()
	
	var next_scene = load(scene_path)
	get_tree().root.add_child(next_scene.instantiate())
	get_tree().current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

func back():
	if scene_stack.is_empty():
		return

	var previous_scene_path = scene_stack.pop_back()
	change_scene(previous_scene_path)
