extends Node2D

enum State {
	AIMING
	ROLLING
	RANDOMNESS
	PLACE_BALL
}

enum Players {
	ONE
	TWO
}

var player_two_is_bot = false
var whose_turn = Players.ONE
var game_state = State.AIMING

func _on_Hole_entered(body):
	if body is StaticBody:
		return
	if body.is_in_group("WhiteBall"):
		print("The white ball has entered a hole!")
	if body.is_in_group("EightBall"):
		print("The 8-ball has entered a hole!")
	if body.is_in_group("ColorBall"):
		print("Color ball ", body, " has entered a hole!")
		body.queue_free()

func advance_turn():
	if whose_turn == Players.ONE:
		whose_turn = Players.TWO
	elif whose_turn == Players.TWO:
		whose_turn = Players.ONE
	else:
		assert(false) # What
	reset_turn_state()

func reset_turn_state():
	game_state = State.AIMING
	$PoolCue/AnimationPlayer.play("Appear")
	$ViewportView/Viewport/ThreeD/WhiteBall.move_cue = true
	if player_two_is_bot and whose_turn == Players.TWO:
		$ViewportView/Viewport/ThreeD/WhiteBall.rotate_cue = false
	else:
		$ViewportView/Viewport/ThreeD/WhiteBall.rotate_cue = true

func _process(_delta):
	if game_state == State.AIMING:
		if player_two_is_bot and whose_turn == Players.TWO:
			$ViewportView/Viewport/ThreeD/WhiteBall.move_cue = false
		else:
			if Input.is_action_just_pressed("Click"):
				$ViewportView/Viewport/ThreeD/WhiteBall.shoot_towards_mouse()
				game_state = State.ROLLING
				$ViewportView/Viewport/ThreeD/WhiteBall.move_cue = false
				$PoolCue/AnimationPlayer.play("Hit")
	if game_state == State.ROLLING:
		var still = true
		for ball in get_tree().get_nodes_in_group("Ball"):
			if ball.linear_velocity.length_squared()>0.01 or ball.angular_velocity.length_squared()>0.01:
				still = false
		if still:
			for ball in get_tree().get_nodes_in_group("Ball"):
				ball.linear_velocity=Vector3.ZERO
				game_state = State.RANDOMNESS
	if game_state == State.RANDOMNESS:
		var opts : Array = [
			$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.x.y,
			$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.y.y,
			$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.z.y,
			-$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.x.y,
			-$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.y.y,
			-$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.z.y
		]
		var table = {
			$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.x.y:  1,
			$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.y.y:  5,
			$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.z.y:  4,
			-$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.x.y: 6,
			-$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.y.y: 2,
			-$ViewportView/Viewport/ThreeD/WhiteBall.transform.basis.z.y: 3
		}
		print(table[opts.max()])
		advance_turn()
