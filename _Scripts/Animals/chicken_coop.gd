extends Node2D

@onready var egg_count: Node2D = $EggCount
@onready var no_chickens_overlay: Node2D = $NoChickensOverlay

var chickens = []

signal collected_eggs

func add_chicken(chicken:PackedScene) -> void:
	var new_chicken = chicken.instantiate()
	chickens.append(new_chicken)
	new_chicken.laid_egg.connect(add_egg)
	add_child(new_chicken)

func _process(_delta: float) -> void:
	no_chickens_overlay.visible = egg_count.get_number_of_eggs() == 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if egg_count.get_number_of_eggs() > 0:
			_collect_eggs()

func _collect_eggs() -> void:
	collected_eggs.emit(egg_count.get_number_of_eggs())
	egg_count.reset_egg_count()

func add_egg() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var original_y = egg_count.position.y
	tween.tween_property(egg_count, "position:y", original_y - 32, 1.0)
	tween.tween_property(egg_count, "position:y", original_y, 1.0)
	egg_count.add_egg()
