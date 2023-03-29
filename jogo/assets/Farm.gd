extends CSGBox3D


# Called when the node enters the scene tree for the first time.
var dead
func _ready():
	dead = false
	add_to_group("farms")
	print("farm")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func getSmokePos():
	var x = position.x + Globals.gridCenter
	var z = position.z + Globals.gridCenter
	return {'x' = x, 'z' = z}

func die():
	remove_from_group("farms")
	use_collision = false
	$AnimationPlayer.play("die")
	
func leave(anim):
	get_parent().remove(self)
