extends TextureRect


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
			
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(3, 3))
			# Body
			draw_texture(GraphicLoader.body_txtr, Vector2(3, 10), soldier.dude_squad.Squad_Faction.faction_color)
			# Body Armor/Trim
			var body_armor_info = soldier.get_armor_txtr(0)
			draw_texture(body_armor_info[0], Vector2(3, 10))
			# Head
			draw_texture(GraphicLoader.head_txtr, Vector2(5, 0))
			# Head Armor
			var head_armor_info = soldier.get_armor_txtr(1)
			if head_armor_info[1]:
				draw_texture(head_armor_info[0], Vector2(5, 0), soldier.dude_squad.Squad_Faction.faction_color)
			else:
				draw_texture(head_armor_info[0], Vector2(5, 0))
				
			var held_weapon = soldier.dude_weapon
			draw_texture(held_weapon.item_img, Vector2(5, 30))
