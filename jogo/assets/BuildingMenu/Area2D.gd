extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
var buttonHover = false


var t = Time.get_ticks_msec()
func _mouse_enter():
	if(!buttonHover):
		print('hover')

func _mouse_exit():
	if(!buttonHover):
		print('leave')


func button_hover():
	print('button')
	buttonHover = true
	pass # Replace with function body.


func button_leave():
	buttonHover = false
	pass # Replace with function body.


func _on_mouse_entered():
	print('test')
	pass # Replace with function body.


func _on_mouse_shape_entered(shape_idx):
	print('shape')
	pass # Replace with function body.
