extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_credits_pressed():
	$Main.hide()
	$Credits.show()


func _on_back_pressed():
	$Main.show()
	$Credits.hide()

func _on_humanplay_pressed():
	Global.cpu = false
	load_scene()

func _on_botplay_pressed():
	Global.cpu = true
	load_scene()

func load_scene():
	get_tree().change_scene("res://MainScene.tscn")
