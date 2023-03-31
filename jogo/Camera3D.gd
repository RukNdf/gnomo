extends Camera3D

#Used to get cursor position relative to the ground within the isometric FOV

var worldspace
func _ready():
	#ground gets loaded along with camera so it doesn't need to update the 3D space afterwards
	worldspace = get_world_3d().direct_space_state
	
var mousePos
var cursor
func _input(event):
	#mouse moved, raycast, get ground coordinates, and update
	if event is InputEventMouse:
		var from = project_ray_origin(event.position)
		var to = project_position(event.position, 1000)
		var query = PhysicsRayQueryParameters3D.create(from, to, 2)
		mousePos = worldspace.intersect_ray(query)
		get_parent().updateMousePos(mousePos)

func getMousePos():
	return mousePos
	
