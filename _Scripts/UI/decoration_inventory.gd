extends CanvasLayer

signal item_selected(type)

@onready var panel_container = $PanelContainer
@onready var item_container: HBoxContainer = $PanelContainer/MarginContainer/ItemContainer
@onready var player: Node2D = $".."
@onready var decoration_button: Button = $"../../CanvasLayer/ActionButtonsContainer/VBoxContainer/DecorationButton"
@onready var empty_label: Label = $PanelContainer/MarginContainer/EmptyLabel

func _ready() -> void:
	hide()
	panel_container.scale = Vector2.ZERO

func show_at_position(show_position: Vector2) -> void:
	show()
	_setup_buttons() 
	await get_tree().process_frame
	var adjusted_show_position = Vector2(show_position.x - panel_container.size.x, show_position.y)
	var screen_pos = get_viewport().get_canvas_transform() * adjusted_show_position
	panel_container.global_position = screen_pos - panel_container.pivot_offset
	AudioManager.play("button_click")
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3).from(Vector2(0,1))
	tween.tween_property(panel_container, "position", screen_pos - panel_container.pivot_offset, 0.3).from(show_position)
	if item_container.get_child_count() == 0: empty_label.show()

func _setup_buttons() -> void:
	# 1. Clear existing dynamic buttons to refresh the list
	for child in item_container.get_children():
		child.queue_free()
	
	# 2. Count the items in the player's inventory
	var decoration_counts = {}
	for decoration_item_type in player.decoration_items:
		if not decoration_counts.has(decoration_item_type):
			decoration_counts[decoration_item_type] = 0
		decoration_counts[decoration_item_type] += 1
	
	# 3. Dynamically create a button for each item type owned
	for decoration_item_type in decoration_counts:
		_create_item_button(decoration_item_type, decoration_counts[decoration_item_type])

func _create_item_button(decoration_item: String, count: int) -> void:
	# Create a Container to hold the button and the label
	var wrapper = HBoxContainer.new()
	
	# Create the Button
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(48, 48)
	var data = GameManager.get_data_by_name(decoration_item)
	if not data.is_empty():
		btn.icon = data.icon
	btn.expand_icon = true
	
	# Connect the click signal using a lambda to pass the type
	btn.pressed.connect(func(): _on_item_picked(decoration_item))
	
	# Create the Label
	var lbl = Label.new()
	lbl.text = str(count)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Add to tree
	wrapper.add_child(btn)
	wrapper.add_child(lbl)
	item_container.add_child(wrapper)

func _on_item_picked(picked_item: String) -> void:
	AudioManager.play("button_click")
	item_selected.emit(picked_item)
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0.2)
	tween.finished.connect(hide)
	GameManager.flip_map_edit_mode()
