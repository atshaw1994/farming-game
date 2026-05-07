extends Node

var last_direction = "right"
var target_position = null
var current_target_plot = null
var harvested_crops = [ ]
var seeds = [ "wheat" ]
var decoration_items = [ ]
var gender = "male"

signal player_arrived_at_plot(target_plot)
signal crop_harvested

func arrived_at_plot(target_plot):
	player_arrived_at_plot.emit(target_plot)

func harvest_crop(harvested_crop) -> void:
	harvested_crops.append(harvested_crop.duplicate())
	crop_harvested.emit()

func remove_seed(crop_seed_to_remove:String) -> void:
	seeds.remove_at(seeds.find(crop_seed_to_remove))

func remove_decoration_item(item_to_remove:String) -> void:
	decoration_items.remove_at(decoration_items.find(item_to_remove))

func remove_harvested(item_to_remove:String) -> void:
	harvested_crops.remove_at(harvested_crops.find(item_to_remove))

func set_gender(new_gender: String) -> void:
	gender = new_gender
