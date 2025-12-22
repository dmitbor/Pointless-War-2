extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass

func _draw() -> void:
	if DataHandler.Selected_Dude:
		var soldier = DataHandler.Selected_Dude

		# Personal
		var soldier_health = soldier.dude_body_health
		$Tabs/Personal/VBoxContainer/HBoxContainer/MarginContainer2/GridContainer/PanelContainer/headHealthTxt.text = str(soldier_health[0])
		$Tabs/Personal/VBoxContainer/HBoxContainer/MarginContainer2/GridContainer/PanelContainer2/rArmHealthTxt.text = str(soldier_health[2])
		$Tabs/Personal/VBoxContainer/HBoxContainer/MarginContainer2/GridContainer/PanelContainer3/lArmHealthTxt.text = str(soldier_health[3])
		$Tabs/Personal/VBoxContainer/HBoxContainer/MarginContainer2/GridContainer/PanelContainer4/bodyHealthTxt.text = str(soldier_health[1])
		$Tabs/Personal/VBoxContainer/HBoxContainer/MarginContainer2/GridContainer/PanelContainer6/rLegHealthTxt.text = str(soldier_health[4])
		$Tabs/Personal/VBoxContainer/HBoxContainer/MarginContainer2/GridContainer/PanelContainer7/lLegHealthTxt.text = str(soldier_health[5])
		$Tabs/Personal/VBoxContainer/MarginContainer/GridContainer/dudeIDLbl.text = str(soldier.dude_ID)
		$Tabs/Personal/VBoxContainer/MarginContainer/GridContainer/squadIDLbl.text = str(soldier.dude_squad.Squad_ID)
		$Tabs/Personal/VBoxContainer/MarginContainer/GridContainer/energyLbl.text = str(soldier.dude_stamina)
		
		# Squad
		var dude_squad : Squad = soldier.dude_squad
		if dude_squad.Leader:
			$Tabs/Squad/PanelContainer/MarginContainer2/LeaderInfoLabel.text = str(dude_squad.Leader.dude_ID) + " " + dude_squad.Leader.dude_name
		
		var live_list = $Tabs/Squad/MarginContainer/LiveList
		var dead_list = $Tabs/Squad/MarginContainer2/DeadList
		var obj_list = $Tabs/Squad/MarginContainer3/ObjList
		
		live_list.clear()
		dead_list.clear()
		for member : Dude in dude_squad.Members:
			if member.is_alive():
				live_list.add_item(str(member.dude_ID) + " " + str(member.dude_name))
			else:
				dead_list.add_item(str(member.dude_ID) + " " + str(member.dude_name))
		
		obj_list.clear()
		for objective : Objective in dude_squad.Squad_Objectives:
			obj_list.add_item(str(objective.Objective_Type) + "[" + str(objective.Objective_SubType) + "]")
	
		# Items
		var dude_armor_total = soldier.get_armor_total()
		var armor_head_string : String = soldier.get_matching_armor_type(1).item_name + " (" + str(dude_armor_total[0]) + "H)"
		var armor_body_string : String = soldier.get_matching_armor_type(0).item_name + " ("
		for index in dude_armor_total.size():
			match index:
				# Body
				1: 
					armor_body_string +=  str(dude_armor_total[1]) + "B "
				# Arm (Assume both arms are matching for now)
				2:
					armor_body_string +=  str(dude_armor_total[2]) + "A "
				# Leg (Same as above)
				4:
					armor_body_string +=  str(dude_armor_total[4]) + "L)"
					
		$Tabs/Items/MarginContainer/ItemsHeld/headItemBtn.text = armor_head_string
		$Tabs/Items/MarginContainer/ItemsHeld/bodyItemBtn.text = armor_body_string
		
		# This will actually be item selected by the player to give more info on, rather than just held weapon.
		var held_weapon : Gun = soldier.dude_weapon
		
		$Tabs/Items/MarginContainer/ItemsHeld/heldItemBtn.text = held_weapon.item_name + " (" +  str(held_weapon.gun_load) + ")"

		$Tabs/Items/MarginContainer3/HBoxContainer/itemInfoGrid/ItemNameLbl.text = held_weapon.item_name
		$Tabs/Items/MarginContainer3/HBoxContainer/itemInfoGrid/ItemRngLbl.text = str(held_weapon.gun_range)
		$Tabs/Items/MarginContainer3/HBoxContainer/itemInfoGrid/ItemDmgLbl.text = str(held_weapon.weapon_damage)
		$Tabs/Items/MarginContainer3/HBoxContainer/itemInfoGrid/ItemUseLbl.text = str(held_weapon.gun_load)
		$Tabs/Items/MarginContainer3/HBoxContainer/TextureRect.texture = held_weapon.item_img
