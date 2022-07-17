extends "res://BallBase.gd"

var move_cue = true
var rotate_cue = true
var speed_multiplier = 4
var speed_cap = 8
var effect = ""

func _process(_delta):
	var pos = get_viewport().get_camera().unproject_position(translation)
	pos.y = 1069 - pos.y
	$"../../../../FLEffect/FlashLight".position = pos
	$"../../../../FLEffect/Blackness".material.set("shader_param/at", pos)
	$"../../../../FLEffect/FlashLight".material.set("shader_param/at", pos)
	if !move_cue:
		return
	$"../../../../PoolCue".position = pos
	$"../../../../PoolCue".look_at($"../../../..".get_global_mouse_position())

func shoot_towards_mouse():
	var mp = $"../../../..".get_local_mouse_position()
	mp.y = 1069 - mp.y
	shoot_towards(mp)

func shoot_towards(mp):
	if effect == "Wonky":
		mp.x+=50-(100*randf())
		mp.y+=50-(100*randf())
	var projected_mouse = get_viewport().get_camera().project_position(mp, 0)
	if effect == "Spin":
		rotate_x(randi()*0.01)
		rotate_y(randi()*0.01)
		rotate_z(randi()*0.01)
		angular_velocity = Vector3(0, 800, 0)
	# Since we are projecting with zero Z-depth we should make sure we don't shoot the ball upwards by not affecting the Y axis
	if effect == "Weak":
		linear_velocity.x = min(speed_cap, (projected_mouse.x-translation.x) * speed_multiplier / 4)
		linear_velocity.z = min(speed_cap, (projected_mouse.z-translation.z) * speed_multiplier / 4)
	else:
		linear_velocity.x = min(speed_cap, (projected_mouse.x-translation.x) * speed_multiplier)
		linear_velocity.z = min(speed_cap, (projected_mouse.z-translation.z) * speed_multiplier)
