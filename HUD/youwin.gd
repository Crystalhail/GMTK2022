extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("appear")
	yield(get_tree().create_timer(1),"timeout")
	$exit.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_exit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://HUD/Mainmenu.tscn")
