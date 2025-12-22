extends Node

var Factions : Array[Faction] = []
var Cur_Faction_ID = 1

var Soldiers : Array[Dude] = []
var cur_soldier_ID = 1

var Dead_Soldiers : Array[Dude] = []

var Squads : Array[Squad] = []
var cur_squad_ID = 1

var SubSectors : Array[Array] = []

var Dead_Squads : Array[Squad] = []

var Control_Points : Array[ControlPoint] = []
var cur_conpoint_ID = 1

var Weapons : Array[Weapon] = []
var cur_weapon_ID = 1

var Armors : Array[Armor] = []
var cur_armor_ID = 1

var Shots : Array[Shot] = []

var Skills : Array[Skill] = []

var Spawns : Array[SpawnZone] = []

var Selected_Dude : Dude = null
var Selected_Item : Item = null

var map_size_x : int = 2000
var map_size_y : int = 1000

func CreateNewFaction(new_fac_name, new_fac_color):
	Factions.append(Faction.new(GetNewFactionID(), new_fac_name, new_fac_color))

func AddNewWeapon(given_name : String, given_hands : int, given_weight : int, given_damage : int, given_range : int, given_load : int, given_reload_time : int, given_graphic, given_refire_rate : int, given_fire_rate = 1, given_users = 1, given_acc_mod = 0):
	Weapons.append(Gun.new(given_name, given_hands, given_weight, given_damage, given_range, given_load, given_reload_time, given_graphic, given_refire_rate, given_fire_rate, given_users, given_acc_mod))

func AddNewArmor(armor_name, armor_weight, armor_given_type, head_armor, body_armor, rarm_armor, larm_armor, rleg_armor, lleg_armor, armor_graphic, remapable = false):
	Armors.append(Armor.new(armor_name, armor_weight, armor_given_type, head_armor, body_armor, rarm_armor, larm_armor, rleg_armor, lleg_armor, armor_graphic, remapable))


func GetNewFactionID():
	Cur_Faction_ID = Cur_Faction_ID + 1
	return Cur_Faction_ID - 1

func GetNewSquadID():
	cur_squad_ID = cur_squad_ID + 1
	return cur_squad_ID - 1

func GetNewSoldierID():
	cur_soldier_ID = cur_soldier_ID + 1
	return cur_soldier_ID - 1
	
func GetNewPointID():
	cur_conpoint_ID = cur_conpoint_ID + 1
	return cur_conpoint_ID - 1

func GetSpawnForFactionId(id):
	for spawn in Spawns:
		if spawn.zone_faction.faction_id == id:
			return spawn
	return null

func add_shot(from, to, damage):
	var new_shot = Shot.new()
	new_shot.shot_from = from
	new_shot.shot_to = to
	new_shot.damage = damage
	Shots.append(new_shot)
	add_shot_to_subsector(new_shot)

# There are no 2D Array in Godot because we can't have nice things. So we shove arrays into arrays!
func set_all_subsectors(mapsize_x = 10, mapsize_y = 5):
	SubSectors.resize(mapsize_x)
	for x in range(mapsize_x):
		var y_array: Array[SubSector]
		y_array.resize(mapsize_y)
		for y in range(mapsize_y):
			y_array[y] = SubSector.new(x, y)
		SubSectors[x] = y_array
		
func get_soldiers_from_subsector(sector_x, sector_y):
	if sector_x < 0 || sector_y < 0 || SubSectors.size() <= sector_x:
		return null
	var sub_sector_row = SubSectors[sector_x]
	if sub_sector_row.size() <= sector_y:
		return null
	return sub_sector_row[sector_y].sector_soldiers

func get_soldier_from_sector_and_close(sector_x, sector_y, numpad_dir):
	var soldier_array : Array[Dude] = []
	var sub_sector_row = SubSectors[sector_x]
	soldier_array.append_array(sub_sector_row[sector_y].sector_soldiers)
	match numpad_dir:
		1:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x - 1, sector_y))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x - 1, sector_y+1))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x - 1, sector_y+1))
		2:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x, sector_y + 1))
		3:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x + 1, sector_y))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x + 1, sector_y + 1))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x, sector_y + 1))
		4:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x - 1, sector_y))
		6:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x + 1, sector_y))
		7:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x - 1, sector_y))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x - 1, sector_y - 1))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x, sector_y - 1))
		8:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x, sector_y - 1))
		9:
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x + 1, sector_y))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x + 1, sector_y - 1))
			append_to_soldier_array(soldier_array, get_soldiers_from_subsector(sector_x, sector_y - 1))
			
	return soldier_array

func clear_all_soldier_arrays():
	var current_slice = []
	for x in range(SubSectors.size()):
		current_slice = SubSectors[x]
		for y in range(current_slice.size()):
			current_slice[y].clear()

func add_soldier_to_subsector(added_dude : Dude, new_loc_x : int = -5000, new_loc_y : int = -5000):
	var dude_x = added_dude.dude_x
	var dude_y = added_dude.dude_y
	if new_loc_x != -5000:
		dude_x = new_loc_x
		dude_y = new_loc_y

	var sector_x = int(dude_x / 200) - 1
	var sector_y = int(dude_y / 200) - 1
	
	if sector_x < 0:
		sector_x = 0
	elif sector_x >= SubSectors.size():
		sector_x = SubSectors.size() - 1
		
	if sector_y < 0:
		sector_y = 0
	elif sector_y >= SubSectors[sector_x].size():
		sector_y = SubSectors[sector_x].size() - 1
	
	var subsector : SubSector = SubSectors[sector_x][sector_y]
	subsector.sector_soldiers.push_front(added_dude)
	return subsector

func append_to_soldier_array(main_soldier_array, adding_array):
	if adding_array != null:
		main_soldier_array.append_array(adding_array)
	return main_soldier_array
	
func get_shots_from_subsector(sector_x, sector_y):
	if sector_x < 0 || sector_y < 0 || SubSectors.size() <= sector_x:
		return null
	var sub_sector_row = SubSectors[sector_x]
	if sub_sector_row.size() <= sector_y:
		return null
	return sub_sector_row[sector_y].sector_shots	

func get_shots_from_sector_and_close(sector_x, sector_y, numpad_dir):
	var shot_array : Array[Shot] = []
	var sub_sector_row = SubSectors[sector_x]
	shot_array.append_array(sub_sector_row[sector_y].sector_shots)
	match numpad_dir:
		1:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x - 1, sector_y))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x - 1, sector_y+1))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x - 1, sector_y+1))
		2:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x, sector_y + 1))
		3:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x + 1, sector_y))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x + 1, sector_y + 1))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x, sector_y + 1))
		4:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x - 1, sector_y))
		6:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x + 1, sector_y))
		7:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x - 1, sector_y))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x - 1, sector_y - 1))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x, sector_y - 1))
		8:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x, sector_y - 1))
		9:
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x + 1, sector_y))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x + 1, sector_y - 1))
			append_to_shot_array(shot_array, get_shots_from_subsector(sector_x, sector_y - 1))
			
	return shot_array
	
func append_to_shot_array(main_shot_array, adding_array):
	if adding_array != null:
		main_shot_array.append_array(adding_array)
	return main_shot_array
	
func add_shot_to_subsector(added_shot : Shot):
	var sector_x = int(added_shot.shot_from.x / 200) - 1
	var sector_y = int(added_shot.shot_from.y / 200) - 1
	var subsector : SubSector = SubSectors[sector_x][sector_y]
	subsector.sector_shots.push_front(added_shot)

func clear_all_shot_arrays():
	var current_slice = []
	for x in range(SubSectors.size()):
		current_slice = SubSectors[x]
		for y in range(current_slice.size()):
			current_slice[y].sector_shots.clear()

func get_subsector_loc(loc_x, loc_y, loc_size):
	var subsec_loc_x = int(loc_x) % 200
	var subsec_loc_y = int(loc_y) % 200
	
	if subsec_loc_y < loc_size:
		if subsec_loc_x < loc_size:
			return 7
		elif subsec_loc_x + loc_size > 200:
			return 9
		else:
			return 8
	elif subsec_loc_y + loc_size > 200:
		if subsec_loc_x < loc_size:
			return 1
		elif subsec_loc_x + loc_size > 200:
			return 3
		else:
			return 2
	elif subsec_loc_x < loc_size:
		return 4
	elif subsec_loc_x + loc_size > 200:
		return 6
	else:
		return 5
