extends CharacterBody3D

##########
# INIT
##########
#current speed
var speed = 3.0
var health = 2
#targets and current target 
var targets 
var destination 
#world
var space_state
#state
var running = false
var leaving = false
var atacking = false
#enemy spawns and instantly searches for the nearest target
func _ready():
	$healthBar.max = float(health)
	self.add_to_group("enemy")
	destination = position
	space_state = get_world_3d().direct_space_state
	getTarget()


#########
# Target
#########
#move towards center point of target
func getTargetCenter(target):
	var x = target.position.x+Globals.gridCenter
	var z = target.position.z+Globals.gridCenter
	return {'x':x, 'z':z}

#iterate through valid targets and move towards nearest 
func getTarget():
	#only target if not fleeing
	if running:
		return
	#select nearest farm, ignore other buildings
	var farms = get_tree().get_nodes_in_group("farms")
	targets = []
	for f in farms:
		if not f.dead:
			targets.append(f)
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


#############
# Process
############
#move towards target until it touches something, then attack if not fleeing
func _physics_process(delta):
	if atacking:
		return
	velocity.x = -(position.x - destination.x)
	velocity.z = -(position.z - destination.z)
	velocity = velocity.normalized()
	#if not fleeing go to nearest target
	if !running:
		var nextMove = position+(velocity)
		#get_parent().line(position, nextMove) #DEBUG
		var query = PhysicsRayQueryParameters3D.create(position, nextMove)
		var result = space_state.intersect_ray(query)
		#touched building, destroy it
		if result:
			get_parent().destroy(result.collider)
			return
	#if fleeing start leaving when out of the player's area
	elif not leaving:
		if position.x < 0 or position.y < 0:
			$AnimationPlayer.play("die")
			leaving = true
	velocity *= speed
	move_and_slide()
	
func hit():
	if health > 0:
		health -= 1
		$healthBar.move(health)
		if health == 0:
			defeat()
			return true
		else:
			$AnimationPlayer.play("hit")
	return false
	
#defeated enemy, switch modes and run away
func defeat():
	if !running:
		remove_from_group('enemy')
		running = true
		atacking = false
		speed *= 1.5
		destination = Vector3(0,position.y,0)
		$AnimationPlayer.play("defeat")
		$CollisionShape3D.disabled = true
	
func animationFinished(anim):
	#leave tree after dying
	if anim == 'die':
		get_parent().destroy(self)



