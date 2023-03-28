extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self.startGame)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func startGame():
	get_tree().change_scene_to_file("res://jogo/jogo.tscn")
