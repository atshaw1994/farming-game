extends CharacterBody2D

@export var speed: float = 200.0
@onready var animations = $AnimatedSprite2D
@onready var target: Panel = $"../CanvasLayer/Target"
@onready var root_node: Node2D = $".."

var last_direction = "right"
var target_position = null
var current_target_plot = null
var harvested_crops = []
var seeds = []

signal arrived_at_plot

func _ready() -> void:
	var inventory_ui = find_child("Inventory", true, false)
	inventory_ui.seed_selected.connect(func(type): remove_seed(type))

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_mouse_over_ui(): return
		if not GameManager.hoe_mode_active and not GameManager.shop_open:
			update_movement_target()

func _physics_process(_delta) -> void:
	if target_position:
		# Calculate the current distance to the target center
		var distance = global_position.distance_to(target_position)
		
		# Get the arrival threshold from the plot itself
		var arrival_threshold = 20.0 # Default fallback
		if current_target_plot and current_target_plot.has_method("get_interaction_distance"):
			arrival_threshold = current_target_plot.get_interaction_distance() * 2
		
		if distance < arrival_threshold:
			target_position = null
			current_target_plot = null # Clear the target after arriving
			velocity = Vector2.ZERO
			target.hide()
			arrived_at_plot.emit()
		else:
			var direction = (target_position - global_position).normalized()
			velocity = direction * speed
			update_animations(direction)
			move_and_slide()
	else:
		# Your existing WASD movement logic
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * speed
		move_and_slide()
		update_animations(direction)

func _unhandled_input(event) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not GameManager.hoe_mode_active and not GameManager.shop_open:
			update_movement_target()
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(target, "scale", Vector2.ONE, 0.3).from(Vector2.ZERO)

func _is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_focus_owner() != null or \
	get_viewport().get_mouse_position() != get_local_mouse_position()

func update_movement_target() -> void:
	target_position = get_global_mouse_position()
	target.show()
	target.position = target_position - Vector2(8, 8)
	target.scale = Vector2.ONE
	current_target_plot = null 
	var inventory = find_child("Inventory", true, false)
	if inventory and inventory.visible:
		inventory.hide()
	if arrived_at_plot.is_connected(_on_arrival_at_random_spot):
		arrived_at_plot.disconnect(_on_arrival_at_random_spot)

func update_animations(direction) -> void:
	if direction.length() > 0:
		# We are moving
		if direction.x != 0:
			last_direction = "right" if direction.x > 0 else "left"
		
		animations.play("walk_" + last_direction)
	else:
		# We are standing still
		animations.play("idle_" + last_direction)

func _on_arrival_at_random_spot() -> void:
	pass 

func harvest_crop(harvested_crop) -> void:
	harvested_crops.append(harvested_crop.duplicate())

func remove_seed(crop_seed_to_remove:String) -> void:
	seeds.remove_at(seeds.find(crop_seed_to_remove))

func show_popup(message:String) -> void:
	var label = Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.texture_filter = 1
	
	# Basic styling
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Position it slightly above the player's head
	label.position = Vector2(-20, 0) 
	
	add_child(label)
	
	# The "Rise and Fade" Animation
	var tween = create_tween()
	
	# Rise up by 30 pixels
	tween.tween_property(label, "position:y", label.position.y - 20, 0.5)
	# Fade to transparent
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	
	# Kill the label node once the animation is done to keep memory clean
	tween.chain().tween_callback(label.queue_free)
