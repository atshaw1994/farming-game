extends StaticBody2D

@export_group("Textures")
@export var sprout_texture: Texture2D
@export var mid_texture: Texture2D
@export var full_texture: Texture2D
@export var wilted_texture: Texture2D

@export_group("General Crop Info")
@export var crop_type: GameManager.CropType

enum Stage { SPROUT, MID, FULL, WILTED }
var current_stage = Stage.SPROUT

@onready var sprite = $Sprite2D
@onready var timer = $GrowthTimer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	update_appearance()
	start_growth_cycle()

func start_growth_cycle() -> void:
	var data = GameManager.crop_data[crop_type]
	timer.start(data.growth_time / 3.0)

func _on_timer_timeout() -> void:
	if current_stage < Stage.FULL:
		current_stage = (current_stage + 1) as Stage
		update_appearance()
		if current_stage == Stage.FULL:
			var data = GameManager.crop_data[crop_type]
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
