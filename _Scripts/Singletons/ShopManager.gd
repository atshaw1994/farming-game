extends Node

# --- ENUMS ---
enum Category { CROPS, DECORATIONS, ANIMALS, STRUCTURES }
enum CropType { WHEAT, POTATO, TOMATO }
enum DecorationItemType { FENCE, HOUSE }
enum AnimalType { CHICKEN }
enum AnimalContainerType { CHICKEN_COOP }

# --- THE MODEL DATA ---
var shop_registry = {
	Category.CROPS: {
		CropType.WHEAT: {
			"name": "wheat",
			"buy_price": 2,
			"sell_price": 4,
			"growth_time": 10.0,
			"wilt_time": 10.0,
			"icon": preload("res://_Sprites/Wheat/6 - Wheat Inventory.png"),
			"scene": load("res://_Prefabs/Crops/Wheat.tscn")
		},
		CropType.POTATO: {
			"name": "potato",
			"buy_price": 4,
			"sell_price": 6,
			"growth_time": 30.0,
			"wilt_time": 15.0,
			"icon": preload("res://_Sprites/Potato/6 - Potato Inventory.png"),
			"scene": load("res://_Prefabs/Crops/Potato.tscn")
		},
		CropType.TOMATO: {
			"name": "tomato",
			"buy_price": 8,
			"sell_price": 10,
			"growth_time": 60.0,
			"wilt_time": 60.0,
			"icon": preload("res://_Sprites/Tomato/6 - Tomato Inventory.png"),
			"scene": load("res://_Prefabs/Crops/Tomato.tscn")
		}
	},
	Category.DECORATIONS: {
		DecorationItemType.FENCE: {
			"name": "Fence",
			"buy_price": 10,
			"sell_price": 8,
			"description": "An oak fence", 
			"icon": preload("res://_Sprites/Fences/oak_fence_right.png")
		},
		DecorationItemType.HOUSE: {
			"name": "House",
			"buy_price": 100,
			"sell_price": 80,
			"description": "A farm house",
			"icon": preload("res://_Sprites/Buildings/house_icon.png")
		}
	},
	Category.ANIMALS: {
		AnimalType.CHICKEN: {
			"name": "Chicken",
			"description": "Lays eggs.\nCHICKEN COOP REQUIRED", 
			"buy_price": 30,
			"icon": null # Populated in _ready via _get_icon_from_spritesheet
		}
	},
	Category.STRUCTURES: {
		AnimalContainerType.CHICKEN_COOP: {
			"name": "Chicken Coop",
			"description": "Holds up to 3 Chickens", 
			"buy_price": 100,
			"sell_price": 80,
			"icon": preload("res://_Sprites/Chicken/chicken_coop_icon.png")
		}
	}
}

func _ready() -> void:
	# Initialize dynamic assets that can't be preloaded in the dictionary directly
	shop_registry[Category.ANIMALS][AnimalType.CHICKEN].icon = _get_icon_from_spritesheet(
		"res://_Sprites/Chicken/Chicken_Sprite_Sheet.png", 0, 0, 32, 32
	)

# --- HELPER METHODS ---
func get_items_in_category(category: Category) -> Dictionary:
	return shop_registry.get(category, {})

func create_scene_by_name(item_name: String) -> Node:
	var data = get_data_by_name(item_name)
	if data.has("scene"):
		var new_item = data.scene.instantiate()
		new_item.name = data.name
		return new_item
	return null

func get_data_by_name(data_name: String) -> Dictionary:
	for category in shop_registry:
		var items = shop_registry[category]
		for type in items:
			if items[type].name == data_name:
				return items[type]
	return {}

func _get_icon_from_spritesheet(path: String, x: int, y: int, w: int, h: int) -> AtlasTexture:
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = load(path)
	atlas_tex.region = Rect2(x, y, w, h)
	return atlas_tex
