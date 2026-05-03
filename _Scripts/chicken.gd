extends CharacterBody2D

signal laid_egg

@onready var egg_timer: Timer = $EggTimer
@onready var animations = $AnimatedSprite2D

func _ready() -> void:
	egg_timer.timeout.connect(lay_egg)
	# egg_timer.start(randi_range(60, 180)) # every 1min to 3min
	egg_timer.start(10) # DEBUG: Remove this
	animations.play("idle")
	print("egg timer set to " + str(egg_timer.wait_time) + "sec")

func lay_egg() -> void:
	animations.play("lay_egg")
	await animations.animation_finished
	laid_egg.emit()
	animations.play("idle")
