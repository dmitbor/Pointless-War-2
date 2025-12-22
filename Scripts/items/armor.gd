class_name Armor
extends Item

# Armor Types are usually:
# 0 - Body Armor
# 1 - Hat/Helmet
var armor_type = 0
# Flat Armor Reduction of the Armor
# Head, Body, Right Arm, Left Arm, Right Leg, Left Leg
var armor_values = [0, 0, 0, 0, 0, 0]

func _init(armor_name, armor_weight, armor_given_type, head_armor, body_armor, rarm_armor, larm_armor, rleg_armor, lleg_armor, armor_visual, remap_visual = false):
	item_name = armor_name
	weight = armor_weight
	armor_type = armor_given_type
	armor_values = [head_armor, body_armor, rarm_armor, larm_armor, rleg_armor, lleg_armor]
	item_img = armor_visual
	remapable = remap_visual
