class_name Objective
extends Node

# Could either be a specific enemy Soldier, Squad, or a Capture Point
var Targets = []
# Has this Objective have been achieved (and can we have a new one be assigned?)
var Complete = true
# Objective Type
var Objective_Type : String
var Objective_SubType : String
# How long should squad wait until objective is considered complete?
var Objective_Time = 0
var Obj_Time_Counted = 0

func set_type(new_type):
	Objective_Type = new_type
	Complete = false
	
func set_subtype(new_type):
	Objective_SubType = new_type
	
func add_target(given_target):
	Targets.append(given_target)

func complete_objective():
	Complete = true
	
func set_objective_time(time):
	Objective_Time = time
	
# Sometimes returns nothing, because everyone in squad is dead, yet squad is still a target
func get_point_target_location():
	if Targets[0] is Squad:
		return Targets[0].get_leader_or_next_soldier()
	elif Targets[0] is ControlPoint || Targets[0] is Dude:
		return Targets[0].get_location()
	
func count_time():
	Obj_Time_Counted = Obj_Time_Counted + 1
	if Obj_Time_Counted >= Objective_Time:
		if Objective_Type == "Combat":
			if Objective_SubType.contains("SearchCombat"):
				if Targets.size() == 0:
					complete_objective()
					return
				set_subtype("MidCombat")
				print("Entering Combat with " + str(Targets.size()) + " targets")
		else:
			complete_objective()
