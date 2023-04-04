extends Node3D

############
# Init
############
const size = Vector2(1,1)
const group = "tower"
var dead = false
#farm starts not dead and in the valid towers group
func _ready():
	add_to_group(group)


###########
# Graphics
###########
#get smoke position to place in front of the tower when it dies
func getSmokePos():
	print(Globals)
	print(Globals.gridCenter)
	var x = position.x + Globals.gridCenter
	var z = position.z + Globals.gridCenter
	return {'x' = x, 'z' = z}


########
# Die
#######
#start dying
func die():
	dead = true
	#start animations, remove from target group, and remove collision halfway into the animation
	remove_from_group(group)
	get_parent().clearPlace(position, size)
	get_parent().spawnSmoke(getSmokePos())
	$AnimationPlayer.play("die")
	await get_tree().create_timer(Globals.colDelay).timeout
	$StaticBody3D/CollisionShape3D.disabled = true
	return true


#########
# Ghost
########
#create a ghost to show placement, ghost is not a real tower and doesn't have collision
func createGhost():
	remove_from_group(group)
	scale = Vector3(1.01, 1.01, 1.01)
	$StaticBody3D/CollisionShape3D.disabled = true
	$Mesh.material_override.albedo_color.a = Globals.ghostOpacity
#update color to show collision	
func updateGhost(canPlace):
	if canPlace:
		$Mesh.material_override.albedo_color = Color(1, 1, 1, Globals.ghostOpacity)
	else:
		$Mesh.material_override.albedo_color = Globals.blockedColor


##########
# Attack
#########
#get center point
func getTargetCenter(target):
	var x = target.position.x+Globals.gridCenter
	var z = target.position.z+Globals.gridCenter
	return {'x':x, 'z':z}
#iterate through valid targets and target nearest 
func kill():
	var targets = get_tree().get_nodes_in_group("enemy")
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
	return targets[target]
