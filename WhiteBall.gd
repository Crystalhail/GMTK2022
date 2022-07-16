extends RigidBody

var speed_multiplier = 4

func shoot_towards_mouse():
	var projected_mouse = get_viewport().get_camera().project_position(get_viewport().get_mouse_position(), 0)
	# Since we are projecting with zero Z-depth we should make sure we don't shoot the ball upwards by not affecting the Y axis
	linear_velocity.x = (projected_mouse.x-translation.x) * speed_multiplier
	linear_velocity.z = (projected_mouse.z-translation.z) * speed_multiplier
