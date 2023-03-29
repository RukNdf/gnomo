extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	draw3D = Draw3D.new()
	add_child(draw3D)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_O):
		spawnFarm()
	if Input.is_key_pressed(KEY_S):
		spawnSmoke($farm.getSmokePos())
	if Input.is_key_pressed(KEY_T):
		nextTurn()
	pass

var farm = preload("res://jogo/assets/Farm.tscn")
var lastSpawnTime = 0
func spawnFarm():
	var t = Time.get_ticks_msec()
	if t < lastSpawnTime+250:
		return
	lastSpawnTime = t
	var pos = $Cursor.getCenter()
	if len(pos) == 0:
		return
	var f = farm.instantiate()
	f.position.x = pos.x + Globals.cameraOffset.x
	f.position.z = pos.z + Globals.cameraOffset.z
	f.position.y = 0.5
	add_child(f)
	pass
	
	
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

func destroy(obj):	
	if(!obj.has_method('die')):
		return
	obj.die()
	spawnSmoke(obj.getSmokePos())
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		e.getTarget()
	
func remove(obj):
	remove_child(obj)

var turn = 1	
func nextTurn():
	spawnEnemy()

var enemy = preload("res://jogo/assets/Enemy.tscn")
func spawnEnemy():
	var e = enemy.instantiate()
	e.position = Vector3(0,0,0)
	add_child(e)
