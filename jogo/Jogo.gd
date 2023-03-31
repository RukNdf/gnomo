extends Node3D

#import draw3D for 3D lines
func _ready():	
	randomize()
	draw3D = Draw3D.new()
	add_child(draw3D)
	initGridSpace()
	spawnGrass()
	makeGhost()
	
func spawnGrass():
	var grass = preload("res://jogo/assets/Grass.tscn")
	var min = Vector2(0, 0)
	var gSize = $ground.size * $ground.scale
	var max = Vector2(gSize.x, gSize.z)
	for i in range(10+(randi()%100)):
		var g = grass.instantiate()
		g.position = Vector3(randf_range(min.x, max.x), 0, randf_range(min.y, max.y))
		add_child(g)
	
	
#DEBUG
var turnP = false
func _process(delta):
	if Input.is_key_pressed(KEY_O):
		if canPlace:
			if spawnFarm():
				place($Cursor.gridPos, ghost.size)
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

var farm = preload("res://jogo/assets/Farm.tscn")
var lastSpawnTime = 0
func spawnFarm():
	var t = Time.get_ticks_msec()
	if t < lastSpawnTime+Globals.placementDelay:
		return false
	lastSpawnTime = t
	var pos = $Cursor.getCenter()
	if len(pos) == 0:
		return false
	var f = farm.instantiate()
	f.position.x = pos.x + Globals.cameraOffset.x
	f.position.z = pos.z + Globals.cameraOffset.z
	f.position.y = 0.5
	add_child(f)
	return true
	
	
var smoke = preload("res://jogo/assets/Smoke.tscn")
func spawnSmoke(pos):
	var s = smoke.instantiate()
	s.position.x = pos.x
	s.position.y = 1.5
	s.position.z = pos.z + Globals.cameraOffset.z
	add_child(s)

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
	obj.die()
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		e.getTarget()
	
func remove(obj):
	remove_child(obj)

var turn = 1	
var atkTurn = false
func nextTurn():
	turn += 1
	if turn > 9:
		$Turn.text = 'Turn ' + str(turn) + ' '
	else: 
		$Turn.text = 'Turn   ' + str(turn) + ' '
	atkTurn = !atkTurn
	if(atkTurn):
		spawnEnemy()

var enemy = preload("res://jogo/assets/Enemy.tscn")
func spawnEnemy():
	var e = enemy.instantiate()
	e.position = Vector3(0,0,0)
	add_child(e)

	
func updateMousePos(pos):
	$Cursor.update(pos)
	moveGhost()
	
#############
# Placement
#############

#initialize gridSpace, by default all cells are empty
var gridSpace
func initGridSpace():
	gridSpace = []
	for x in range(Globals.maxX+1):
		gridSpace.append([])
		for y in range(Globals.maxY+1):
			gridSpace[x].append(false)
#test if there's a building intersecting within the grid and update canPlace
var canPlace = false
func testPlacement(pos, size):
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			if gridSpace[x][y]:
				canPlace = false
				return
	canPlace = true
#update grid
func place(pos, size):
	canPlace = false
	for x in range(pos.x, pos.x+size.x):
		for y in range(pos.y, pos.y+size.y):
			gridSpace[x][y] = true

var ghost
func makeGhost():
	#remove(ghost)
	ghost = farm.instantiate()
	add_child(ghost)
	ghost.createGhost()
#moves ghost and update placement
func moveGhost(): 
	#ghost.mat
	var pos = $Cursor.getCenter()
	testPlacement($Cursor.gridPos, ghost.size)
	if len(pos) == 0:
		return
	ghost.position.x = pos.x + Globals.cameraOffset.x
	ghost.position.z = pos.z + Globals.cameraOffset.z
	ghost.position.y = 0.5
	ghost.updateGhost(canPlace)
	
	
	
	
	
	
	
	
		
