extends Node3D


################
# Init
################
#resource indexes
const mush = 0
#resource list
var resources = [120]
#num of required buildings (e.g. farm)
var numBuilding = 0
#current selected building
var selected = 'farm'

#initialize game field
func _ready():	
	mute()
	randomize()
	#import draw3D for 3D lines
	draw3D = Draw3D.new()
	add_child(draw3D)
	initGridSpace()
	spawnGrass()
	makeGhost()
	updateMushrooms(0)
#aaaaaaaaaaa
func mute():
	var master_sound = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_sound, true)

#initialize gridSpace to simplify placement, by default all cells are empty
var gridSpace
func initGridSpace():
	gridSpace = []
	for x in range(Globals.maxX+1):
		gridSpace.append([])
		for y in range(Globals.maxY+1):
			gridSpace[x].append(false)

#set farm as default building 
func makeGhost():
	ghost = farm.instantiate()
	add_child(ghost)
	ghost.createGhost()


##############
# Graphics
##############
#Spawn random grass patches on the player's field
func spawnGrass():
	var grass = preload("res://jogo/assets/Grass.tscn")
	var min = Vector2(0, 0)
	var gSize = $ground.size * $ground.scale
	var max = Vector2(gSize.x, gSize.z)
	for i in range(10+(randi()%100)):
		var g = grass.instantiate()
		g.position = Vector3(randf_range(min.x, max.x), 0, randf_range(min.y, max.y))
		add_child(g)

#spawn smoke after building dies
var smoke = preload("res://jogo/assets/Smoke.tscn")
func spawnSmoke(pos):
	var s = smoke.instantiate()
	s.position.x = pos.x
	s.position.y = 1.5
	s.position.z = pos.z + Globals.cameraOffset.z
	add_child(s)


#############
# Placement
#############
var canPlace = false
#buildings
var farm = preload("res://jogo/assets/Farm.tscn")
var tower = preload("res://jogo/assets/Tower.tscn")

#try to spawn a building
func spawn(type):
	lastSpawnTime = Time.get_ticks_msec()
	var pos = $Cursor.getCenter()
	if len(pos) == 0:
		return false
	var f
	if type == 'farm':
		f = farm.instantiate()
		numBuilding += 1
	else:
		f = tower.instantiate()
	f.position.x = pos.x + Globals.cameraOffset.x
	f.position.z = pos.z + Globals.cameraOffset.z
	f.position.y = 0.5
	add_child(f)
	return true

#test if there's a building intersecting within the grid
func testPlacement(pos, size):
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			if gridSpace[x][y]:
				canPlace = false
				return
	canPlace = true

#place building within the grid
func place(pos, size):
	canPlace = false
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			gridSpace[x][y] = true

#clear space on grid when destroyed
func clearPlace(position, size):
	var pos = Vector2()
	pos.x = position.x/Globals.gridSize
	pos.y = position.z/Globals.gridSize
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			gridSpace[x][y] = false


#########
# Ghost
#########
var ghost
var ghostState = canPlace
#moves ghost and update placement
func moveGhost(): 
	var pos = $Cursor.getCenter()
	testPlacement($Cursor.gridPos, ghost.size)
	if len(pos) == 0:
		return
	ghost.position.x = pos.x + Globals.cameraOffset.x
	ghost.position.z = pos.z + Globals.cameraOffset.z
	ghost.position.y = 0.5
	#only update color if it changed
	if ghostState != canPlace:
		ghost.updateGhost(canPlace)
		ghostState = canPlace


###############AAAAAAAAAAAAAAAA
#DEBUG
var turnP = false
var farmCost = -10
func _process(delta):
	#if Input.is_key_pressed(KEY_L):
		#kill()
	if Input.is_key_pressed(KEY_O):
		if canPlace:
			if tryPlace(farmCost):
				spawn('farm')
				place($Cursor.gridPos, ghost.size)
			else:
				print('b')
	if Input.is_key_pressed(KEY_I):
		if canPlace:
			if tryPlace(farmCost):
				spawn('tower')
				place($Cursor.gridPos, ghost.size)
			else:
				print('b')
	if Input.is_key_pressed(KEY_A):
		var scale = $Arrow.scale.x
		$Arrow.scale = Vector3(-scale, -scale, -scale)
	if Input.is_key_pressed(KEY_Q):
		pass#test()
	if Input.is_key_pressed(KEY_S):
		for s in get_tree().get_nodes_in_group('smoke'):
			remove_child(s)
	if Input.is_key_pressed(KEY_T):
		if turnP:
			return
		turnP = true
		nextTurn()
	else:
		turnP = false
	if Input.is_key_pressed(KEY_K):
		for e in get_tree().get_nodes_in_group('enemy'):
			remove_child(e)
	pass	


func defend():
	print('start')
	$AtkTimer.set_wait_time(Globals.atkDelay)
	$AtkTimer.start()
	
func towerAtk():
	for tower in get_tree().get_nodes_in_group("tower"):
		if tower.dead:
			continue
		var e = tower.kill()
		if e != null:
			killUnit(e)
	if(!atkTurn):
		$AtkTimer.stop()
		
func killUnit(e):
	e.defeat()

var lastSpawnTime = 0
func tryPlace(cost):
	var t = Time.get_ticks_msec()
	if t < lastSpawnTime+Globals.placementDelay:
		return false
	return updateMushrooms(cost)
	
	
	

var draw3D
func line(p1, p2):
	draw3D.clear()
	draw3D.draw_line([p1,p2])
	pass

var destroyTime = 0.5
func destroy(col):	
	var obj = col.get_parent()
	if(!obj.has_method('die')):
		return
	if obj.dead:
		return
	obj.die()
	if obj.group == 'farms':
		print('a')
		numBuilding -= 1	
	if numBuilding == 0:
		gameOver()
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		e.getTarget()
	
func remove(obj):
	remove_child(obj)

func gameOver():
	$menu/colBox.position.y = 1000
	$Overlay/AnimationPlayer.play("GG")
	$Cursor.visible = false
	ghost.visible = false	

var turn = 1
var atkTurn = false 
func nextTurn():
	updateResources()
	turn += 1
	if turn > 9:
		$Overlay/Turn.text = 'Turn ' + str(turn) + ' '
	else: 
		$Overlay/Turn.text = 'Turn   ' + str(turn) + ' '
	#atkTurn = !atkTurn
	if(turn >= 3):
		if(!atkTurn):
			atkTurn = true
			defend()
			$Bsong.stop()
			$Asong.play()
		spawnEnemy(turn)
		#spawnEnemy(1)


var enemy = preload("res://jogo/assets/Enemy.tscn")
func spawnEnemy(num):
	for i in range(num):
		var e = enemy.instantiate()
		e.position = Vector3(0,0,0)
		add_child(e)

func select(type):
	selected = type
	var pos = ghost.position
	remove_child(ghost)
	if type == 'mush':
		ghost = farm.instantiate()
	if type == 'tower':
		ghost = tower.instantiate()
	ghost.createGhost()
	ghost.position = pos
	add_child(ghost)
		
	
func updateMousePos(pos):
	$Cursor.update(pos)
	#$menu.$shape.
	moveGhost()
	
func _input(event):
	if event is InputEventMouse:
		$menu.testMenuCol(event.position)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if canPlace:
				if tryPlace(farmCost):
					spawn(selected)
					place($Cursor.gridPos, ghost.size)
	
var farmProduces = 5
func updateResources():
	var m = 0
	for f in get_tree().get_nodes_in_group("farms"):
		m += farmProduces
	updateMushrooms(m)
	
func updateMushrooms(num):
	if resources[mush] + num < 0:
		return false
	resources[mush] += num
	$Overlay/resources.updateMush(resources[mush])
	return true
	
