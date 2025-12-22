class_name Dude
extends Node2D

var dude_x = 0
var dude_y = 0

var current_subsector : SubSector

# Name of the Soldier
var dude_name = "Dude Duderson"
# Speed, based on Agility / 10
var dude_speed = 5

# Max Stamina for the Soldier. Used for Running and Melee Combat.
var dude_max_stamina = 50
# Current Stamina of the Soldier.
var dude_stamina = 50

var dude_width = 10

# OLD Health, based on the Endurance
#var dude_health = 20

# Health of individual body parts
# Head, Torso, Right Arm, Left Arm, Right Left, Left Leg
var dude_body_health = [20, 50, 25, 25, 30, 30]
var dude_body_max_health = [20, 50, 25, 25, 30, 30]

# CaptureSpeed, based on Intelligence
var dude_cap_speed = 5
# Sight Distance
var dude_sight_distance = 250
# Hearing Distance
var dude_hearing_distance = 100
# Command value that Officers have, Charisma based
var dude_command_value = 0
# Current Facing Angle
var dude_angle = 0.0

# Currently held item by the Soldier. To replace Held Weapon. References item in inventory.
var dude_held_item : Item
# Rest of the items carried by the soldier.
var dude_inventory : Array[Item]
# How many of soldier's hands are occupied.
var dude_hands_available = 2

# Current Weapon held by Soldier
var dude_weapon : Weapon


# Currently worn armor of the Soldier. First Armor is for body, second is hat/helmet.
var dude_armor : Array[Armor]
#  Current Squad of the Soldier
var dude_squad : Squad
# Skills of the character, Shooting, Melee, Familiarity with Equipment, etc
var dude_skills : Array[Skill] = []

# Current weapon's cooldown.
var shot_cooldown = 0
# Current weapon's remaining shots before having to reload
var shots_remaining = 0
# Current time to reload, remaining
var reload_time_left = 0

# For when in firefight, choose just one guy to fight
var dude_individual_target : Dude

var dude_aim_bonus = 0
var dude_aim_bonus_step = 0
var dude_max_aim_bonus = 0

var dude_ID = 0

#Stealing SPECIAL
var dude_stats = {
		"Strength": 50,
		"Perception": 50,
		"Endurance": 50,
		"Charisma": 50,
		"Intelligence": 50,
		"Agility": 50,
		"Luck": 50,
		"Bravery": 50
}

func _init() -> void:
	#print("I live")
	dude_ID = DataHandler.GetNewSoldierID()
	gen_rand_stats()
	#set_rand_around_loc()
	get_skills()
	dude_weapon = DataHandler.Weapons[randi() % 3]
	if dude_weapon is Gun:
		shots_remaining = dude_weapon.gun_load
		shot_cooldown = 0
	# Hat or Helmet, 50% chance
	dude_armor.append(DataHandler.Armors[randi() % 2])
	# And give Cuirass to one soldier in 10
	if randi_range(0, 10) == 0:
		dude_armor.append(DataHandler.Armors[3])
	else:
		dude_armor.append(DataHandler.Armors[2])
	pass # Replace with function body.

func setSquad(squad):
	dude_squad = squad

func set_to_loc(given_x = 0, given_y = 0):
	if (dude_squad.Leader == self):
		dude_x = given_x
		dude_y = given_y
	else:
		set_rand_around_loc(given_x, given_y)
	current_subsector = DataHandler.add_soldier_to_subsector(self)

func set_rand_around_loc(given_x = 0, given_y = 0):
	if self == dude_squad.Leader:
		dude_x = given_x
		dude_y = given_y
	else:
		var placed = false
		var failed = false
		var new_loc = Vector2.UP.from_angle(randf_range(0, 2 * PI)) * (dude_squad.Members.size() * 10) + Vector2(given_x, given_y)
		
		if new_loc.x > DataHandler.map_size_x:
			new_loc.x = DataHandler.map_size_x
		if new_loc.x < 0:
			new_loc.x = 0
		if new_loc.y > DataHandler.map_size_y:
			new_loc.y = DataHandler.map_size_y
		if new_loc.y < 0:
			new_loc.y = 0
		
		while !placed:
			failed = false
			for squadmate in dude_squad.Members:
				if squadmate != self:
					if new_loc.distance_to(squadmate.get_location()) <= ceil(dude_width + squadmate.dude_width):
						new_loc = Vector2.UP.from_angle(randf_range(0, 2 * PI)) * (dude_squad.Members.size() * 10) + Vector2(given_x, given_y)
						failed = true
						break
			if !failed:
				placed = true
						
		dude_x = new_loc[0]
		dude_y = new_loc[1]

func gen_rand_stats():
	dude_stats["Strength"] = 25 + randi() % 50
	dude_stats["Perception"] = 25 + randi() % 50
	dude_stats["Endurance"] = 25 + randi() % 50
	dude_stats["Charisma"] = 25 + randi() % 50
	dude_stats["Intelligence"] = 25 + randi() % 50
	dude_stats["Agility"] = 25 + randi() % 50
	dude_stats["Luck"] = 25 + randi() % 50
	dude_stats["Bravery"] = 25 + randi() % 50
	
	dude_speed = dude_stats["Agility"] / 10
	dude_command_value = dude_stats["Charisma"] * 10
	dude_cap_speed = dude_stats["Intelligence"] / 10
	#dude_health = dude_stats["Endurance"] 
	
	# Health Stats
	dude_body_health = [dude_stats["Endurance"] / 5, dude_stats["Endurance"], dude_stats["Endurance"] / 3, dude_stats["Endurance"] / 3, dude_stats["Endurance"] / 2, dude_stats["Endurance"] / 2]
	dude_body_max_health = [dude_stats["Endurance"] / 5, dude_stats["Endurance"], dude_stats["Endurance"] / 3, dude_stats["Endurance"] / 3, dude_stats["Endurance"] / 2, dude_stats["Endurance"] / 2]
	
	# Perception Stats
	dude_sight_distance = dude_stats["Perception"] * 5
	dude_hearing_distance = dude_stats["Perception"] * 2
	
	dude_max_stamina = dude_stats["Endurance"] * 2
	dude_stamina = dude_max_stamina
	
	dude_width = ceil((dude_stats["Strength"] + dude_stats["Endurance"]) / 10)
	
	dude_aim_bonus_step = (dude_stats["Perception"] + dude_stats["Intelligence"]) / 200
	dude_max_aim_bonus = (dude_stats["Perception"] + dude_stats["Intelligence"]) / 20

func get_skills():
	var new_skill = Skill.new()
	new_skill.set_skill_info("Shooting", 5, 0, "")
	dude_skills.append(new_skill)
	new_skill.set_skill_info("Melee", 5, 0, "")
	dude_skills.append(new_skill)

func rotate_or_move(target):
	if rotate_to(target) == 0:
		go_towards(target)
	
func go_towards(target):
	var dude_speed_final = dude_speed
	
	if dude_squad.Squad_State == "At Ease":
		dude_speed_final = dude_squad.squad_slowest_speed
	elif dude_squad.Squad_State == "Rush" || dude_squad.Squad_State == "Forming Up":
		dude_speed_final = dude_speed
	
	var stepped = false
	var attempts = 0
	var total_distance = dude_width * 2
	var blocked = false
	var new_location = get_location().move_toward(target.get_location(), dude_speed_final)
	var turn_pref = randi() % 1
	var turn_mod = 0.01 * dude_stats["Agility"]
	if turn_pref == 1:
		turn_mod = 0 - turn_mod
		
	var subsector_loc = DataHandler.get_subsector_loc(dude_x, dude_y, dude_speed)
	var viable_interlopers = DataHandler.get_soldier_from_sector_and_close(current_subsector.sector_x, current_subsector.sector_y, subsector_loc)
	
	while !stepped && attempts < 6:
		blocked = false
		for interloper in viable_interlopers:
			if interloper != self:
				total_distance = dude_width + interloper.dude_width
				# Squad Mates can move closer to each other
				if interloper.dude_squad == dude_squad:
					total_distance = total_distance / 2
				if new_location.distance_to(interloper.get_location()) <= total_distance:
					#print("Too close of distance - Width: " + str(total_distance) + " Distance:" + str(get_location().distance_to(squad_member.get_location())))
					blocked = true
					# Last attempt
					if attempts == 5:
						new_location = Vector2.UP.from_angle(get_location().angle_to_point(interloper.get_location())) * (0 - dude_speed_final) + Vector2(dude_x, dude_y)
						dude_x = new_location.x
						dude_y = new_location.y
		if !blocked:
			stepped = true
			
			if entered_new_sector():
				# Remove Self from Subsector
				current_subsector.sector_soldiers.remove_at(current_subsector.sector_soldiers.find(self))
				current_subsector = DataHandler.add_soldier_to_subsector(self, new_location.x, new_location.y)
			dude_x = new_location.x
			dude_y = new_location.y
		else:
			attempts += 1
			new_location = Vector2.UP.from_angle(dude_angle + (turn_mod * attempts)) * dude_speed_final + Vector2(dude_x, dude_y)
			#print("Failed to step #:" + str(attempts))
	
	
func rotate_to(target):
	var target_angle = get_location().angle_to_point(target.get_location())
	
	if dude_angle == target_angle:
		return 0
	elif dude_angle < target_angle:
		dude_angle += 0.01 * dude_stats["Agility"]
		if (dude_angle > target_angle):
			dude_angle = target_angle
			return 0
		return target_angle - dude_angle
	elif dude_angle > target_angle:
		dude_angle -= 0.01 * dude_stats["Agility"]
		if (dude_angle < target_angle):
			dude_angle = target_angle
			return 0
		return dude_angle - target_angle
	
	
func capture_target(target : ControlPoint):
	if target.con_faction:
		if target.con_faction.faction_id != dude_squad.Squad_Faction.faction_id:
			if target.con_control >= 0:
				target.con_control = target.con_control - dude_cap_speed
				if (target.con_control < 0):
					target.con_control = abs(target.con_control)
					target.con_faction = dude_squad.Squad_Faction
		else:
			target.con_control = target.con_control + dude_cap_speed
			if target.con_control > target.con_max_control:
				target.con_control = target.con_max_control
	else:
		target.con_faction = dude_squad.Squad_Faction
		target.con_control = dude_cap_speed
		if target.con_control > target.con_max_control:
			target.con_control = target.con_max_control
	
func select_closest_target():
	var cur_targets = dude_squad.Squad_Objectives[0].Targets
	# Set the targets to be members of the target squad
	if cur_targets[0] is Squad:
		cur_targets = cur_targets[0].Members
	var cur_closest
	var cur_distance = 0
	
	for new_target_sel in cur_targets:
		if new_target_sel.is_alive():
			var new_distance = get_location().distance_to(new_target_sel.get_location())
			if (!cur_closest || new_distance < cur_distance):
				cur_distance = new_distance
				cur_closest = new_target_sel
	# Set the new target to newest
	dude_individual_target = cur_closest
	
func look_for_targets_around(targets_array : Array, first_frame = false, assign_now = false):
	if (!first_frame):
		# Always looks away from Squad Leader
		var squad_leader_angle = 0
		if dude_squad.Leader != self:
			squad_leader_angle = get_location().angle_to(dude_squad.Leader.get_location())
		if (squad_leader_angle > dude_angle):
			dude_angle -= 0.01 * dude_stats["Agility"]
		else:
			dude_angle += 0.01 * dude_stats["Agility"]
		
	# Check through all Soldiers. Yeah, who needs optimization!
	for other_dude in DataHandler.Soldiers:
		# Make sure we're looking for enemies
		if dude_squad.Squad_Faction != other_dude.dude_squad.Squad_Faction:
			if get_location().distance_to(other_dude.get_location()) <= dude_sight_distance:
				var min_angle = dude_angle - 0.01 * dude_stats["Perception"]
				var max_angle = dude_angle + 0.01 * dude_stats["Perception"]
				var angle_to_dude = get_location().angle_to(other_dude.get_location())
				if min_angle <= angle_to_dude && angle_to_dude <= max_angle:
					if assign_now:
						dude_individual_target = other_dude
					if other_dude in targets_array:
						targets_array.append(other_dude)
	
	
func go_towards_or_shoot():
	# Always face opponents directly to shoot at them. If we do face them exactly (Difference of Angle of 0)
	if rotate_to(dude_individual_target) < dude_stats["Agility"]:
		# If we're too far for the weapon, get closer.
		if dude_weapon is Gun:
			if dude_weapon.gun_range < get_location().distance_to(dude_individual_target.get_location()) || dude_sight_distance < get_location().distance_to(dude_individual_target.get_location()):
				#print("Gotta Move Closer: DST - " + str(get_location().distance_to(dude_individual_target.get_location())) + " RNG: " + str(dude_weapon.gun_range) + " SGT: " + str(dude_sight_distance))
				go_towards(dude_individual_target)
			# If the soldier is in range of the enemy:
			else:
				#print("Gotta shoot the target")
				# Still got ammo
				if shots_remaining > 0:
				# If gun can't shoot yet or we haven't gotten max aim bonus yet AND we pass an Intelligence roll modified by existing aim bonus - AIM more
					if shot_cooldown > 0 || (dude_aim_bonus < dude_max_aim_bonus && randi_range(0, 100) <= (dude_stats["Intelligence"] - dude_aim_bonus)):
						wait_to_refire()
						#print("Aiming Current: " + str(dude_aim_bonus) + " Max:" + str(dude_max_aim_bonus))
						dude_aim_bonus += dude_aim_bonus_step
						# Check that aim doesn't overshot max by accident
						if dude_aim_bonus > dude_max_aim_bonus:
							dude_aim_bonus = dude_max_aim_bonus
					# if we're ready to aim or too antsy to aim, FIRE!
					else:
						fire_at_target()
				else:
					#print("Gotta reload")
					reload_weapon()
	
func fire_at_target():
	var shot_value = randi_range(0, 100)
	var skill_mod = 0
	var shot_ability = (dude_stats["Perception"] + dude_stats["Agility"]) / 2
	
	for skill in dude_skills:
		if (skill.skill_name == "Shooting"):
			skill_mod = skill_mod + skill.skill_value
	
	if shot_ability + skill_mod + dude_aim_bonus >= shot_value:
		dude_individual_target.take_damage(dude_weapon.weapon_damage)
		#print("shot hit! " + str(target_range) + "|"+ str(shot_value + skill_mod + dude_aim_bonus))
		DataHandler.add_shot(get_location(), dude_individual_target.get_location(), 0)
	else:
		#print("shot missed! " + str(shot_value) + "|"+ str(shot_ability + skill_mod + dude_aim_bonus))
		var differential = abs(shot_ability - shot_value + skill_mod + dude_aim_bonus)
		var new_end_point = dude_individual_target.get_location() + Vector2(randi_range(0 - differential, differential),randi_range(0 - differential, differential))
		DataHandler.add_shot(get_location(), new_end_point, dude_weapon.weapon_damage)
		
	shot_cooldown = dude_weapon.gun_refire_rate
	shots_remaining = shots_remaining - 1
	if shots_remaining == 0:
		reload_time_left = dude_weapon.gun_reload_time
	# Refresh aim bonus after the shot is done
	dude_aim_bonus = 0
	
func take_damage(weapon_damage):
	var hit_loc = randi_range(1, 15)
	var damage_location = 1
	var total_armor = get_armor_total()
	
	match hit_loc:
		# Head
		1:
			damage_location = 0
		# Torso
		2,3,4,5,6,7:
			damage_location = 1
		# RArm
		8, 9:
			damage_location = 2
		# LArm
		10, 11:
			damage_location = 3
		# Rleg
		12, 13:
			damage_location = 4
		# LLeg
		14, 15:
			damage_location = 5
	
	var mod_weapon_damage = weapon_damage - total_armor[damage_location]
	if mod_weapon_damage < 0:
		mod_weapon_damage = 0
	dude_body_health[damage_location] -= mod_weapon_damage
	if dude_body_health[damage_location] < 0:
		dude_body_health[damage_location] = 0
	
	if (!is_alive()):
		if (current_subsector):
			current_subsector.sector_soldiers.remove_at(current_subsector.sector_soldiers.find(self))
			current_subsector = null
		dude_squad.recount_squad_speed()
		if (dude_squad.Leader == self):
			dude_squad.find_new_leader()
	
func wait_to_refire():
	shot_cooldown = shot_cooldown - 1
	
func reload_weapon():
	#print(str(dude_ID) + " Reloading! " + str(reload_time_left))
	var reload_completion = randi_range(0, (dude_stats["Agility"] + dude_stats["Intelligence"]) / 2)
	reload_time_left = reload_time_left - reload_completion
	if 0 >= reload_time_left:
		#print("Reloaded!")
		shots_remaining = dude_weapon.gun_load
		shot_cooldown = 0
	
func find_item(searched_name : String):
	for i in range(dude_inventory.size()):
		if dude_inventory[i].item_name == searched_name:
			return i
	# Return -1 if item is not found
	return -1
	
func switch_item(item_index : int):
	dude_held_item = dude_inventory[item_index]
	dude_hands_available = 2 - dude_held_item.hands_usage
	
func move_lad_rand():
	dude_x = dude_x + (randi_range(-1, 1) * dude_speed)
	dude_y = dude_y + (randi_range(-1, 1) * dude_speed)
	
func get_location():
	return Vector2(dude_x, dude_y)
	
func get_id():
	return str(dude_squad.Squad_ID) + " " + str(dude_ID)
	
func is_alive():
	if dude_body_health[0] == 0 || dude_body_health[1] == 0:
		return false
	else:
		return true
		
func get_armor_total():
	var total_armor = [0,0,0,0,0,0]
	for armor in dude_armor:
		total_armor[0] += armor.armor_values[0]
		total_armor[1] += armor.armor_values[1]
		total_armor[2] += armor.armor_values[2]
		total_armor[3] += armor.armor_values[3]
		total_armor[4] += armor.armor_values[4]
		total_armor[5] += armor.armor_values[5]
	return total_armor

func get_armor_txtr(type):
	for armor in dude_armor:
		if armor.armor_type == type:
			return [armor.item_img, armor.remapable]

func get_matching_armor_type(type):
	for armor in dude_armor:
		if armor.armor_type == type:
			return armor

func make_stat_roll(Stat : String):
		return randi_range(0, 100) <= dude_stats[Stat]

func entered_new_sector():
	var sector_x = int(dude_x / 200) - 1
	var sector_y = int(dude_y / 200) - 1
	
	if sector_x == current_subsector.sector_x && sector_y == current_subsector.sector_y:
		return false
	else:
		return true
