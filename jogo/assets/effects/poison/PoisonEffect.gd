extends Node3D

var target : Node3D
@export var damage := 0.5
@export var duration := 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func init(target_node, time_interval := 1):
	$Timer.wait_time = time_interval
	target = target_node
	$Timer.start()

func _on_timer_timeout():
	if duration > 0:
		target.poisonDamage(damage)
		duration -= 1
		$Timer.start()
	else:
		var newStatus = get_parent().get_status()
		newStatus.erase("poison")
		get_parent().set_status(newStatus)
		queue_free()
	pass # Replace with function body.
