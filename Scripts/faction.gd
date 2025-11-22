class_name Faction
extends Node

var faction_color : Color
var faction_name
var faction_id = 0


func _init(new_fac_id, new_fac_name, new_fac_color):
	faction_id = new_fac_id
	faction_name = new_fac_name
	faction_color = new_fac_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
