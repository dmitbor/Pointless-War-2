class_name Skill
extends Node

var skill_name = ""
var skill_value = 0
# Could be one of the following:
# 0 - General Skill
# 1 - Specific Item Skill
var skill_type = 0
var skill_focus = ""

func set_skill_info(skl_name = "",skl_val = 0, skl_type = 0, skl_focus = ""):
	skill_name = skl_name
	skill_value = skl_val
	skill_type = skl_type
	skill_focus = skl_focus
