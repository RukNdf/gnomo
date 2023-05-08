extends Node3D

var target : Node3D
@export var damage := 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func init(target_node, time_interval := 1):
	$Timer.wait_time = time_interval
	target = target_node
	$Timer.start()

func _on_timer_timeout():
	print("TIMER")
	target.poisonDamage(damage)
	$Timer.start()
	pass # Replace with function body.
