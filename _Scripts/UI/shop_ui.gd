extends MarginContainer

# UI References
@onready var buy_tabs: TabContainer = $MainContainer/BaseTabContainer/Buy/BuyTabContainer
@onready var current_coins_label: Label = %CurrentCoinsLabel
@onready var sell_items_list: VBoxContainer = %SellItemsList
@onready var sell_all_button: Button = %SellAllButton

@onready var category_containers = {
	ShopManager.Category.CROPS: %CropsTabContainer,
	ShopManager.Category.DECORATIONS: %DecorationsTabContainer,
	ShopManager.Category.STRUCTURES: %StructuresTabContainer,
	ShopManager.Category.ANIMALS: %AnimalsTabContainer
}

# Mapping Categories to their specific item templates
var category_templates = {
	ShopManager.Category.CROPS: preload("res://_Prefabs/UI/Shop/crop_tab_template.tscn"),
	ShopManager.Category.DECORATIONS: preload("res://_Prefabs/UI/Shop/decoration_item_tab_template.tscn"),
	ShopManager.Category.STRUCTURES: preload("res://_Prefabs/UI/Shop/decoration_item_tab_template.tscn"),
	ShopManager.Category.ANIMALS: preload("res://_Prefabs/UI/Shop/decoration_item_tab_template.tscn") # Reusing for animals
}

var active_tabs = []

func _ready() -> void:
	_setup_audio()
	_initialize_dynamic_shop()
	GameManager.money_changed.connect(_on_player_gold_changed)
	_update_affordability()

func _initialize_dynamic_shop() -> void:
	current_coins_label.text = str(GameManager.total_gold)
	
	# Loop through every category defined in the Model (ShopManager)
	for category in ShopManager.shop_registry:
		var container = category_containers.get(category)
		var template = category_templates.get(category)
		
		if not container or not template: continue
		
		var items = ShopManager.get_items_in_category(category)
		
		for type in items:
			_create_shop_item(category, type, items[type], container, template)
	
	await get_tree().create_timer(0.1).timeout
	PlayerManager.crop_harvested.connect(_setup_sell_tab)
	_setup_sell_tab()

func _setup_sell_tab() -> void:
	for child in sell_items_list.get_children(): child.queue_free()
	for harvested_item in PlayerManager.harvested_crops:
		var new_sell_item = Button.new()
		var data = ShopManager.shop_registry[ShopManager.Category.CROPS][harvested_item.crop_type]
		new_sell_item.icon = data.icon
		new_sell_item.text = data.name + "(value: " + str(data.sell_price) + ")"
		new_sell_item.pressed.connect(handle_sell_item.bind(data, new_sell_item))
		new_sell_item.custom_minimum_size = Vector2(64, 48)
		sell_items_list.add_child(new_sell_item)

func handle_sell_item(data:Dictionary, sender:Button) -> void:
	PlayerManager.remove_harvested(data.name)
	GameManager.total_gold += data.sell_price
	AudioManager.play("sell")
	sender.queue_free()

func _create_shop_item(category, type, data, container, template) -> void:
	var tab = template.instantiate()
	tab.name = data.name
	container.add_child(tab)
	
	container.set_tab_icon(tab.get_index(), data.icon)
	if tab.has_method("setup"):
		tab.setup(category, type)
	
	# Universal signal binding
	if tab.has_signal("buy_requested"):
		tab.buy_requested.connect(_on_item_buy_requested)
	elif tab.has_signal("buy_decoration_item_requested"):
		tab.buy_decoration_item_requested.connect(_on_item_buy_requested)
	
	active_tabs.append(tab)

func _on_item_buy_requested(category, type, qty) -> void:
	var item_data = ShopManager.shop_registry[category][type]
	if GameManager.can_afford(item_data.buy_price * qty):
		_handle_purchase_delivery(category, item_data.name, qty)
		GameManager.spend_money(item_data.buy_price * qty)

func _handle_purchase_delivery(category, item_name: String, qty: int) -> void:
	for i in range(qty):
		match category:
			ShopManager.Category.CROPS:
				PlayerManager.seeds.append(item_name)
			ShopManager.Category.DECORATIONS, ShopManager.Category.STRUCTURES:
				PlayerManager.decoration_items.append(item_name)

# --- UI Updates ---
func _on_player_gold_changed(_new_amount) -> void:
	current_coins_label.text = str(GameManager.total_gold)
	_update_affordability()

func _update_affordability() -> void:
	for tab in active_tabs:
		var total_cost = int(tab.total_label.text)
		tab.buy_btn.disabled = total_cost <= 0 or !GameManager.can_afford(total_cost)

func _setup_audio() -> void:
	for btn in find_children("*", "Button", true):
		if not btn.pressed.is_connected(_play_click):
			btn.pressed.connect(_play_click)

func _play_click() -> void:
	AudioManager.play("button_click")

func _on_close_shop_button_pressed() -> void:
	_play_click()
	GameManager.set_shop_open(false)
	hide()
	get_viewport().gui_release_focus()

func _on_sell_all_button_pressed() -> void:
	for sell_item:Button in sell_items_list.get_children():
		sell_item.pressed.emit()
