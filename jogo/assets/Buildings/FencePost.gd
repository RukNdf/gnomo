extends SpriteBuilding

############
# Init
############
var gridLocation
func init(location = null):
	size = Vector2i(1,1)
	if location != null:
		group = "fence"
	else:
		group = ''
	gridLocation = location
	dead = false
	cost = 5
	$healthBar.setHealth(2)
	
	
func updateFence(fences):
	if hasNeighbor(fences, 1, 0):
		print('has x')
		$DR.visible = true
		$DRCol/StaticBody3D/CollisionShape3D.disabled = false
	else:
		$DR.visible = false
		$DRCol/StaticBody3D/CollisionShape3D.disabled = true
	if hasNeighbor(fences, 0, 1):
		print('has y')
		$DL.visible = true
		$DLCol/StaticBody3D/CollisionShape3D.disabled = false
	else:
		print('noy')
		$DL.visible = false
		$DLCol/StaticBody3D/CollisionShape3D.disabled = true
	
func hasNeighbor(fences, x,y):
	x += gridLocation.x
	y += gridLocation.y
	if len(fences) < x:
		return false
	if len(fences[0]) < y:
		return false
	return fences[x][y]

func hit():
	$healthBar.damage(1)
	if($healthBar.realHealth <= 0):
		die()

#overload die
func die(smoke = true):
	#hit()
	return
	dead = true
	#remove from target group, start animations, and remove collision halfway into the animation
	remove_from_group(group)
	get_parent().clearPlace(position, size)
	if smoke:
		get_parent().spawnSmoke(getSmokePos())
	$AnimationPlayer.play("die")
	await get_tree().create_timer(Globals.colDelay).timeout
	$DRCol/StaticBody3D/CollisionShape3D.disabled = true
	$DLCol/StaticBody3D/CollisionShape3D.disabled = true
	$StaticBody3D/CollisionShape3D.disabled = true
	$DR.visible = false
	$DL.visible = false
	
