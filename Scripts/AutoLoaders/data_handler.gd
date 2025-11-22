extends Node

var Factions : Array[Faction] = []
var Cur_Faction_ID = 1

var Soldiers : Array[Dude] = []
var cur_soldier_ID = 1

var Dead_Soldiers : Array[Dude] = []

var Squads : Array[Squad] = []
var cur_squad_ID = 1

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
