extends RigidBody

#func _physics_process(_delta):
#	var to = get_viewport().get_camera().project_position(get_viewport().get_mouse_position(), 0)
#	if to.x-translation.x > linear_velocity.x or -(to.x-translation.x) > -linear_velocity.x:
#		linear_velocity.x = to.x-translation.x
#	if to.z-translation.z > linear_velocity.z or -(to.z-translation.z) > -linear_velocity.z:
#		linear_velocity.z = to.z-translation.z
