extends Node

var hoe_mode_active: bool = false
var map_edit_mode_active: bool = false
var shop_open: bool = false
var hoe_durability: int = 80
var total_gold: int = 4:
	set(value):
		total_gold = value
		money_changed.emit(total_gold)
enum CropType { WHEAT, POTATO, TOMATO }
var crop_data = {
	CropType.WHEAT: {
		"name": "wheat",
		"buy_price": 2,
		"sell_price": 4,
		"growth_time": 10.0,
		"wilt_time": 10.0,
		"icon": preload("res://_Sprites/Wheat/6 - Wheat Inventory.png")
	},
	CropType.POTATO: {
		"name": "potato",
		"buy_price": 4,
		"sell_price": 6,
		"growth_time": 30.0,
		"wilt_time": 15.0,
		"icon": preload("res://_Sprites/Potato/6 - Potato Inventory.png")
	},
	CropType.TOMATO: {
		"name": "tomato",
		"buy_price": 8,
		"sell_price": 10,
		"growth_time": 60.0,
		"wilt_time": 60.0,
		"icon": preload("res://_Sprites/Tomato/6 - Tomato Inventory.png")
	}
}

signal hoe_mode_switched
signal map_edit_mode_switched
signal money_changed(new_amount)
signal hoe_broken
signal hoe_restored

func flip_hoe_mode() -> void:
	hoe_mode_active = !hoe_mode_active
	hoe_mode_switched.emit()

func flip_map_edit_mode() -> void:
	map_edit_mode_active = !map_edit_mode_active
	map_edit_mode_switched.emit()
	print("map_edit_mode_active: " + str(map_edit_mode_active))

func set_shop_open(value: bool):
	if value:
		shop_open = value
		hoe_mode_active = false
		map_edit_mode_active = false
		hoe_mode_switched.emit()
		map_edit_mode_switched.emit()

func can_afford(amount: int) -> bool:
	return total_gold >= amount

func spend_money(amount: int):
	if can_afford(amount):
		total_gold -= amount
		AudioManager.play("purchase")

func lower_hoe_durability():
	hoe_durability -= 10
	
	if hoe_durability <= 0:
		hoe_durability = 0
		hoe_broken.emit()
		hoe_mode_active = false

func reset_hoe_durability():
	hoe_durability = 80
	hoe_restored.emit()

func get_data_by_name(crop_name: String) -> Dictionary:
	for type in crop_data:
		if crop_data[type].name == crop_name:
			return crop_data[type]
	return {}
