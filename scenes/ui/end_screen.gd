extends Control

func _ready():
	$VBoxContainer/Score.text = str(Globals.score)

func _on_texture_button_pressed():
		Globals.score = 0
		get_tree().change_scene_to_file("res://scenes/lvls/lvl.tscn")
