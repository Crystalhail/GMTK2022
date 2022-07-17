extends RigidBody

func _on_BallBase_body_entered(body):
	if body is RigidBody:
		$Impact.stop()
		$Impact.unit_db = clamp(-26+(linear_velocity.length_squared()*26), -26, 0)
		$Impact.pitch_scale = 0.8 + ((randf()-0.5) * 0.2)
		$Impact.play()
