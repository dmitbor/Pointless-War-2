class_name Item
extends Node

var item_name
# How many hands are needed to use this item?
var hands_usage
# How much does this item weight
var weight
# How many people are needed to use this item
var users_req
# Texture for the Item
var item_img
# Does the item change color with Faction uniform?
var remapable = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
