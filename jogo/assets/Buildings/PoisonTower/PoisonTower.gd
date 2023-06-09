extends Building

var effect := preload("res://jogo/assets/effects/poison/PoisonEffect.tscn")
############
# Init
############
func init():
	size = Vector2i(1,1)
	group = "poison_tower"
	dead = false
	cost = 15

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	print("TO VIVO")
	pass

func deal_poison(body):
	# apply poison
	if body.is_in_group("enemy") and body.has_method("get_status") and not body.get_status().has("poison"):
		print("AAAAA-->", body, dead)
		if body.has_method("poisonDamage"):
			var newStatus = body.get_status()
			newStatus["poison"] = 0.5
			body.set_status(newStatus)
			
			body.poisonDamage(0.5)
			var effectInstance = effect.instantiate()
			body.add_child(effectInstance)
			effectInstance.init(body)
	else:
		print("-->", body, dead)

func _on_area_3d_body_entered(body):
	deal_poison(body)

func _on_area_3d_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	deal_poison(body)

func _on_area_3d_area_entered(area):
	deal_poison(area)
	pass # Replace with function body.
