extends Node2D

var squad_size_current = 5
var selected_dude

func do_everything():
	#print(str(DataHandler.Soldiers.size()))
	#print(str(Squads.size()))
	
	for squad in DataHandler.Squads:
		if squad.count_live_members() == 0:
			print("Found Dead Squad! " + str(squad.Squad_ID))
			DataHandler.Dead_Squads.append(DataHandler.Squads.pop_at(DataHandler.Squads.find(squad)))
		# Confirm that the Squad Leader exists, which means at least someone is.
		elif squad.Leader:
			#squad.remove_completed_objectives()
			#squad.add_objective_if_none()
			#squad.check_distance_to_squadmates()
			#squad.check_for_enemies()
			squad.act_out()
		# Place Killed Squads into separate Squad Array
		
	
func react_to_shots_and_remove_dead():
	# Check every soldier in the Soldier Array
	for soldier in DataHandler.Soldiers:
		# Remove the dead into their own little Array
		if !soldier.is_alive():
			DataHandler.Dead_Soldiers.append(DataHandler.Soldiers.pop_at(DataHandler.Soldiers.find(soldier)))
		else:
			if DataHandler.Shots.size() > 0:
				# Check for every shot in the close subsectors to the soldier
				var subsector_loc = DataHandler.get_subsector_loc(soldier.dude_x, soldier.dude_y, soldier.dude_width)
				var viable_shots = DataHandler.get_shots_from_sector_and_close(soldier.current_subsector.sector_x, soldier.current_subsector.sector_y, subsector_loc)
				
				if viable_shots:
					for shot in viable_shots:
						if shot.shot_to.distance_to(soldier.get_location()) <= soldier.dude_width:
							if !soldier.make_stat_roll("Luck") && shot.damage != 0:
								print("unlucky!")
								soldier.take_damage(shot.damage)
						
						if shot.shot_to.distance_to(soldier.get_location()) <= soldier.dude_hearing_distance && soldier.dude_squad.Squad_Objectives[0].Objective_Type != "Combat":
							soldier.dude_squad.set_objective_combat("HeardShot")
			DataHandler.Shots.clear()
			DataHandler.clear_all_shot_arrays()
	
func check_objectives():
	for squad in DataHandler.Squads:
		# Confirm that the Squad Leader exists, which means at least someone is.
		if squad.Leader:
			squad.remove_completed_objectives()
			squad.add_objective_if_none()
	
func check_distances():
	for squad in DataHandler.Squads:
		# Confirm that the Squad Leader exists, which means at least someone is.
		if squad.Leader:
			squad.check_distance_to_squadmates()
	
func check_for_enemies(): 
	for squad in DataHandler.Squads:
		# Confirm that the Squad Leader exists, which means at least someone is.
		if squad.Leader:
			squad.check_for_enemies()
	
func Spawn_Squads():
	for squads in 2:
		print("Generating Squad: " + str(squads))
		var cur_squad = Squad.new()
		cur_squad.set_faction(DataHandler.Factions[squads%2])
		cur_squad.set_squad_info(squad_size_current)
		cur_squad.add_objective_if_none()
		DataHandler.Squads.append(cur_squad)
	
func  _input(event):
	if event is InputEventWithModifiers && event.is_pressed() && event is not InputEventMouseButton:
		var key_modifier = 1
		if event.shift_pressed:
			key_modifier = 3
		match event.keycode:
			KEY_UP:
				DrawScript.y_offset += 10 * key_modifier
			KEY_DOWN:
				DrawScript.y_offset -= 10 * key_modifier
			KEY_LEFT:
				DrawScript.x_offset += 10 * key_modifier
			KEY_RIGHT:
				DrawScript.x_offset -= 10 * key_modifier
			KEY_SPACE:
				Spawn_Squads()
			KEY_EQUAL:
				print("More squad")
				squad_size_current = squad_size_current + 1
			KEY_MINUS:
				print("LESS SQUAD")
				squad_size_current = squad_size_current - 1
				if squad_size_current < 1:
					squad_size_current = 1
			KEY_CTRL:
				if DebugHandler.show_subsectors:
					print("Hidding Subsectors")
					DebugHandler.show_subsectors = false
				else:
					print("Showing Subsectors")
					DebugHandler.show_subsectors = true
	if event is InputEventMouseButton and event.is_released():
		if event.button_index == 2:
			var offset_loc = event.position + Vector2(abs(DrawScript.x_offset), abs(DrawScript.y_offset))
			print(offset_loc)
			var distance = 0
			var soldier_found = false
			var statmenu : PanelContainer = $"UI Menus/MainPanelCont"
			for soldier in DataHandler.Soldiers:
				distance = soldier.get_location().distance_to(offset_loc)
				#print(str(soldier.dude_squad.Squad_ID) + "|X/Y:" + str(soldier.get_location()) + "|" + str(soldier.get_id()) + "|" + str(distance))
				if distance <= soldier.dude_width * 2:
					if (selected_dude != soldier):
						selected_dude = soldier
						print(soldier)
						statmenu.position = Vector2(0,28)
						soldier_found = true
						DataHandler.Selected_Dude = soldier
						return
			if !soldier_found:
				selected_dude = null
			if !selected_dude:
				statmenu.position = Vector2(-240,28)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Starting")
	
	DataHandler.CreateNewFaction("Rude Republic", Color(randf(), randf(), randf(), 1))
	DataHandler.CreateNewFaction("Envious Empire", Color(randf(), randf(), randf(), 1))
	
	DataHandler.AddNewWeapon("Rifle", 2, 12, 30, 500, 5, 100, GraphicLoader.rifle_txtr, 90)
	DataHandler.AddNewWeapon("Pistol", 1, 3, 10, 150, 8, 50, GraphicLoader.pistol_txtr, 20)
	DataHandler.AddNewWeapon("SMG", 2, 9, 12, 250, 15, 75, GraphicLoader.smg_txtr, 5)
	
	DataHandler.AddNewArmor("Hat", 1, 1, 2, 0, 0, 0, 0, 0, GraphicLoader.hat_txtr, true)
	DataHandler.AddNewArmor("Helmet", 3, 1, 5, 0, 0, 0, 0, 0, GraphicLoader.helmet_txtr)
	DataHandler.AddNewArmor("Uniform", 2, 0, 0, 2, 1, 1, 1, 1, GraphicLoader.uniform_txtr)
	DataHandler.AddNewArmor("Cuirass", 10, 0, 0, 10, 2, 2, 1, 1, GraphicLoader.cuirass_txtr)
	
	BattleMapGenerator.set_up_map()
	BattleMapGenerator.set_spawn_zones(2)
	
	# Make some Squads
	for squads in 4:
		print("Generating Squad: " + str(squads))
		var cur_squad = Squad.new()
		cur_squad.set_faction(DataHandler.Factions[squads%2])
		cur_squad.set_squad_info(squad_size_current)
		cur_squad.add_objective_if_none()
		DataHandler.Squads.append(cur_squad)
	pass

func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(30,30), "Squad Size:" + str(squad_size_current), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0, 0, 0, 1))
	draw_string(ThemeDB.fallback_font, Vector2(30,50), "Live Soldiers:" + str(DataHandler.Soldiers.size()), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0, 0, 0, 1))
	draw_string(ThemeDB.fallback_font, Vector2(30,70), "Live Squads:" + str(DataHandler.Squads.size()), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0, 0, 0, 1))
	draw_string(ThemeDB.fallback_font, Vector2(30,90), "Dead Soldiers:" + str(DataHandler.Dead_Soldiers.size()), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0, 0, 0, 1))

func _physics_process(_delta: float) -> void:
	if Engine.get_frames_drawn() % 3 == 0:
		react_to_shots_and_remove_dead()
		do_everything()
		queue_redraw()
	if Engine.get_frames_drawn() % 30 == 0:
		check_objectives()
		check_distances()
		check_for_enemies()
	pass
