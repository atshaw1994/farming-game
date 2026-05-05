extends Node

var player = null
var hoe_mode_active: bool = false
var map_edit_mode_active: bool = false
var shop_open: bool = false
var hoe_durability: int = 80
var total_gold: int = 4:
	set(value):
		total_gold = value
		money_changed.emit(total_gold)

signal hoe_mode_switched
signal map_edit_mode_switched
signal money_changed(new_amount)
signal hoe_broken
signal hoe_restored

func flip_hoe_mode() -> void:
	hoe_mode_active = !hoe_mode_active
	hoe_mode_switched.emit()
	print("hoe mode: " + str(hoe_mode_active))

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

func reset_hoe_durability() -> void:
	hoe_durability = 80
	hoe_restored.emit()
