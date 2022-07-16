extends RigidBody

var move_cue = true
var rotate_cue = true
var speed_multiplier = 4
var speed_cap = 8

func _process(_delta):
	if !move_cue:
		return
	var pos = get_viewport().get_camera().unproject_position(translation)
	pos.y = 1069 - pos.y
	$"../../../../PoolCue".position = pos
	$"../../../../PoolCue".look_at($"../../../..".get_global_mouse_position())

func shoot_towards_mouse():
	var mp = $"../../../..".get_local_mouse_position()
	mp.y = 1069 - mp.y
	var projected_mouse = get_viewport().get_camera().project_position(mp, 0)
	# Since we are projecting with zero Z-depth we should make sure we don't shoot the ball upwards by not affecting the Y axis
	linear_velocity.x = min(speed_cap, (projected_mouse.x-translation.x) * speed_multiplier)
	linear_velocity.z = min(speed_cap, (projected_mouse.z-translation.z) * speed_multiplier)
