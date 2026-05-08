extends StaticBody2D

@export_group("Textures")
@export var sprout_texture: Texture2D
@export var mid_texture: Texture2D
@export var full_texture: Texture2D
@export var wilted_texture: Texture2D

@export_group("General Crop Info")
@export var crop_type: ShopManager.CropType

enum Stage { SPROUT, MID, FULL, WILTED }
var current_stage = Stage.SPROUT
var _restore_stage: int = -1

@onready var sprite = $Sprite2D
@onready var timer = $GrowthTimer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	update_appearance()
	start_growth_cycle()
	if _restore_stage >= 0:
		restore_to_stage(_restore_stage as Stage)
		_restore_stage = -1

func start_growth_cycle() -> void:
	var data = ShopManager.shop_registry[ShopManager.Category.CROPS][crop_type]
	timer.start(data.growth_time / 3.0)

func _on_timer_timeout() -> void:
	if current_stage < Stage.FULL:
		current_stage = (current_stage + 1) as Stage
		update_appearance()
		if current_stage == Stage.FULL:
			var data = ShopManager.shop_registry[ShopManager.Category.CROPS][crop_type]
			timer.start(data.wilt_time / 3.0) # Time until wilt
	elif current_stage == Stage.FULL:
		current_stage = Stage.WILTED
		update_appearance()

func update_appearance() -> void:
	match current_stage:
		Stage.SPROUT: sprite.texture = sprout_texture
		Stage.MID:    sprite.texture = mid_texture
		Stage.FULL:   sprite.texture = full_texture
		Stage.WILTED: sprite.texture = wilted_texture

func restore_to_stage(stage: Stage) -> void:
	timer.stop()
	current_stage = stage
	update_appearance()
	var data = ShopManager.shop_registry[ShopManager.Category.CROPS][crop_type]
	match current_stage:
		Stage.SPROUT, Stage.MID:
			timer.start(data.growth_time / 3.0)
		Stage.FULL:
			timer.start(data.wilt_time / 3.0)
		Stage.WILTED:
			pass  # No further growth

func play_harvest_animation() -> void:
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + Vector2(0, -40), 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(self.queue_free)
