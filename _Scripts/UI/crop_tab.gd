extends MarginContainer

signal buy_requested(type: ShopManager.CropType, quantity: int, total_cost: int)

@onready var qty_spin = %SeedQtySpinBox
@onready var total_label = %SeedTotalPriceLabel
@onready var buy_btn = %BuySeedsButton

var crop_type: ShopManager.CropType
var unit_price: int = 0

func setup(category: int, type: ShopManager.CropType) -> void:
	var data = ShopManager.shop_registry[category][type]
	crop_type = type
	unit_price = data.buy_price
	
	%SeedImage.texture = data.icon
	%SeedNameLabel.text = data.name.to_upper() + " SEEDS"
	%SeedPriceLabel.text = str(unit_price)
	%SeedInfoLabel.text = "Growth: %ds\nValue: %d" % [data.growth_time, data.sell_price]
	
	qty_spin.value_changed.connect(_on_qty_changed)
	buy_btn.pressed.connect(_on_buy_pressed)
	_update_ui()

func _on_qty_changed(_value:int) -> void:
	AudioManager.play("button_click")
	_update_ui()

func _update_ui() -> void:
	var total = int(qty_spin.value) * unit_price
	total_label.text = str(total)
	buy_btn.disabled = qty_spin.value <= 0

func _on_buy_pressed() -> void:
	buy_requested.emit(crop_type, int(qty_spin.value), int(total_label.text))
	qty_spin.value = 0 # Reset after purchase
