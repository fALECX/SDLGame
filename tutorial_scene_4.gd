extends Node2D

const TUTORIAL_SCENE_5 = preload("res://tutorial_scene_5.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_continue_pressed():
	print("tutorial scene 5")
	get_tree().change_scene_to_packed(TUTORIAL_SCENE_5)