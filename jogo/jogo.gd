extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_O):
		spawnFarm()
	pass

var farm = preload("res://jogo/assets/farm.tscn")
var lastSpawnTime = 0
func spawnFarm():
	var t = Time.get_ticks_msec()
	if t < lastSpawnTime+250:
		return
	lastSpawnTime = t
	var pos = $Camera3D.getMousePos()
	if len(pos) == 0:
		return
	var f = farm.instantiate()
	f.position.x = pos.position.x
	f.position.z = pos.position.z
	f.position.y = 0.5
	add_child(f)
	pass
