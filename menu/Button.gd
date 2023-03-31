extends Button


func _ready():
	self.pressed.connect(self.startGame)

func startGame():
	get_tree().change_scene_to_file("res://jogo/Jogo.tscn")
