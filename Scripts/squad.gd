class_name Squad
extends Node

# Faction of the Squad
var Squad_Faction : Faction
# Squad Leader
var Leader : Dude
# Squad Members
var Members : Array[Dude] = []
# Squad ID for testing and Identification
var Squad_ID
#Current State of the Squad: At Ease, In Combat, Rushing, Recouperating, etc
var Squad_State = "At Ease"
#Current lowest squad speed, so no one outruns each other
var squad_slowest_speed = 100
# Current Squad Objective
var Squad_Objectives : Array[Objective] = []

func gen_Members(squad_size = 5):
	#print ("creating squad with size of " + str(squad_size))
	for mem_count in range(squad_size):
		#print("Creating new dude")
		var new_dude = Dude.new()
		if (mem_count == 0):
			Leader = new_dude
		new_dude.setSquad(self)
		Members.append(new_dude)
		DataHandler.Soldiers.append(new_dude)

func find_new_leader():
	var new_leader = null
	Leader = null
	for dude in Members:
		if dude.is_alive():
			if !new_leader || dude.dude_stats["Charisma"] > new_leader.dude_stats["Charisma"]:
				new_leader = dude
	Leader = new_leader
	if !Leader:
		new_leader = Members[0]
	

func recount_squad_speed():
	var lowest_speed = 100
	for dude in Members:
		if (dude.dude_speed < lowest_speed):
			lowest_speed = dude.dude_speed
	
	# Set Squad Speed to slowest Dude
	squad_slowest_speed = lowest_speed

func set_to_loc(squad_x, squad_y):
	for member in Members:
		member.set_to_loc(squad_x, squad_y)

func set_squad_info(squad_size, squad_x = 0, squad_y = 0) -> void:
	Squad_ID = DataHandler.GetNewSquadID()
	gen_Members(squad_size)
	recount_squad_speed()
	if squad_x == squad_y && squad_y == 0:
		var spawn_info : SpawnZone = DataHandler.GetSpawnForFactionId(Squad_Faction.faction_id)
		var random_loc = spawn_info.get_random_location()
		set_to_loc(random_loc[0], random_loc[1])
	else:
		set_to_loc(squad_x, squad_y)
	pass # Replace with function body.

func set_faction(faction):
	Squad_Faction = faction

func remove_completed_objectives():
	#print("Removing done Objectives")
	if (Squad_Objectives.size() > 0):
		for index in range(Squad_Objectives.size()-1, -1, -1):
			if Squad_Objectives[index].Complete == true:
				print("Objective Complete: " + Squad_Objectives[index].Objective_Type)
				Squad_Objectives.remove_at(index)
		
func add_objective_if_none():
	if Squad_Objectives.size() == 0:
		var closest_cap
		var closest_cap_distance = 0
		
		for cap_point in DataHandler.Control_Points:
			# Uncaptured point or owned by another faction
			if (!cap_point.con_faction || cap_point.con_faction != Squad_Faction):
				var cap_point_distance = Leader.get_location().distance_to(cap_point.get_location())
				
				if (!closest_cap || cap_point_distance < closest_cap_distance):
					closest_cap_distance = cap_point_distance
					closest_cap = cap_point
					
		# Capture Point found, go capture it.
		if closest_cap:
			set_objective_cap(closest_cap)
			return
		# If no Capture Point to take, look for viable enemy squads
		else:
			for squad in DataHandler.Squads:
				# Does the Squad belong to enemy and is it still alive?
				if (squad.Squad_Faction != Squad_Faction && squad.Leader):
				# If enemy Squad is found, go for the kill!
					set_objective_kill(squad)
					return
			
			# No Squads found to kill (Yet). Time to sit around and wait.
			set_objective_wait()

func check_for_enemies():
	var my_fac_id = Squad_Faction.faction_id
	
	# If the squad is not in combat, only Officer will be on the lookout for enemies.
	if Squad_Objectives[0].Objective_Type != "Combat":
		# Get Officer's Sight Stats for quick reference:
		var officer_angle = Leader.dude_angle
		var officer_prcptn_mod = 0.01 * Leader.dude_stats["Perception"]
		var min_angle = officer_angle - officer_prcptn_mod
		var max_angle = officer_angle + officer_prcptn_mod
		var officer_maxsight = Leader.dude_sight_distance
		var officer_maxhear = Leader.dude_hearing_distance
		
		# Go through every soldier
		for SearchedSoldier in DataHandler.Soldiers:
			# Seeing someone alive and not in my faction:
			if (SearchedSoldier.is_alive() && SearchedSoldier.dude_squad.Squad_Faction.faction_id != my_fac_id):
				# Then, check if the character isn't beyond max distance of sight:
				if (Leader.get_location().distance_to(SearchedSoldier.get_location()) <= officer_maxsight):
					# Get Angle to viable target:
					var enemy_angle = Leader.get_location().angle_to_point(SearchedSoldier.get_location())
					
					# Check if within Sight
					if min_angle <= enemy_angle && enemy_angle <= max_angle:
						set_objective_combat("Sighted", SearchedSoldier)
						return
					else:
					# Check to see if they are within hearing distance of me:
						if Leader.get_location().distance_to(SearchedSoldier.get_location()) <= officer_maxhear:
							set_objective_combat("Heard")
							return
	# If we're in a fight, every soldier is always on lookout for enemies.				
	else:
		print("Search for enemies in the fight")
		var obj_targets = Squad_Objectives[0].Targets
		
		for member in Members:
			var soldier_angle = member.dude_angle
			var soldier_prcptn_mod = 0.01 * member.dude_stats["Perception"]
			var min_angle = soldier_angle - soldier_prcptn_mod
			var max_angle = soldier_angle + soldier_prcptn_mod
			var soldier_maxsight = member.dude_sight_distance
			var soldier_maxhear = member.dude_hearing_distance
		
			# Go through every soldier
			for SearchedSoldier in DataHandler.Soldiers:
				# Seeing someone alive and not in my faction and also isn't already a target:
				if (SearchedSoldier.is_alive() && SearchedSoldier.dude_squad.Squad_Faction.faction_id != my_fac_id && !(SearchedSoldier in obj_targets)):
					# Then, check if the character isn't beyond max distance of sight:
					if (member.get_location().distance_to(SearchedSoldier.get_location()) <= soldier_maxsight):
						# Get Angle to viable target:
						var enemy_angle = member.get_location().angle_to_point(SearchedSoldier.get_location())
						
						# Check if within Sight
						if min_angle <= enemy_angle && enemy_angle <= max_angle:
							obj_targets.append(SearchedSoldier)
							return
						else:
						# Check to see if they are within hearing distance of me:
							if member.get_location().distance_to(SearchedSoldier.get_location()) <= soldier_maxhear:
								obj_targets.append(SearchedSoldier)
								return
								
		# Clear Dead Enemies from Target Array.
		for index in range(obj_targets.size()-1, -1, -1):
			if !obj_targets[index].is_alive():
				obj_targets.remove_at(index)
				
		# If no enemies are left as targets, end combat for the squad.
		if obj_targets.size() == 0:
			print("Combat Over!")
			for soldier in Members:
				soldier.dude_individual_target = null
			Squad_Objectives[0].complete_objective()

func check_distance_to_squadmates():
	if (Squad_State != "Combat" && Leader && Leader.is_alive()):
		var command_value = Leader.dude_command_value
					
		var in_cohession = true
					
		for squadie in Members:
			if squadie.dude_ID != Leader.dude_ID:
				var distance_to_leader = squadie.get_location().distance_to(Leader.get_location())
				#print(distance_to_leader)
				if distance_to_leader > command_value && !Squad_Objectives[0].Objective_Type == "Squad Cohesion":
					#print("A Dude is too far!")
					in_cohession = false
					print(Squad_ID)
					print(command_value)
					print(distance_to_leader)
					set_cohesion_objective()
					print("Getting Back into Cohesion")
					return
		#If everyone is in the cohesion, accomplish the goal
		if Squad_Objectives[0].Objective_Type == "Squad Cohesion" && in_cohession:
			#print("Everyone's in coherence")
			Squad_Objectives[0].complete_objective()

func set_objective_cap(capture_point):
	print("Adding Capture Point Objective: " + str(Squad_ID))
	var goto_cap = Objective.new()
	goto_cap.set_type("Capture Point")
	goto_cap.add_target(capture_point)
	set_State("At Ease")
	Squad_Objectives.push_front(goto_cap)

func set_objective_kill(target):
	print("Adding Hunting Objective " + str(Squad_ID))
	var kill_squad = Objective.new()
	kill_squad.set_type("Hunt Down")
	kill_squad.add_target(target)
	set_State("Hunting")
	Squad_Objectives.push_front(kill_squad)

func set_objective_combat(type : String, first_target = null):
	print("Adding Combat Objective: " + str(Squad_ID))
	
	var start_combat = Objective.new()
	
	set_State("Combat")
	start_combat.set_type("Combat")
	
	match type:
		# We saw the enemy, probably have time to acquire targets before engaging
		"Sighted":
			start_combat.set_subtype("CleanSearchCombat")
			start_combat.set_objective_time(15)
		# Head someone near-by, search for all targets, then engage
		"Heard":
			start_combat.set_subtype("SearchCombat")
			start_combat.set_objective_time(10)
		# Shot landed by, grab a target then engage!
		"HeardShot":
			start_combat.set_subtype("PanicSearchCombat")
		_:
			print("How the hell we got here?")
	
	if first_target:
		start_combat.Targets.append(first_target)
	
	Squad_Objectives.push_front(start_combat)
	
func set_objective_wait(wait_time = 100):
	print("Adding Waiting Objective " + str(Squad_ID))
	var wait = Objective.new()
	wait.set_type("Wait")
	wait.set_objective_time(wait_time)
	set_State("Waiting")
	Squad_Objectives.push_front(wait)

func set_State(new_state):
	Squad_State = new_state

func set_cohesion_objective():
	print("Adding Cohesion Objective " + str(Squad_ID))
	var wait_up = Objective.new()
	wait_up.set_type("Squad Cohesion")
	wait_up.add_target(Leader)
	set_State("Forming Up")
	Squad_Objectives.push_front(wait_up)

func act_out():
	if (Squad_Objectives.size() > 0 && !Squad_Objectives[0].Complete):
		match Squad_Objectives[0].Objective_Type:
			"Wait":
				Squad_Objectives[0].count_time()
			_:
				# Go through each Squad Member who are alive, and make them do things
				for member in Members:
					if member.is_alive():
						match Squad_Objectives[0].Objective_Type:
							"Capture Point":
								var ObjContPoint : ControlPoint = Squad_Objectives[0].Targets[0]
								# Capture the point if we're close enough
								if member.get_location().distance_to(ObjContPoint.get_location()) <= ObjContPoint.con_point_level * 10:
								#print("Capturing")
									member.capture_target(ObjContPoint)
									if ObjContPoint.fully_captured(Squad_Faction):
										Squad_Objectives[0].complete_objective()
								# Too far, move towards the Control Point
								else:
									member.rotate_or_move(ObjContPoint)
							"Squad Cohesion":
								member.rotate_or_move(Leader)
							"Combat":
								var first_frame = false
								if Squad_Objectives[0].count_time() == 0:
									first_frame = true
								match Squad_Objectives[0].Objective_SubType:
									# Search for all viable targets until wait time, then engage.
									"CleanSearchCombat":
										member.look_for_targets_around(Squad_Objectives[0].Targets, first_frame)
									# Everyone finds a target, then open fire.
									"SearchCombat":
										member.look_for_targets_around(Squad_Objectives[0].Targets, first_frame, true)
									# Search and engage immediately upon finding any target.
									"PanicSearchCombat":
										# No target? Find one NOW!
										if !member.dude_individual_target:
											member.look_for_targets_around(Squad_Objectives[0].Targets, first_frame, true)
										# Engage if we go target
										else:
											member.go_towards_or_shoot()
									# Keep fighting.
									"MidCombat":
										if !member.dude_individual_target || !member.dude_individual_target.is_alive():
											member.select_closest_target()
										# Engage if we go target
										else:
											member.go_towards_or_shoot()
			
				# After everyone is done finding targets, set them to regular combat
				if Squad_Objectives[0].Objective_Type == "Combat":
					match Squad_Objectives[0].Objective_SubType:
						# Once we reach the max search time, set to mid-combat Objective Type
						"CleanSearchCombat":
							Squad_Objectives[0].count_time()
							if (Squad_Objectives[0].Objective_SubType == "MidCombat"):
								if (Squad_Objectives[0].Targets.size() > 0):
									# Assign closest target to each soldier.
									assign_targets()
						# We either all got targets and will engage or ran out of time for search
						"SearchCombat":
							var all_got_targets = true
							for member in Members:
								if !member.dude_individual_target:
									all_got_targets = false
							
							Squad_Objectives[0].count_time()
							if (Squad_Objectives[0].Targets.size() > 0):
								if (all_got_targets || Squad_Objectives[0].Objective_SubType == "MidCombat"):
									if (!all_got_targets):
										assign_targets()
									Squad_Objectives[0].Objective_SubType = "MidCombat"
									
						"PanicSearchCombat":
							var all_got_targets = true
							for member in Members:
								if !member.dude_individual_target:
									all_got_targets = false
							
							if (all_got_targets):
								if (Squad_Objectives[0].Targets.size() == 0):
									print("Got no targets, how the hell did everyone get some?")
									print("Squad ID: " + str(Squad_ID))
									for member in Members:
										print(member.dude_individual_target.get_id())
									return
								Squad_Objectives[0].Objective_SubType = "MidCombat"
								print("Entering Combat with " + str(Squad_Objectives[0].Targets.size()) + " targets")

func assign_targets():
	for member in Members:
		member.select_closest_target()

func get_leader_or_next_soldier():
	if Leader && Leader.is_alive():
		return Leader.get_location()
	else:
		for soldier in Members:
			if soldier.is_alive():
				return soldier.get_location() 

func count_live_members():
	var live_members = 0
	for soldier in Members:
		if soldier.is_alive():
			live_members += 1
	return live_members
