extends Node2D

var squad_size_current = 5

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
	# Check every soldier against every landed shot
	for soldier in DataHandler.Soldiers:
		# Remove the dead into their own little Array
		if !soldier.is_alive():
			DataHandler.Dead_Soldiers.append(DataHandler.Soldiers.pop_at(DataHandler.Soldiers.find(soldier)))
		else:
			if (soldier.dude_squad.Squad_Objectives[0].Objective_Type != "Combat"):
				for shot in DataHandler.Shots:
					if shot.shot_to.distance_to(soldier.get_location()) <= soldier.dude_hearing_distance:
						soldier.dude_squad.set_objective_combat("HeardShot")
					if shot.shot_to.distance_to(soldier.get_location()) <= soldier.dude_width:
						if !soldier.make_stat_roll("Luck") && shot.damage != 0:
							soldier.take_damage(shot.damage)
	
	DataHandler.Shots.clear()
	
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

func _physics_process(delta: float) -> void:
	if Engine.get_frames_drawn() % 3 == 0:
		react_to_shots_and_remove_dead()
		do_everything()
		queue_redraw()
	if Engine.get_frames_drawn() % 30 == 0:
		check_objectives()
		check_distances()
		check_for_enemies()
	pass
		
