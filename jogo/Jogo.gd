extends Node3D


#MUTE ALL GAME AUDIO
const MUTE = true



#############################################################
# Init
#############################################################
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
	initGridSpace()
	initTurns()
	spawnGrass()
	initGhost()
	updateMushrooms(0)

#mute
func mute():
	var master_sound = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_sound, true)

#initialize gridSpace to simplify placement testing, by default all cells are empty
var gridSpace
func initGridSpace():
	gridSpace = []
	for x in range(Globals.maxX+1):
		gridSpace.append([])
		for y in range(Globals.maxY+1):
			gridSpace[x].append(false)

#set farm as default building 
func initGhost():
	ghost = farm.instantiate()
	ghost.position.x = -500
	select('mush')

#initialize turns from turn file
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



#############################################################
# Graphics
#############################################################
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

#clear all smoke
func clearSmoke():
	for s in get_tree().get_nodes_in_group('smoke'):
		remove_child(s)



#############################################################
# Building
#############################################################
#buildings
var farm = preload("res://jogo/assets/Buildings/Farm.tscn")
var tower = preload("res://jogo/assets/Buildings/Tower.tscn")
var wide = preload("res://jogo/assets/Buildings/WideFarm.tscn")
#last selected action icon
var icon	
#placement test
var lastSpawnTime = 0
var canPlace = false

#select building/action	
func select(type):
	selected = type
	var pos = ghost.position
	remove_child(ghost)
	#repair or destroy building
	if type == 'fix':
		print('fix')
		ghostEnabled = false
		return
	#place building
	ghostEnabled = true	
	if type == 'mush':
		ghost = farm.instantiate()
	elif type == 'tower':
		ghost = tower.instantiate()
	elif type == 'wide':
		ghost = wide.instantiate()
	ghost.init()
	ghostDisplacement = ghost.calcDisplacement()
	ghost.createGhost()
	ghost.position = pos
	add_child(ghost)
	moveGhost()


#test if user can place a building
func tryPlace(cost):
	var t = Time.get_ticks_msec()
	if t < lastSpawnTime+Globals.placementDelay:
		return false
	return updateMushrooms(cost)

#test if spot is empty within the 2D grid
func testPlacement(pos, size):
	if pos.x+size.x > Globals.maxX or pos.y+size.y > Globals.maxY:
		canPlace = false
		return
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			if gridSpace[x][y]:
				canPlace = false
				return
	canPlace = true

#spawn building
func spawn(type):
	if !ghostEnabled:
		return
	lastSpawnTime = Time.get_ticks_msec()
	var f
	if type == 'mush':
		f = farm.instantiate()
		numBuilding += 1
	elif type == 'wide':
		f = wide.instantiate()
		numBuilding += 1
	elif type == 'tower':
		f = tower.instantiate()
	else:
		return
	var pos = $Cursor.getCenter()
	if len(pos) == 0:
		return false
	$SFX/Build.play()
	f.init()
	f.position.x = pos.x + ghostDisplacement.x + Globals.cameraOffset.x
	f.position.z = pos.z + ghostDisplacement.z + Globals.cameraOffset.z
	f.position.y = 0.5
	add_child(f)
	return true

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

#move icon and display when action is valid
func moveIcon():
	if selected == 'fix':
		icon = $Icons/Hammer
	else:
		return
	if gridSpace[$Cursor.gridPos.x][$Cursor.gridPos.y]:
		icon.visible = true
		$Icons/Hammer.position.x = $Camera.mousePos.x
		$Icons/Hammer.position.y = $Camera.mousePos.y
		print($Icons/Hammer.position)
	else:
		icon.visible = false



#############################################################
# Ghost
#############################################################
var ghost
var ghostEnabled = true
var ghostState = canPlace
var ghostDisplacement
#moves ghost and update placement
func moveGhost(): 
	var pos = $Cursor.getCenter()
	testPlacement($Cursor.gridPos, ghost.size)
	if len(pos) == 0:
		return
	ghost.position.x = pos.x + ghostDisplacement.x + Globals.cameraOffset.x
	ghost.position.z = pos.z + ghostDisplacement.z + Globals.cameraOffset.z
	ghost.position.y = 0.5
	#only update color if it changed
	if ghostState != canPlace:
		ghost.updateGhost(canPlace)
		ghostState = canPlace



#############################################################
# Turns
#############################################################
#current turn
var turnCount = 1
#enemies are attacking
var atkTurn = false 
#next turn
var nextTurn

#next turn
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
			disableBuild()
			atkTurn = true
			defend()
			$Bsong.stop()
			$Horn.play()
			await get_tree().create_timer(2).timeout
			$Asong.play()
		announceEnemy(turn, nextTurn)
		spawnEnemy(turn)
	else:
		announceEnemy(turn, nextTurn)
		
func disableBuild():
	ghostEnabled = false
	$Cursor.visible = false
	ghost.visible = false
	$Overlay/Build.visible = false
	$Overlay/Defend.visible = true
	$menu.position.y += 500

func enableBuild():
	ghostEnabled = true
	$Cursor.visible = true
	ghost.visible = true
	$Overlay/Build.visible = true
	$Overlay/Defend.visible = false
	$menu.position.y -= 500

#sum list
func sum(list):
	var s = 0
	for i in list:
		s += i
	return s

#Display where enemy spawn/warnings
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
	
#all enemies dead, no longer under attack
func enemyDeath():
	numEnemy -= 1
	if numEnemy == 0:
		enableBuild()
		$AtkTimer.stop()
		atkTurn = false
		$Asong.stop()
		$Bsong.play()
		clearSmoke()

#buildings produce resources between turns
func updateResources():
	var m = 0
	for f in get_tree().get_nodes_in_group("farms"):
		m += f.produces
	updateMushrooms(m)

#update mushroom counter
func updateMushrooms(num):
	if resources[mush] + num < 0:
		return false
	resources[mush] += num
	$Overlay/resources.updateMush(resources[mush])
	return true


#############################################################
# Defend 
#############################################################
#start turret processing
func defend():
	$AtkTimer.set_wait_time(Globals.atkDelay)
	$AtkTimer.start()
	
#turrets attack nearest enemy
func towerAtk():
	for tower in get_tree().get_nodes_in_group("tower"):
		if tower.dead:
			continue
		var e = tower.kill()
		if e != null:
			atkUnit(e)
	if(!atkTurn):
		$AtkTimer.stop()
		
#hit unit
func atkUnit(e):
	$SFX/EnemyHit.play()
	if e.hit():
		$SFX/EnemyDeath.play()

#destroy building
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
	
#remove destroyed building from game tree 
func remove(obj):
	remove_child(obj)

#game over
func gameOver():
	$menu/colBox.position.y = 1000
	$Overlay/AnimationPlayer.play("GG")
	$Cursor.visible = false
	ghost.visible = false	

#recieves a list of numbers of enemies to spawn in each position
var numEnemy = 0
var enemy = preload("res://jogo/assets/Enemy/Enemy.tscn")
func spawnEnemy(numList):
	#center of spawn positions
	var centerPoss = $Spawners.getSpawnPositions()
	for i in range(len(centerPoss)):
		var centerPos = centerPoss[i]
		var num = numList[i]
		numEnemy += num
		for n in range(num):
			var e = enemy.instantiate()
			e.position.x = centerPos.x + randf_range(-1,1)*Globals.spawnRadius 
			e.position.z = centerPos.z + randf_range(-1,1)*Globals.spawnRadius 
			e.speed = randf_range(Globals.minESpeed, Globals.maxESpeed)
			add_child(e)



#############################################################
# ... 
#############################################################
func _input(event):
	if event is InputEventMouse:
		$menu.testMenuCol(event.position)
	if event is InputEventMouseButton:
		var test = $Camera.selectEnemy()
		if len(test) > 0:
			test.collider.play()
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if canPlace and not $menu.up:
				if tryPlace(ghost.cost):
					spawn(selected)
					place($Cursor.gridPos, ghost.size)

func updateMousePos(pos):
	if len(pos) > 0:
		if ghostEnabled:
			$Cursor.update(pos)
			moveGhost()
		else:
			$Cursor.update(pos)
			moveIcon()
	else:
		canPlace = false
