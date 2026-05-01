extends Node

# Dictionary to store the preloaded sounds for instant playback[cite: 6]
var sounds = {
	"button_click": preload("res://_Audio/button_click.wav"),
	"harvest": preload("res://_Audio/harvest.wav"),
	"hoe": preload("res://_Audio/hoe.wav"),
	"plant_seed": preload("res://_Audio/plant_seed.wav"),
	"purchase": preload("res://_Audio/purchase.wav"),
	"sell": preload("res://_Audio/sell.wav")
}

# Pool of players to handle overlapping sounds (e.g., clicking fast)
func play(sound_name: String):
	if sounds.has(sound_name):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = sounds[sound_name]
		player.play()
		# Clean up the player automatically when the sound finishes
		player.finished.connect(player.queue_free)
