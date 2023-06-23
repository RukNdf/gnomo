extends Node3D


#MUTE ALL GAME AUDIO
const MUTE = true



#############################################################
# Init
#############################################################
#resource indexes
const MUSH = 0
#resource list
var resources = [50]
#num of required buildings (e.g. farm)
var numBuilding = 0
#current selected building
var selected = 'mush'
#turn configuration
var turns
#3d lines
var draw3D
#ded
var gg = false

#initialize game field
func _ready():	
	if(MUTE):
		mute()
	randomize()
	draw3D = Draw3D.new()
	add_child(draw3D)
	icon =  $Icons/Hammer
	initGridSpace()
	initTurns()
	spawnGrass()
	initGhost()
	updateMushrooms(0)
	enableStorageMode()

#mute
func mute():
	var master_sound = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_sound, true)

#initialize gridSpace to simplify placement testing, by default all cells are empty
var gridSpace
var fences
func initGridSpace():
	gridSpace = []
	for x in range(Globals.maxX+1):
		gridSpace.append([])
		for y in range(Globals.maxY+1):
			gridSpace[x].append(false)
	fences = []
	for x in range(Globals.maxX+1):
		fences.append([])
		for y in range(Globals.maxY+1):
			fences[x].append(false)

#set farm as default building 
func initGhost():
	ghost = farm.instantiate()
	ghost.position.x = -500
	selected = 'mush'
	icon.visible = false
	ghostEnabled = true	
	$Camera.mode = Globals.BUILDMODE
	ghost = farm.instantiate()
	ghost.init()
	ghostDisplacement = ghost.calcDisplacement()
	ghost.createGhost()
	add_child(ghost)
	moveGhost()

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
# Storage
#############################################################
var hasStorage = false
func enableStorageMode():
	atkTurn = true
	$menu.visible = false
	$Overlay/Label.visible = false
	$Cursor.visible = false
	_select('storage')

func disableStorageMode():
	hasStorage = true
	atkTurn = false
	$menu.visible = true
	$Overlay/Label.visible = true
	$Cursor.visible = true
	select('mush')

#storage destroyed, remove resources and force replace
func storageDestroyed():
	hasStorage = false
	resources[MUSH] = 0
	$Overlay/resources.updateMush(0)


#############################################################
# Building
#############################################################
#buildings
var farm = preload("res://jogo/assets/Buildings/Farm.tscn")
var wide = preload("res://jogo/assets/Buildings/WideFarm.tscn")
var storage = preload("res://jogo/assets/Buildings/Storage.tscn")
var fence = preload("res://jogo/assets/Buildings/FencePost.tscn")
var tower = preload("res://jogo/assets/Buildings/Tower.tscn")
var poison_tower = preload("res://jogo/assets/Buildings/PoisonTower/PoisonTower.tscn")
#last selected action icon
var icon
#placement test
var lastSpawnTime = 0
var canPlace = false
var placingEnabled = true
#selected building to repair/delete
var selectedBuilding = null

#select and update cursor
func select(type):
	_select(type)
	updateBuildCursor($Camera.groundedMousePos)
#select building/action	
func _select(type):	
	selected = type
	var pos = ghost.position
	remove_child(ghost)
	icon.visible = false
	#repair or destroy building
	if type == 'fix':
		icon = $Icons/Hammer
		enableEdit()
		return
	elif type == 'dest':
		icon = $Icons/Destroy
		enableEdit()
		return
	#place building
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ghostEnabled = true	
	$Cursor.visible = true
	$Camera.mode = Globals.BUILDMODE
	if type == 'mush':
		ghost = farm.instantiate()
	if type == 'storage':
		ghost = storage.instantiate()
	elif type == 'tower':
		ghost = tower.instantiate()
	elif type == 'wide':
		ghost = wide.instantiate()
	elif type == 'poison_tower':
		ghost = poison_tower.instantiate()
	elif type == 'fence':
		ghost = fence.instantiate()
	ghost.init()
	updateCost(Globals.buildingPrices[ghost.buildingType])
	ghostDisplacement = ghost.calcDisplacement()
	ghost.createGhost()
	ghost.position = pos
	$Cursor.changeSize(ghost.size)
	add_child(ghost)

func updateCost(cost):
	$Overlay/Label.text = '(-'+str(cost)+')'

func enableEdit():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	$Camera.mode = Globals.EDITMODE
	icon.visible = true
	ghostEnabled = false
	$Cursor.visible = false
	moveIcon()
	
func togglePlacing(enabled):
	placingEnabled = enabled

#test if user can place a building
func tryPlace(cost):
	if not placingEnabled:
		return
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
	ghost.updateCost()
	lastSpawnTime = Time.get_ticks_msec()
	var f
	var required = false
	if type == 'mush':
		required = true
		f = farm.instantiate()
		numBuilding += 1
	elif type == 'storage':
		required = true
		f = storage.instantiate()
		f.updtMush(resources[MUSH])
		numBuilding += 1
		disableStorageMode()
	elif type == 'wide':
		required = true
		f = wide.instantiate()
		numBuilding += 1
	elif type == 'tower':
		f = tower.instantiate()
	elif type == 'poison_tower':
		f = poison_tower.instantiate()
	elif type == 'fence':
		f = fence.instantiate()
	else:
		return
	var pos = $Cursor.getCenter()
	if len(pos) == 0:
		return false
	$SFX/Build.play()
	if type == 'fence':
		f.init($Cursor.gridPos)
	else:
		f.init()
	f.position.x = pos.x + ghostDisplacement.x + Globals.cameraOffset.x
	f.position.z = pos.z + ghostDisplacement.z + Globals.cameraOffset.z
	f.position.y = 0.5
	f.ready()
	add_child(f)
	updateNextResources()
	updateCost(Globals.buildingPrices[ghost.buildingType])
	if required:
		$Overlay/turnButton.disabled = false
	return true

#place building within the grid
func place(pos, size):
	canPlace = false
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			gridSpace[x][y] = true
			if selected == 'fence':
				fences[x][y] = true
				updateFences()

#clear space on grid when destroyed
func clearPlace(position, size, group=''):
	var pos = Vector2()
	pos.x = position.x/Globals.gridSize
	pos.y = position.z/Globals.gridSize
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			gridSpace[x][y] = false
			fences[x][y] = false
	if group == 'farms':
		updateEnemyTargets()
		removeFarm()
	elif group == 'storage':
		storageDestroyed()
		updateEnemyTargets()
		removeFarm()
	else:
		updateFences()

#move icon and display when action is valid
func moveIcon():
	if $Camera.mode != Globals.EDITMODE:
		return
	icon.position.x = $Camera.mousePos.x
	icon.position.y = $Camera.mousePos.y

func updateFences():
	for f in get_tree().get_nodes_in_group('fence'):
		f.updateFence(fences)
		



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
		$Cursor.toggleBuild(canPlace)
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
#turn change in progress, can't pass another turn
var turnChange = false

#next turn
func passTurn():
	if turnChange:
		return
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
			turnChange = true
			disableBuild()
			atkTurn = true
			defend()
			$Bsong.stop()
			$Horn.play()
			$Overlay/turnButton.disabled = true
			await get_tree().create_timer(2).timeout
			turnChange = false
			$Overlay/turnButton.disabled = false
			$Asong.play()
		announceEnemy(turn, nextTurn)
		spawnEnemy(turn)
	else:
		announceEnemy(turn, nextTurn)
		updateResources()
		
func disableBuild():
	ghostEnabled = false
	$Cursor.visible = false
	ghost.visible = false
	$Overlay/Build.visible = false
	$Overlay/Defend.visible = true
	$menu.position.y += 500
	$Overlay/Label.visible = false

func enableBuild():
	ghostEnabled = true
	$Cursor.visible = true
	ghost.visible = true
	$Overlay/Build.visible = true
	$Overlay/Defend.visible = false
	$menu.position.y -= 500
	$Overlay/Label.visible = true

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
		if !hasStorage:
			enableStorageMode()

#calculate the resources generated per turn
func calcNextResources():
	var m = 0
	for f in get_tree().get_nodes_in_group("farms"):
		if !f.dead:
			m += f.produces
	return m
#buildings produce resources between turns
func updateResources():
	updateMushrooms(calcNextResources())
	for s in get_tree().get_nodes_in_group("storage"):
		print(s)
		s.updtMush(resources[MUSH])
#update counter of resource change at the end of the turn
func updateNextResources():
	$Overlay/resources.updateMushPT(calcNextResources())


#update mushroom counter
func updateMushrooms(num):
	if resources[MUSH] + num < 0:
		return false
	resources[MUSH] += num
	$Overlay/resources.updateMush(resources[MUSH])
	return true


#############################################################
# Defend 
#############################################################
#list of attack lines to render on screen
var atkLines = []
#time of next atk line to despawn
var nextDespawnTime = 0

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
			atkUnit(e, tower.position)
	if(!atkTurn):
		draw3D.clear()
		$AtkTimer.stop()
		$atkLineTimer.stop()

#add another attack line to render on screen
func addAtkLine(src, dst):
	var despawnTime = Time.get_ticks_msec() + Globals.projectileDuration
	src.y = Globals.projectileSrcHeight
	dst.y = Globals.projectileDstHeight
	atkLines += [[[src,dst], despawnTime]]
	print(atkLines)
	draw3D.draw_line([src,dst])
	nextDespawnTime = atkLines[0][0]
	if($atkLineTimer.is_stopped()):
		$atkLineTimer.set_wait_time(Globals.projectileCleanupTimer)
		$atkLineTimer.start()
	
#remove expired lines and redraw
func updateAtkLine():
	var curTime = Time.get_ticks_msec()
	var len = len(atkLines)
	while len > 0:
		if(atkLines[0][1] < curTime):
			atkLines.remove_at(0)
			len -= 1
		else:
			break
	draw3D.clear()
	for line in atkLines:
		draw3D.draw_line(line[0])

#hit unit
func atkUnit(e, source):
	addAtkLine(source, e.position)
	$SFX/EnemyHit.play()
	if e.hit():
		$SFX/EnemyDeath.play()

#damage building
func damageBuilding(col):	
	var obj
	if(col.has_method('getNode')):
		obj = col.get_parent().getNode()
	else:
		obj = col.get_parent()
	if(!obj.has_method('damage')):
		return
	if obj.dead:
		return
	obj.damage()

#destroy building
func destroy(col):	
	var obj
	if(col.has_method('getNode')):
		obj = col.get_parent().getNode()
	else:
		obj = col.get_parent()
	if(!obj.has_method('die')):
		return
	if obj.dead:
		return
	var group = obj.group	
	#kills object but doesn't spawn smoke if it's not getting attacked
	obj.die(atkTurn)
	if group == 'farms':
		removeFarm()
	
#call after a farm is destroyed
func removeFarm():
	numBuilding -= 1	
	if numBuilding == 0:
		if atkTurn:
			gameOver()
		else:
			$Overlay/turnButton.disabled = true
	updateEnemyTargets()

func updateEnemyTargets():
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
	gg = true
	$Cursor.visible = false
	ghost.visible = false	
	$Overlay/turnButton.disabled = true

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
# Camera
#############################################################
#x position, zoom, and z position
var minCamera = Vector3i(20,5,20)
var maxCamera = Vector3i(60,100,50)
var moveFactor = Vector2(.6, 0.3)
var zoomFactor = 1
func cameraZoomIn():
	$Camera.size -= zoomFactor
	if $Camera.size < minCamera.y:
		$Camera.size = minCamera.y
func cameraZoomOut():
	$Camera.size += zoomFactor
	if $Camera.size > maxCamera.y:
		$Camera.size = maxCamera.y
func moveCamera(x,z):
	$Camera.position.x += x
	if x < 0:
		if($Camera.position.x < minCamera.x):
			$Camera.position.x = minCamera.x
	else:
		if($Camera.position.x > maxCamera.x):
			$Camera.position.x = maxCamera.x
	$Camera.position.z += z
	if z < 0:
		if($Camera.position.z < minCamera.z):
			$Camera.position.z = minCamera.z
	else:
		if($Camera.position.z > maxCamera.z):
			$Camera.position.z = maxCamera.z

#############################################################
# ... 
#############################################################
func _process(delta):
	#var moveCamera = false
	#var move = 
	if Input.is_key_pressed(KEY_W):
		moveCamera(-moveFactor.x,-moveFactor.x)
	elif Input.is_key_pressed(KEY_S):
		moveCamera(moveFactor.x,moveFactor.x)
	if Input.is_key_pressed(KEY_A):
		moveCamera(-moveFactor.y,moveFactor.y)
	elif Input.is_key_pressed(KEY_D):
		moveCamera(moveFactor.y,-moveFactor.y)
	elif Input.is_key_pressed(KEY_SPACE):
		damageBuilding($gnome.col)
	elif Input.is_action_just_pressed('toggleMenu'):
		$menu.toggleMenu()
	elif Input.is_key_pressed(KEY_T):
		updateResources()
	elif Input.is_key_pressed(KEY_Y):
		resources[MUSH] = 0
	if Input.is_key_pressed(KEY_C):
		enableStorageMode()
	if Input.is_action_just_pressed("Restart") and gg:
		get_tree().reload_current_scene()
		
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_ctrl_pressed() or gg:
			if event.keycode == KEY_ESCAPE:
				get_tree().change_scene_to_file("res://menu/Menu.tscn")
		if !atkTurn:
			keySelect(event.keycode)
	if event is InputEventMouse:
		$menu.testMenuCol(event.position)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cameraZoomIn()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cameraZoomOut()
		if $Camera.mode == Globals.BUILDMODE:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if canPlace and not $menu.up:
					if tryPlace(-ghost.getCost()):
						spawn(selected)
						place($Cursor.gridPos, ghost.size)
		elif $Camera.mode == Globals.EDITMODE:
			if selectedBuilding != null:
				icon.click(selectedBuilding)
		else:
			var test = $Camera.selectEnemy()
			if len(test) > 0:
				test.collider.play()

func keySelect(key):
	var selected
	if key == KEY_1 or key == KEY_KP_1:
		selected = 0
	elif key == KEY_2 or key == KEY_KP_2:
		selected = 1
	elif key == KEY_3 or key == KEY_KP_3:
		selected = 2
	elif key == KEY_4 or key == KEY_KP_4:
		selected = 3
	elif key == KEY_5 or key == KEY_KP_5:
		selected = 4
	else:
		if key == KEY_ESCAPE:
			$menu.reset()
		return
	$menu.shortcut(selected)

func updateBuildCursor(pos):
	if len(pos) > 0:
		$Cursor.update(pos)
		moveGhost()
	else:
		canPlace = false
	
func updateEditCursor(pos):
	print('test')
	moveIcon()
	if len(pos) > 0:
		icon.hover(true)
		selectedBuilding = pos.collider
		$Cursor.update(pos)
	else:
		icon.hover(false)
		selectedBuilding = null


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	pass # Replace with function body.
