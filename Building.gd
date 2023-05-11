extends Node3D
class_name Building

############
# Init
############
var size
var group
var cost
var center
var dead = false
var smokePos

#building starts in group 
func _ready():
	initSmokePos()
	add_to_group(group)

#get root building
func getNode():
	return self

###########
# Graphics
###########
#smoke position to place in front of the farm when it diest
func initSmokePos():
	var x = position.x + (Globals.gridCenter*(size.x%2)) + ((Globals.gridSize*(size.x/2))/2)
	var z = position.z + (Globals.gridCenter*(size.y%2)) + ((Globals.gridSize*(size.y/2))/2)
	smokePos = {'x' = x, 'z' = z}

func getSmokePos():
	return smokePos

#center position for placement
func calcDisplacement():
	var x
	var z
	if size.x == 1:
		x = 0
	else:
		x = (Globals.gridCenter*(size.x-1))
	if size.y == 1:
		z = 0
	else:
		z = (Globals.gridCenter*(size.y-1))
	return {'x' = x, 'z' = z}


########
# Die
#######
#start dying
func die(smoke = true):
	dead = true
	#remove from target group, start animations, and remove collision halfway into the animation
	remove_from_group(group)
	get_parent().clearPlace(position, size)
	if smoke:
		get_parent().spawnSmoke(getSmokePos())
	$AnimationPlayer.play("die")
	await get_tree().create_timer(Globals.colDelay).timeout
	$StaticBody3D/CollisionShape3D.disabled = true

#########
# Ghost
########
#create a ghost to show placement, ghost is not a real building and doesn't have collision
func createGhost():
	dead = true
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
		
