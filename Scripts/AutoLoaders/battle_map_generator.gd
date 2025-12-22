extends Node

var spawn_zones : Array[SpawnZone] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_up_map():
	var map_size_x = DataHandler.map_size_x
	var map_size_y = DataHandler.map_size_y
	
	# Create Subsector web
	DataHandler.set_all_subsectors(map_size_x / 200, map_size_y / 200)
	# Main Point in the center
	var main_cap_point = ControlPoint.new(DataHandler.GetNewPointID())
	main_cap_point.set_point_level(5)
	main_cap_point.set_location(map_size_x / 2, map_size_y / 2 - 100)
	DataHandler.Control_Points.append(main_cap_point)
	
	
	# Side Points for values of 2 and 3, respectively
	for cap in 4:
		var new_side_cap_point = ControlPoint.new(DataHandler.GetNewPointID())
		var min_y = 250
		var y_size = map_size_y - 500
		var min_x = map_size_x / 4
		var x_size = min_x - 250

		if (cap > 1):
			min_x = map_size_x / 2 + 250
		
		if cap % 2 == 0:
			new_side_cap_point.set_point_level(3)
		else:
			new_side_cap_point.set_point_level(2)
		
		var point_location = attempt_to_get_location_within_limits(min_x, x_size, min_y, y_size, new_side_cap_point)
		
		if (point_location):
			new_side_cap_point.set_location(point_location.x, point_location.y)
			DataHandler.Control_Points.append(new_side_cap_point)

	# And the 6 side points for value of 1 each.
	for cap in 6:
		var new_extreme_cap_point = ControlPoint.new(DataHandler.GetNewPointID())
		var min_y = 125
		var y_size = map_size_y - 250
		var min_x = map_size_x / 8
		var x_size = min_x
		
		if (cap > 2):
			min_x = map_size_x - (map_size_x / 6)
			
		var point_location = attempt_to_get_location_within_limits(min_x, x_size, min_y, y_size, new_extreme_cap_point)
		if (point_location):
			new_extreme_cap_point.set_location(point_location.x, point_location.y)
			DataHandler.Control_Points.append(new_extreme_cap_point)
		

func set_spawn_zones(faction_number : int):
	var map_size_x = DataHandler.map_size_x
	var map_size_y = DataHandler.map_size_y
	
	for faction_spawn in range(1, faction_number + 1):
		print(faction_number)
		var new_spawn = SpawnZone.new()
		new_spawn.set_faction(DataHandler.Factions[faction_spawn-1])
		match faction_spawn:
			1:
				new_spawn.set_location(Vector2(50, 50), map_size_x / 16, map_size_y - 100)
			2:
				new_spawn.set_location(Vector2(map_size_x - (map_size_x / 16 - 100), 50), map_size_x / 16, map_size_y - 100)
		spawn_zones.append(new_spawn)
		
		DataHandler.Spawns = spawn_zones

func attempt_to_get_location_within_limits(min_x: int, x_size: int, min_y: int, y_size: int, con_point: ControlPoint, max_tries: int = 15):
		var current_tries = 0
		var failed = false
		
		while current_tries < max_tries:
			failed = false
			var place_vector = Vector2(min_x + randi() % x_size, min_y + randi() % y_size)
			for existing_point in DataHandler.Control_Points:
				# Too close, fail and re-roll!
				if place_vector.distance_to(existing_point.get_location()) < (con_point.con_point_level * 100):
					print("Failed to Place at: " + str(place_vector) + " / " + str(existing_point.get_location()) + " | " + str(place_vector.distance_to(existing_point.get_location())))
					failed = true
					current_tries += 1
					break
					
			if (!failed):
				return place_vector
			
		print("Failed to Place a Capture Point: " + con_point.con_point_ID)
		return null
