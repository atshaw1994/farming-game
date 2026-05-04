extends MarginContainer

@export var player: Node2D
@onready var tab_container: TabContainer = $MainContainer/BaseTabContainer/Buy/BuyTabContainer
@onready var crops_tab: TabContainer = $MainContainer/BaseTabContainer/Buy/BuyTabContainer/Crops/CropsTabContainer
@onready var current_coins_label: Label = $MainContainer/CurrentCoinsMarginContainer/HBoxContainer/CurrentCoinsLabel
@onready var sell_items_list: VBoxContainer = $MainContainer/BaseTabContainer/Sell/VBoxContainer/ScrollContainer/SellItemsList
@onready var sell_all_button: Button = $MainContainer/BaseTabContainer/Sell/VBoxContainer/MarginContainer/SellAllButton

var active_tabs = []

func _ready() -> void:
	for btn in find_children("*", "Button", true):
		btn.pressed.connect(func(): AudioManager.play("button_click"))
		
	for type in GameManager.crop_data:
		var data = GameManager.crop_data[type]
		var tab = preload("res://_Prefabs/UI/crop_tab_template.tscn").instantiate()
		tab.name = data.name
		crops_tab.add_child(tab)
		var tab_index = tab.get_index()
		crops_tab.set_tab_icon(tab_index, data.icon)
		
		if tab.has_method("setup"): tab.setup(type)
		
		tab.buy_requested.connect(_on_tab_buy_requested)
		active_tabs.append(tab)

func _process(_delta) -> void:
	current_coins_label.text = str(GameManager.total_gold)
	
	for tab in active_tabs:
		var can_afford_one = GameManager.can_afford(tab.unit_price)
		crops_tab.set_tab_hidden(tab.get_index(), !can_afford_one)
		
		var total_needed = int(tab.total_label.text)
		tab.buy_btn.disabled = total_needed <= 0 or !GameManager.can_afford(total_needed)

func open() -> void:
	# Clear old items
	for child in sell_items_list.get_children(): child.queue_free()
	
	# Generate sell list from player inventory
	for item in player.harvested_crops: _create_sell_button(item)
	
	if sell_items_list.get_child_count() > 0: sell_all_button.show()
	else: sell_all_button.hide()
	
	show()

func _create_sell_button(item: Node) -> void:
	var new_sell_item = Button.new()
	var data = GameManager.get_data_by_name(item.name)
	new_sell_item.text = "{n} (value: {v})".format({"n": data.name, "v": data.sell_price})
	
	new_sell_item.icon = data.icon
	new_sell_item.expand_icon = true
	new_sell_item.custom_minimum_size.y = 48
	
	new_sell_item.pressed.connect(func(): _sell_item(item, new_sell_item))
	sell_items_list.add_child(new_sell_item)

# Use this when clicking ONE button in the list
func _sell_item(item: Node, button: Button) -> void:
	_process_item_sale(item)
	button.queue_free()
	AudioManager.play("sell")
	
	# Hide the 'Sell All' button if the last item was sold
	if sell_items_list.get_child_count() <= 1: 
		sell_all_button.hide()

# The core 'Industrial' logic shared by both sell methods
func _process_item_sale(item: Node) -> void:
	var data = GameManager.get_data_by_name(item.name)
	GameManager.total_gold += data.sell_price
	player.harvested_crops.erase(item)
	item.queue_free()

func _on_tab_buy_requested(type, qty, cost) -> void:
	if GameManager.can_afford(cost):
		var crop_name = GameManager.crop_data[type].name
		for i in range(qty):
			player.seeds.append(crop_name)
		GameManager.spend_money(cost)

func _on_close_shop_button_pressed() -> void:
	GameManager.set_shop_open(false)
	self.hide()

func _on_tab_container_tab_changed(_tab: int) -> void:
	AudioManager.play("button_click")

func _on_sell_all_button_pressed() -> void:
	# Duplicate the list so we don't crash while iterating and deleting
	var items_to_sell = player.harvested_crops.duplicate()
	
	for item in items_to_sell:
		_process_item_sale(item)
	
	# Clear all the UI buttons at once
	for child in sell_items_list.get_children():
		child.queue_free()
	
	sell_all_button.hide()
	AudioManager.play("sell") # One big satisfying sound for the whole batch

func _on_buy_house_button_pressed() -> void:
	pass # Replace with function body.
