extends Node

var crop_value_dict = { "wheat": 4, "potato": 6, "tomato": 10 }

func get_crop_sell_value(crop_name: String) -> int:
	if crop_value_dict.has(crop_name):
		return crop_value_dict[crop_name]
	
	return 0
