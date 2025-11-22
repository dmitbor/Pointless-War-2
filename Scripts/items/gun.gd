class_name Gun
extends Weapon

var gun_range
var gun_load
var gun_acc_mod
var gun_refire_rate
var gun_fire_rate
var gun_reload_time

func _init(gun_name, gun_num_hands, gun_weight, gun_damage, gun_given_range, gun_given_load, gun_given_reload_time, gun_given_visual, gun_given_refire_rate, gun_given_fire_rate = 1, given_users = 1, given_acc_mod = 0):
	item_name = gun_name
	hands_usage = gun_num_hands
	weight = gun_weight
	gun_reload_time = gun_given_reload_time
	gun_fire_rate = gun_given_fire_rate
	gun_refire_rate = gun_given_refire_rate
	users_req = given_users
	weapon_damage = gun_damage
	gun_range = gun_given_range
	gun_load = gun_given_load
	gun_acc_mod = given_acc_mod
	item_img = gun_given_visual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
