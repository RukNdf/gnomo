extends Node3D


#MUTE ALL GAME AUDIO
const MUTE = false

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
var selected = 'mush'
#turn configuration
var turns

#initialize game field
func _ready():	
	if(MUTE):
		mute()
	randomize()
	#import draw3D for 3D lines
	#draw3D = Draw3D.new()
	#add_child(draw3D)
	initGridSpace()
	initTurns()
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
	var grass = preload("res://jogo/assets/map/Grass.tscn")
	var min = Vector2(0, 0)
	var gSize = $ground.size * $ground.scale
	var max = Vector2(gSize.x, gSize.z)
	for i in range(10+(randi()%100)):
		var g = grass.instantiate()
		g.position = Vector3(randf_range(min.x, max.x), 0, randf_range(min.y, max.y))
		add_child(g)

#spawn smoke after building dies
var smoke = preload("res://jogo/assets/Buildings/Smoke.tscn")
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
var farm = preload("res://jogo/assets/Buildings/Farm.tscn")
var tower = preload("res://jogo/assets/Buildings/Tower.tscn")

#try to spawn a building
func spawn(type):
	lastSpawnTime = Time.get_ticks_msec()
	var pos = $Cursor.getCenter()
	if len(pos) == 0:
		return false
	var f
	$SFX/Build.play()
	if type == 'mush':
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
		passTurn()
	else:
		turnP = false
	if Input.is_key_pressed(KEY_K):
		for e in get_tree().get_nodes_in_group('enemy'):
			remove_child(e)
	pass	


func defend():
	$AtkTimer.set_wait_time(Globals.atkDelay)
	$AtkTimer.start()
	
func towerAtk():
	for tower in get_tree().get_nodes_in_group("tower"):
		if tower.dead:
			continue
		var e = tower.kill()
		if e != null:
			atkUnit(e)
	if(!atkTurn):
		$AtkTimer.stop()
		
func atkUnit(e):
	if MUTE:
		e.hit()
		return
	#play sounds if not muted
	$SFX/EnemyHit.play()
	#if enemy died on hit 
	if e.hit():
		$SFX/EnemyDeath.play()

var lastSpawnTime = 0
func tryPlace(cost):
	var t = Time.get_ticks_msec()
	if t < lastSpawnTime+Globals.placementDelay:
		return false
	return updateMushrooms(cost)
	
	
	

var draw3D
func line(p1, p2):
	return
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

func initTurns():
	turns = []
	var file = FileAccess.open("res://jogo/Turns.txt", FileAccess.READ).get_as_text().split('\n')
	var turn = 1
	for s in file.slice(0,-1):
		var t = s.split(' ', true, 1)
		var cTurn = int(t[0])
		var e = t[-1]
		while turn != cTurn:
			turn+= 1 
			turns.append([0,0,0,0,0])
		var eInt = []
		for v in e.split(' '):
			eInt.append(int(v))
		turns.append(eInt)		
		turn+= 1 
	nextTurn = turns[1]

var turnCount = 1
var atkTurn = false 
var nextTurn
func passTurn():
	#buildings create resources
	updateResources()
	#update turn
	turnCount += 1
	var turn = nextTurn
	if turnCount < len(turns):
		nextTurn = turns[turnCount]
	else:
		nextTurn = turns[0]
	if turnCount > 9:
		$Overlay/Turn.text = 'Turn ' + str(turnCount) + ' '
	else: 
		$Overlay/Turn.text = 'Turn   ' + str(turnCount) + ' '
	#enemy attacking
	if sum(turn) > 0:
		if !atkTurn:
			atkTurn = true
			defend()
			$Bsong.stop()
			$Asong.play()
		announceEnemy(turn, nextTurn)
		spawnEnemy(turn)
	else:
		if atkTurn:
			atkTurn = true
			defend()
			$Asong.stop()
			$Bsong.play()
		announceEnemy(turn, nextTurn)
		
func announceEnemy(current, next):
	$Spawners/EnemySpawnerUL.visible = current[0] > 0
	$Spawners/EnemySpawnerLL.visible = current[1] > 0
	$Spawners/EnemySpawnerUR.visible = current[2] > 0
	$Spawners/EnemySpawnerLR.visible = current[3] > 0
	$Spawners/EnemySpawnerC.visible = current[4] > 0
	$Spawners/ArrowUL.visible = next[0] > 0
	$Spawners/ArrowLL.visible = next[1] > 0
	$Spawners/ArrowUR.visible = next[2] > 0
	$Spawners/ArrowLR.visible = next[3] > 0
	
func sum(list):
	var s = 0
	for i in list:
		s += i
	return s

#recieves a list of numbers of enemies to spawn in each position
var enemy = preload("res://jogo/assets/Enemy/Enemy.tscn")
func spawnEnemy(numList):
	#center of spawn positions
	var centerPoss = $Spawners.getSpawnPositions()
	for i in range(len(centerPoss)):
		var centerPos = centerPoss[i]
		var num = numList[i]
		for n in range(num):
			var e = enemy.instantiate()
			e.position.x = centerPos.x + randf_range(-1,1)*Globals.spawnRadius 
			e.position.z = centerPos.z + randf_range(-1,1)*Globals.spawnRadius 
			e.speed = randf_range(Globals.minESpeed, Globals.maxESpeed)
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
	if len(pos) > 0:
		$Cursor.update(pos)
		moveGhost()
	else:
		canPlace = false
	
func _input(event):
	if event is InputEventMouse:
		$menu.testMenuCol(event.position)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if canPlace and not $menu.up:
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
	
