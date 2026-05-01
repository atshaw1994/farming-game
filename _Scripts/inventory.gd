extends CanvasLayer

signal seed_selected(type)

@onready var panel_container = $PanelContainer
@onready var seed_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/SeedContainer
@onready var player: Node2D = $".."

func _ready():
	hide()
	panel_container.scale = Vector2.ZERO

func show_at_position(plot_global_center: Vector2):
	if player.seeds.size() == 0:
		player.show_popup("No seeds.")
		return
	show()
	_setup_buttons()
	await get_tree().process_frame
	var screen_pos = get_viewport().get_canvas_transform() * plot_global_center
	panel_container.global_position = screen_pos - panel_container.pivot_offset
	AudioManager.play("button_click")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3).from(Vector2.ZERO)

func _setup_buttons():
	# 1. Clear existing dynamic buttons to refresh the list
	for child in seed_container.get_children():
		child.queue_free()
	
	# 2. Count the seeds in the player's inventory
	var seed_counts = {}
	for seed_type in player.seeds:
		if not seed_counts.has(seed_type):
			seed_counts[seed_type] = 0
		seed_counts[seed_type] += 1
	
	# 3. Dynamically create a button for each seed type owned
	for seed_type in seed_counts:
		_create_seed_button(seed_type, seed_counts[seed_type])

func _create_seed_button(picked_seed: String, count: int):
	# Create a Container to hold the button and the label
	var wrapper = HBoxContainer.new()
	
	# Create the Button
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(48, 48)
	var data = GameManager.get_data_by_name(picked_seed)
	if not data.is_empty():
		btn.icon = data.icon
	btn.expand_icon = true
	
	# Connect the click signal using a lambda to pass the type
	btn.pressed.connect(func(): _on_seed_picked(picked_seed))
	
	# Create the Label
	var lbl = Label.new()
	lbl.text = str(count)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Add to tree
	wrapper.add_child(btn)
	wrapper.add_child(lbl)
	seed_container.add_child(wrapper)

func _on_seed_picked(picked_seed: String):
	AudioManager.play("plant_seed")
	seed_selected.emit(picked_seed)
	player.remove_seed(picked_seed)
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0.2)
	tween.finished.connect(hide)
