extends Button

@onready var hoe_durability_bar: ProgressBar = $HoeDurabilityBar
@onready var hoe_broken_overlay: Label = $HoeBrokenOverlay
@onready var root_node: Node2D = get_tree().current_scene

func _ready() -> void:
	GameManager.plot_hoed.connect(update_durability)

func update_durability() -> void:
	hoe_durability_bar.value = (GameManager.hoe_durability / 80.0) * 100

func _on_hoe_broken() -> void:
	hoe_broken_overlay.show()

func _on_hoe_restored() -> void:
	hoe_broken_overlay.hide()
	hoe_durability_bar.value = 100
