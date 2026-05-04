extends Node2D

@onready var egg_count_label: Label = $EggCountLabel

var _egg_count: int = 0

func add_egg() -> void:
	_egg_count += 1
	egg_count_label.text = str(_egg_count)

func reset_egg_count() -> void:
	_egg_count = 0
	egg_count_label.text = str(_egg_count)

func get_number_of_eggs() -> int: return _egg_count
