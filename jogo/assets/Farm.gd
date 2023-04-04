extends Node3D


############
# Init
############
const size = Vector2(1,1)
const group = "farms"
var dead = false
#farm starts not dead and in the valid farms group
func _ready():
	add_to_group(group)


###########
# Graphics
###########
#get smoke position to place in front of the farm when it dies
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
	#remove from target group, start animations, and remove collision halfway into the animation
	remove_from_group(group)
	get_parent().clearPlace(position, size)
	get_parent().spawnSmoke(getSmokePos())
	$AnimationPlayer.play("die")
	await get_tree().create_timer(Globals.colDelay).timeout
	$StaticBody3D/CollisionShape3D.disabled = true


#########
# Ghost
########
#create a ghost to show placement, ghost is not a real farm and doesn't have collision
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
	
