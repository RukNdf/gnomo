extends Node3D

#farm size
const size = Vector2(1,1)
const group = "tower"
#farm starts not dead and in the valid farms group
var dead
func _ready():
	dead = false
	add_to_group(group)

#get smoke position to place in front of the farm when it dies
func getSmokePos():
	print(Globals)
	print(Globals.gridCenter)
	var x = position.x + Globals.gridCenter
	var z = position.z + Globals.gridCenter
	return {'x' = x, 'z' = z}

#ignore collision if it's already dying
var dying = false
func die():
	dying = true
	#start animations, remove from target group, and remove collision halfway into the animation
	remove_from_group(group)
	get_parent().clearPlace(position, size)
	get_parent().spawnSmoke(getSmokePos())
	$AnimationPlayer.play("die")
	await get_tree().create_timer(Globals.colDelay).timeout
	removeCol()
	return true

#remove collision box
func removeCol():
	$StaticBody3D/CollisionShape3D.disabled = true

#create a ghost to show placement, ghost is not a real farm and doesn't have collision
func createGhost():
	remove_from_group(group)
	scale = Vector3(1.01, 1.01, 1.01)
	removeCol()
	$Mesh.material_override.albedo_color.a = Globals.ghostOpacity
#update color to show collision	
func updateGhost(canPlace):
	if canPlace:
		$Mesh.material_override.albedo_color = Color(1, 1, 1, Globals.ghostOpacity)
	else:
		$Mesh.material_override.albedo_color = Globals.blockedColor
	


#move towards center point of target
func getTargetCenter(target):
	var x = target.position.x+Globals.gridCenter
	var z = target.position.z+Globals.gridCenter
	return {'x':x, 'z':z}

#iterate through valid targets and move towards nearest 
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
