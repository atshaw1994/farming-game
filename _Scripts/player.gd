extends CharacterBody2D

@export var speed: float = 200.0

@onready var animations = $AnimatedSprite2D
@onready var root_node: Node2D = $".."
@onready var blink_timer: Timer = $BlinkTimer
@onready var decoration_inventory: CanvasLayer = $DecorationInventory

signal crop_harvested
signal arrived_at_plot

func _ready() -> void:
	if PlayerManager.gender == "male": animations.sprite_frames = GameManager.MALE_FRAMES
	else: animations.sprite_frames = GameManager.FEMALE_FRAMES
	animations.play("idle_" + PlayerManager.last_direction)
	blink_timer.wait_time = randf_range(3.0, 7.0)
	blink_timer.start()

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_mouse_over_ui(): return
		if not GameManager.hoe_mode_active and not GameManager.shop_open:
			update_movement_target()

func _physics_process(_delta) -> void:
	if PlayerManager.target_position:
		# Calculate the current distance to the target center
		var distance = global_position.distance_to(PlayerManager.target_position)
		
		# Get the arrival threshold from the plot itself
		var arrival_threshold = 20.0 # Default fallback
		if PlayerManager.current_target_plot and PlayerManager.current_target_plot.has_method("get_interaction_distance"):
			arrival_threshold = PlayerManager.current_target_plot.get_interaction_distance() * 2
		
		if distance < arrival_threshold:
			arrived_at_plot.emit()
			PlayerManager.arrived_at_plot(PlayerManager.current_target_plot)
			PlayerManager.target_position = null
			PlayerManager.current_target_plot = null # Clear the target after arriving
			velocity = Vector2.ZERO
		else:
			var direction = (PlayerManager.target_position - global_position).normalized()
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

func _is_mouse_over_ui() -> bool:
	return get_viewport().gui_get_focus_owner() != null or \
	get_viewport().get_mouse_position() != get_local_mouse_position()

func update_movement_target() -> void:
	PlayerManager.target_position = get_global_mouse_position()
	PlayerManager.current_target_plot = null 
	var inventory = find_child("Inventory", true, false)
	if inventory and inventory.visible:
		inventory.hide()
	if arrived_at_plot.is_connected(_on_arrival_at_random_spot):
		arrived_at_plot.disconnect(_on_arrival_at_random_spot)

func update_animations(direction) -> void:
	if PlayerManager.gender == "male": animations.sprite_frames = GameManager.MALE_FRAMES
	else: animations.sprite_frames = GameManager.FEMALE_FRAMES
	if direction.length() > 0:
		if direction.x != 0:
			PlayerManager.last_direction = "right" if direction.x > 0 else "left"
		animations.play("walk_" + PlayerManager.last_direction)
	else:
		if not animations.animation == "blink_left" and not animations.animation == "blink_right":
			animations.play("idle_" + PlayerManager.last_direction)

func _on_arrival_at_random_spot() -> void:
	PlayerManager.target_position = null

func harvest_crop(harvested_crop) -> void:
	PlayerManager.harvested_crops.append(harvested_crop.duplicate())
	crop_harvested.emit()

func remove_seed(crop_seed_to_remove:String) -> void:
	PlayerManager.seeds.remove_at(PlayerManager.seeds.find(crop_seed_to_remove))

func remove_decoration_item(item_to_remove:String) -> void:
	PlayerManager.decoration_items.remove_at(PlayerManager.decoration_items.find(item_to_remove))

func remove_harvested(item_to_remove:String) -> void:
	PlayerManager.harvested_crops.remove_at(PlayerManager.harvested_crops.find(item_to_remove))

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
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 20, 0.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	# Kill the label node once the animation is done to keep memory clean
	tween.chain().tween_callback(label.queue_free)

func _on_blink_timer_timeout() -> void:
	if velocity.length() == 0:
		var blink_anim = "blink_" + PlayerManager.last_direction
		if animations.sprite_frames.has_animation(blink_anim): 
			animations.play(blink_anim)
			await animations.animation_finished
			animations.play("idle_" + PlayerManager.last_direction)
	blink_timer.wait_time = randf_range(3.0, 7.0)
	blink_timer.start()
