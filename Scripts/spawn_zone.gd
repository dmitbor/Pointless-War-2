class_name SpawnZone
extends Node

var zone_location = Vector2(0,0)
var zone_x_size = 100
var zone_y_size = 100
var zone_faction

func set_faction(given_faction):
	zone_faction = given_faction
	
func set_location(start_point : Vector2, size_x : int, size_y : int):
	zone_location = start_point
	zone_x_size = size_x
	zone_y_size = size_y
	
func get_random_location():
	var random_x = randi_range(zone_location[0] , zone_location[0] + zone_x_size)
	var random_y = randi_range(zone_location[1] , zone_location[1] + zone_y_size)
	print("Random Location: " + str(random_x) + "/" + str(random_y) + " for faction #" + str(zone_faction.faction_id))
	return Vector2(random_x, random_y)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
