class_name Faction
extends Node

var faction_color : Color
var faction_name
var faction_id = 0


func _init(new_fac_id, new_fac_name, new_fac_color):
	faction_id = new_fac_id
	faction_name = new_fac_name
	faction_color = new_fac_color
