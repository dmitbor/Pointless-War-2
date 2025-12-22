class_name SubSector

var sector_soldiers : Array[Dude] = []
var sector_shots : Array[Shot] = []
var sector_x : int
var sector_y : int

func _init(x, y) -> void:
	sector_x = x
	sector_y = y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
