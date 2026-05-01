extends MarginContainer

@export var player: Node2D
@onready var tab_container: TabContainer = $MainContainer/TabContainer/Buy/TabContainer
@onready var current_coins_label: Label = $MainContainer/MarginContainer/HBoxContainer/CurrentCoinsLabel
@onready var sell_items_list: VBoxContainer = $MainContainer/TabContainer/Sell/ScrollContainer/SellItemsList

var active_tabs = []

func _ready():
	for btn in find_children("*", "Button", true):
		btn.pressed.connect(func(): AudioManager.play("button_click"))
	
	for child in tab_container.get_children():
		if child.name != "Hoe":  child.queue_free()
	
	for type in GameManager.crop_data:
		var data = GameManager.crop_data[type]
		var tab = preload("res://_Prefabs/crop_tab_template.tscn").instantiate()
		tab.name = data.name
		tab_container.add_child(tab)
		var tab_index = tab.get_index()
		tab_container.set_tab_icon(tab_index, data.icon)
		
		if tab.has_method("setup"): tab.setup(type)
		
		tab.buy_requested.connect(_on_tab_buy_requested)
		active_tabs.append(tab)

func _process(_delta):
	current_coins_label.text = str(GameManager.total_gold)
	
	for tab in active_tabs:
		var can_afford_one = GameManager.can_afford(tab.unit_price)
		tab_container.set_tab_hidden(tab.get_index(), !can_afford_one)
		
		var total_needed = int(tab.total_label.text)
		tab.buy_btn.disabled = total_needed <= 0 or !GameManager.can_afford(total_needed)

func open() -> void:
	# Clear old items
	for child in sell_items_list.get_children(): child.queue_free()
	
	# Generate sell list from player inventory
	for item in player.harvested_crops: _create_sell_button(item)
	show()

func _create_sell_button(item: Node):
	var new_sell_item = Button.new()
	var data = GameManager.get_data_by_name(item.name)
	new_sell_item.text = "{n} (value: {v})".format({"n": data.name, "v": data.sell_price})
	
	new_sell_item.icon = data.icon
	new_sell_item.expand_icon = true
	new_sell_item.custom_minimum_size.y = 48
	
	new_sell_item.pressed.connect(func(): _sell_item(item, new_sell_item))
	sell_items_list.add_child(new_sell_item)

func _sell_item(item: Node, button: Button):
	var data = GameManager.get_data_by_name(item.name)
	GameManager.total_gold += data.sell_price
	player.harvested_crops.erase(item)
	item.queue_free()
	button.queue_free()
	AudioManager.play("sell")

func _on_tab_buy_requested(type, qty, cost):
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
