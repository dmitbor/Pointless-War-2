extends Node2D

var x_offset = 0
var y_offset = 0

var visibility_color = Color(1, 1, 0, .1)
var combat_color = Color(1, 0, 0, .1)

func _draw() -> void:
	# Draw Spawn Zone:
	for spawn in DataHandler.Spawns:
		draw_rect(Rect2(spawn.zone_location + Vector2(x_offset, y_offset), Vector2(spawn.zone_x_size, spawn.zone_y_size)),spawn.zone_faction.faction_color)

	# Draw Capture Point
	for cap in DataHandler.Control_Points:
		var cap_vector : Vector2 = cap.get_draw_vector_loc()
		cap_vector = cap_vector + Vector2(x_offset, y_offset)
		draw_rect(Rect2(cap_vector, Vector2(30 * cap.con_point_level, 30 * cap.con_point_level)), Color.GRAY)
		var cap_color = Color.DARK_GRAY
		if (cap.con_faction):
			cap_color = cap.con_faction.faction_color
		draw_rect(Rect2(Vector2(cap_vector.x + 5 * cap.con_point_level , cap_vector.y + 5 * cap.con_point_level), Vector2(30 * cap.con_point_level - 10 * cap.con_point_level, (30 * cap.con_point_level - 10 * cap.con_point_level) * cap.con_control/cap.con_max_control)), cap_color)
		draw_string(ThemeDB.fallback_font, Vector2(cap_vector.x + 5 * cap.con_point_level , cap_vector.y + 5 * cap.con_point_level), str(cap.con_control) + "/" + str(cap.con_max_control) , HORIZONTAL_ALIGNMENT_LEFT, -1, 20, cap_color)
	
	# Let's draw visual vectors first and separately, so we can force Z-Index
	for soldier in DataHandler.Soldiers:
		var soldier_location : Vector2 = soldier.get_location()
		soldier_location = soldier_location + Vector2(x_offset, y_offset)
		
		if (soldier.dude_squad.Leader == soldier || soldier.dude_squad.Squad_Objectives[0].Objective_Type == "Combat"):
			var vision_array : PackedVector2Array = []
			var soldier_perception_modifier = 0.01 * soldier.dude_stats["Perception"]
			var soldier_sight = soldier.dude_sight_distance
			# Add Soldier's Current Location
			vision_array.append(soldier_location)
			# Add Left Facing
			vision_array.append(Vector2.UP.from_angle(soldier.dude_angle - soldier_perception_modifier) * soldier_sight + soldier_location)
			# Add Facing Line
			vision_array.append(Vector2.UP.from_angle(soldier.dude_angle) * soldier_sight + soldier_location)
			# Add Right Facing
			vision_array.append(Vector2.UP.from_angle(soldier.dude_angle + soldier_perception_modifier) * soldier_sight + soldier_location)
			if soldier.dude_squad.Squad_Objectives[0].Objective_Type == "Combat":
				draw_polygon(vision_array, [combat_color])
			else:
				draw_polygon(vision_array, [visibility_color])
		
	for soldier in DataHandler.Soldiers:
		var soldier_location : Vector2 = soldier.get_location()
		soldier_location = soldier_location + Vector2(x_offset, y_offset)
	
		var soldier_id = soldier.get_id()
		if (soldier.dude_squad.Leader == soldier):
			soldier_id = soldier_id + "   --*--   " + soldier.dude_squad.Squad_Objectives[0].Objective_Type + "/" + soldier.dude_squad.Squad_Objectives[0].Objective_SubType
		
		# Line Pointing to Objective
		if (soldier.dude_squad.Squad_Objectives.size() > 0 && soldier.dude_squad.Squad_Objectives[0].Targets.size() > 0 && soldier.dude_squad.Squad_Objectives[0].Targets[0]):
			# Again, if no valid location, don't point the line.				
			if soldier.dude_squad.Squad_Objectives[0].get_point_target_location():
				var target_loc = soldier.dude_squad.Squad_Objectives[0].get_point_target_location() + Vector2(x_offset, y_offset)
				draw_line(soldier_location, soldier_location.move_toward(target_loc, 20), Color(0, 0, 0, 1), 3.5)
		
		# Line Pointing in front of the Soldier, showing their facing
		#draw_line(soldier_location, Vector2.UP.rotated(soldier.dude_angle) * 25 + soldier_location, Color(0, 0, 0, .5), 2.5)
		draw_line(soldier_location, Vector2.UP.from_angle(soldier.dude_angle) * 35 + soldier_location, Color(0, 0, 0, .5), 2.5)
		
		# Healthbar
		#draw_rect(Rect2(Vector2(soldier_location.x-10, soldier_location.y+10), Vector2(20, 5) * soldier.dude_health/soldier.dude_stats["Endurance"]), soldier.dude_squad.Squad_Faction.faction_color, true)
		# Body
		draw_texture(GraphicLoader.body_txtr, Vector2(soldier_location.x-10, soldier_location.y-10), soldier.dude_squad.Squad_Faction.faction_color)
		# Body Armor/Trim
		var body_armor_info = soldier.get_armor_txtr(0)
		draw_texture(body_armor_info[0], Vector2(soldier_location.x-10, soldier_location.y-10))
		# Head
		draw_texture(GraphicLoader.head_txtr, Vector2(soldier_location.x-8, soldier_location.y-20))
		# Head Armor
		var head_armor_info = soldier.get_armor_txtr(1)
		if head_armor_info[1]:
			draw_texture(head_armor_info[0], Vector2(soldier_location.x-8, soldier_location.y-20), soldier.dude_squad.Squad_Faction.faction_color)
		else:
			draw_texture(head_armor_info[0], Vector2(soldier_location.x-8, soldier_location.y-20))
		# Soldier ID
		draw_string(ThemeDB.fallback_font, Vector2(soldier_location.x, soldier_location.y + 10),soldier_id, HORIZONTAL_ALIGNMENT_LEFT,-1, 20, Color(0, 0, 0, 1))
		# Gun
		if (soldier.dude_squad.Squad_Objectives.size() > 0 && soldier.dude_squad.Squad_Objectives[0].Targets.size() > 0 && soldier.dude_squad.Squad_Objectives[0].Targets[0]):
			var target_loc
			if soldier.dude_individual_target:
				target_loc = soldier.dude_individual_target.get_location()
			elif soldier.dude_squad.Squad_Objectives[0].get_point_target_location():	
				target_loc = soldier.dude_squad.Squad_Objectives[0].get_point_target_location()
			# if we have no valid target, do not try to point a gun to them.
			if target_loc:
				draw_set_transform(Vector2(soldier_location.x-5, soldier_location.y-5), soldier.get_location().angle_to_point(target_loc))
		draw_texture(soldier.dude_weapon.item_img, Vector2(0,0))
		draw_set_transform(Vector2(0,0), 0.0)
		
	
	for shot in DataHandler.Shots:
		var shot_from_mod = shot.shot_from
		var shot_to_mod = shot.shot_to
		shot_from_mod = shot_from_mod + Vector2(x_offset, y_offset)
		shot_to_mod = shot_to_mod + Vector2(x_offset, y_offset)
		draw_line(shot_from_mod,shot_to_mod, Color.YELLOW, 1.0)
	
	if DebugHandler.show_subsectors:
		for slice_x in DataHandler.SubSectors:
			for subsector : SubSector in slice_x:
				#var sub_sect_rect = Rect2(Vector2(100 + subsector.sector_x * 20, 100 + subsector.sector_y * 20), Vector2(180, 180))
				#draw_rect(sub_sect_rect, Color.BEIGE)
				draw_string(ThemeDB.fallback_font, Vector2(110 + subsector.sector_x * 20, 100 + subsector.sector_y * 20), str(subsector.sector_soldiers.size()))


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	queue_redraw()
	#if Engine.get_frames_drawn() % 3 == 0:
		#do_everything()
	pass
