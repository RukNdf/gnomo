extends CharacterBody3D

const SPEED = 3.0

var targets 
var destination 

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("enemy")
	destination = position
	space_state = get_world_3d().direct_space_state
	getTarget()

var minDist = 40
var atacking = false
var space_state
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if atacking:
		return
	velocity.x = -(position.x - destination.x)
	velocity.z = -(position.z - destination.z)
	velocity = velocity.normalized()
	var nextMove = position+(velocity)
	get_parent().line(position, nextMove)
	#get_parent().updateLine(position, nextMove)
	var query = PhysicsRayQueryParameters3D.create(position, nextMove)
	var result = space_state.intersect_ray(query)
	if result:
		#print(result)
		#get_parent().placeDot(result.position, false)
		get_parent().destroy(result.collider)
	else:
		velocity *= SPEED
		move_and_slide()

func getTargetCenter(target):
	var x = target.position.x+Globals.gridCenter
	var z = target.position.z+Globals.gridCenter
	return {'x':x, 'z':z}

func getTarget():
	targets = get_tree().get_nodes_in_group("farms")
	print(targets)
	var tNum = len(targets)
	if tNum == 0:
		return
	var target = 0
	var center = getTargetCenter(targets[0])
	var min = ((position.x - center.x)**2) + ((position.z - center.z)**2)
	for i in range(1, tNum):
		center = getTargetCenter(targets[i])
		var d = ((position.x - center.x)**2) + ((position.z - center.z)**2)
		if d < min:
			min = d
			target = i
	destination = targets[target].position
