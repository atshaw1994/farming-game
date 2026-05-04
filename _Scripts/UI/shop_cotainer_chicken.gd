extends MarginContainer

@onready var chicken_container: HBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer/ChickenContainer
@onready var chicken_cooop_container: HBoxContainer = $ScrollContainer/MarginContainer/VBoxContainer/ChickenCooopContainer
@onready var buy_chicken_coop_button: Button = $ScrollContainer/MarginContainer/VBoxContainer/ChickenCooopContainer/VBoxContainer/GridContainer/BuyChickenCoopButton
@onready var buy_chicken_button: Button = $ScrollContainer/MarginContainer/VBoxContainer/ChickenContainer/VBoxContainer/GridContainer/BuyChickenButton


func _process(_delta: float) -> void:
	buy_chicken_coop_button.disabled = !GameManager.can_afford(100)
	buy_chicken_button.disabled = !GameManager.can_afford(30)
