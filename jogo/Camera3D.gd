extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
var mousePos
func _input(event):
	if event is InputEventMouse:
		mousePos = event.position

func getMousePos():
	var worldspace = get_world_3d().direct_space_state
	var from = project_ray_origin(mousePos)
	var to = project_position(mousePos, 1000)
	var query = PhysicsRayQueryParameters3D.create(from, to, 2)
	return worldspace.intersect_ray(query)
	
