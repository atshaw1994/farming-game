extends MarginContainer

signal buy_decoration_item_requested(category: int, type: int, qty: int)

@onready var buy_btn = %BuyItemButton
@onready var total_label: Label = %TotalLabel

var item_category: int = 0
var item_type: int 

func setup(category: int, type: int) -> void:
	var data = ShopManager.shop_registry[category][type]
	item_category = category
	item_type = type
	%ItemImage.texture = data.icon
	%ItemNameLabel.text = data.name.to_upper()
	%ItemInfoLabel.text = data.description
	total_label.text = str(data.buy_price)
	# Check if already connected to prevent double-connections during dynamic pooling
	if not buy_btn.pressed.is_connected(_on_buy_pressed):
		buy_btn.pressed.connect(_on_buy_pressed)

func _on_buy_pressed() -> void:
	buy_decoration_item_requested.emit(item_category, item_type, 1)
