extends MarginContainer

@export var player: Node2D

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
	# Loop through every category defined in the Model (ShopManager)
	for category in ShopManager.shop_registry:
		var container = category_containers.get(category)
		var template = category_templates.get(category)
		
		if not container or not template: continue
		
		var items = ShopManager.get_items_in_category(category)
		
		for type in items:
			_create_shop_item(category, type, items[type], container, template)

func _create_shop_item(category, type, data, container, template) -> void:
	var tab = template.instantiate()
	tab.name = data.name
	container.add_child(tab)
	
	container.set_tab_icon(tab.get_index(), data.icon)
	if tab.has_method("setup"):
		tab.setup(category, type)
	
	# Universal signal binding
	if tab.has_signal("buy_requested"):
		tab.buy_requested.connect(_on_item_buy_requested.bind(category))
	elif tab.has_signal("buy_decoration_item_requested"):
		tab.buy_decoration_item_requested.connect(_on_item_buy_requested.bind(category))
	
	active_tabs.append(tab)

func _on_item_buy_requested(type, qty_or_cost, maybe_cost = null, category = null) -> void:
	var qty = qty_or_cost if maybe_cost != null else 1
	var total_cost = maybe_cost if maybe_cost != null else qty_or_cost
	
	if GameManager.can_afford(total_cost):
		var item_data = ShopManager.shop_registry[category][type]
		_handle_purchase_delivery(category, item_data.name, qty)
		GameManager.spend_money(total_cost)

func _handle_purchase_delivery(category, item_name: String, qty: int) -> void:
	for i in range(qty):
		match category:
			ShopManager.Category.CROPS:
				player.seeds.append(item_name)
			ShopManager.Category.DECORATIONS, ShopManager.Category.STRUCTURES:
				player.decoration_items.append(item_name)

# --- UI Updates ---
func _on_player_gold_changed(_new_amount) -> void:
	current_coins_label.text = str(_new_amount)
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
