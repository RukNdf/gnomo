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
var buildingType

#building starts in group 
func ready():
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
		z = (Globals.gridCenter*(size.y-2))
	return {'x' = x, 'z' = z}


########
# Die
#######
#take damage, by default has 1 health and takes 1 damage
func damage(damage = 1, smoke = true):
	die(smoke) 
#start dying
func die(smoke = true):
	updateCost(true)
	dead = true
	#remove from target group, start animations, and remove collision halfway into the animation
	get_parent().clearPlace(position, size, group)
	remove_from_group(group)
	if smoke:
		get_parent().spawnSmoke(getSmokePos())
	$AnimationPlayer.play("die")
	await get_tree().create_timer(Globals.colDelay).timeout
	$StaticBody3D/CollisionShape3D.disabled = true
	hide()
	queue_free()
#leave scene 
func leave(anim):
	if anim == 'die':
		get_parent().remove(self)

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


#########
# Ghost
########
# cost
func getCost():
	return Globals.buildingPrices[buildingType]

func updateCost(reverse = false):
	var increase = Globals.buildingPriceIncrease[buildingType]
	if reverse:
		Globals.buildingPrices[buildingType] -= increase
	else:
		Globals.buildingPrices[buildingType] += increase
