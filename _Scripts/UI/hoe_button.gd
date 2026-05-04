extends Button

@onready var hoe_durability_bar: ProgressBar = $HoeDurabilityBar
@onready var hoe_broken_overlay: Label = $HoeBrokenOverlay
@onready var root_node: Node2D = get_tree().current_scene

func _ready() -> void:
	hoe_durability_bar.value = (GameManager.hoe_durability / 80.0) * 100
	GameManager.hoe_broken.connect(_on_hoe_broken)
	GameManager.hoe_restored.connect(_on_hoe_restored)
	root_node.plot_hoed.connect(update_durability)

func update_durability() -> void:
	GameManager.lower_hoe_durability()
	# Sync the UI bar with the new durability value [cite: 74]
	hoe_durability_bar.value = (GameManager.hoe_durability / 80.0) * 100

func _on_hoe_broken() -> void:
	hoe_broken_overlay.show()

func _on_hoe_restored() -> void:
	hoe_broken_overlay.hide()
	hoe_durability_bar.value = 100
