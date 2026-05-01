extends Node

# Dictionary to store the preloaded sounds for instant playback[cite: 6]
var sounds = {
	"button_click": preload("res://_audio/button_click.wav"),
	"button_click_reverse": preload("res://_audio/button_click_reverse.wav"),
	"harvest": preload("res://_audio/harvest.wav"),
	"hoe": preload("res://_audio/hoe.wav"),
	"plant_seed": preload("res://_audio/plant_seed.wav"),
	"purchase": preload("res://_audio/purchase.wav"),
	"sell": preload("res://_audio/sell.wav")
}

# Pool of players to handle overlapping sounds (e.g., clicking fast)
func play(sound_name: String) -> void:
	if sounds.has(sound_name):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = sounds[sound_name]
		player.play()
		# Clean up the player automatically when the sound finishes
		player.finished.connect(player.queue_free)
