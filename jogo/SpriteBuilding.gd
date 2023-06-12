extends Building
class_name SpriteBuilding

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
	print(Globals.ghostOpacity)
	$Post.modulate.a = Globals.ghostOpacity
#update color to show collision	
func updateGhost(canPlace):
	return
	if canPlace:
		$Post.modulate = Color(1, 1, 1, Globals.ghostOpacity)
	else:
		$Post.modulate = Globals.blockedColor
		
