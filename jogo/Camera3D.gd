extends Camera3D

#	Used to get cursor position relative to the ground within the isometric FOV
#--------------------------------------------------------------------------------

#ground gets loaded along with camera so it doesn't need to update the 3D space afterwards
var worldspace
func _ready():
	worldspace = get_world_3d().direct_space_state
	
var mode = Globals.BUILDMODE
var mousePos
var groundedMousePos
var cursor
func _input(event):
	#mouse moved, raycast, get ground coordinates, and update
	if event is InputEventMouse:
		mousePos = event.position
		if mode == Globals.BUILDMODE:
			var from = project_ray_origin(event.position)
			var to = project_position(event.position, 1000)
			var query = PhysicsRayQueryParameters3D.create(from, to, 2)
			groundedMousePos = worldspace.intersect_ray(query)
			get_parent().updateMousePos(groundedMousePos)
	
func selectEnemy():
	var from = project_ray_origin(mousePos)
	var to = project_position(mousePos, 1000)
	var query = PhysicsRayQueryParameters3D.create(from, to, 4)
	return worldspace.intersect_ray(query)

func getMousePos():
	return mousePos
	
