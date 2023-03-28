extends Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	worldspace = get_world_3d().direct_space_state
	cursor = get_node('../Cursor')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
var mousePos
var worldspace
var cursor
func _input(event):
	if event is InputEventMouse:
		var from = project_ray_origin(event.position)
		var to = project_position(event.position, 1000)
		var query = PhysicsRayQueryParameters3D.create(from, to, 2)
		mousePos = worldspace.intersect_ray(query)
		cursor.update(mousePos)

func getMousePos():
	return mousePos
	
