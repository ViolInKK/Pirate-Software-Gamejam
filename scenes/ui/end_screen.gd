extends Control

func _ready():
	$Score.text = str(Globals.score)
	
func _on_retry_pressed():
		Globals.score = 0
		get_tree().change_scene_to_file("res://scenes/lvls/lvl.tscn")
