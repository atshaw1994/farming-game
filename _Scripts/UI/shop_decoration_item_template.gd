extends MarginContainer

signal buy_decoration_item_requested(type: int, total_cost: int)

@onready var buy_btn = %BuyItemButton
@onready var total_label: Label = %TotalLabel

var item_type: int 
var unit_price: int = 0

func setup(category: int, type: int) -> void:
	var data = ShopManager.shop_registry[category][type]
	
	item_type = type
	unit_price = data.buy_price
	
	%ItemImage.texture = data.icon
	%ItemNameLabel.text = data.name.to_upper()
	%ItemInfoLabel.text = data.description
	total_label.text = str(unit_price)
	
	# Check if already connected to prevent double-connections during dynamic pooling
	if not buy_btn.pressed.is_connected(_on_buy_pressed):
		buy_btn.pressed.connect(_on_buy_pressed)

func _on_buy_pressed() -> void:
	buy_decoration_item_requested.emit(item_type, unit_price)
