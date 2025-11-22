class_name ControlPoint
extends Node

# Location of control point on the map
var con_point_x = 0
var con_point_y = 0

# Power Level of Control Point: Goes from 1 to 3
var con_point_level = 1

var con_point_ID

var con_faction: Faction

var con_control = 0
var con_max_control = 100

func _init(point_id : int) -> void:
	con_point_ID = point_id

func set_location(new_x, new_y):
	con_point_x = new_x
	con_point_y = new_y

func set_point_level(level: int):
	con_point_level = level
	con_max_control = con_point_level * 100

func get_location():
	return Vector2(con_point_x,con_point_y)

func get_draw_vector_loc():
	return Vector2(float(con_point_x - 10 * con_point_level), float(con_point_y - 10 * con_point_level))

func fully_captured(my_faction: Faction):
	if con_faction:
		if con_control == con_max_control && con_faction.faction_id == my_faction.faction_id:
			return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
