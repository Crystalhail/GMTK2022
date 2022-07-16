extends Node2D

enum State {
	AIMING
	ROLLING
	RANDOMNESS
}

enum Players {
	ONE
	TWO
}

var player_two_is_bot = true
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
	game_state = State.AIMING

func _process(_delta):
	if game_state == State.AIMING:
		if Input.is_action_just_pressed("Click"):
			$ViewportView/Viewport/ThreeD/WhiteBall.shoot_towards_mouse()
			game_state = State.ROLLING
	if game_state == State.ROLLING:
		var still = true
		for ball in get_tree().get_nodes_in_group("Ball"):
			ball.visible = !ball.visible
			if ball.linear_velocity.length_squared()>0.01 or ball.angular_velocity.length_squared()>0.01:
				still = false
		if still:
			for ball in get_tree().get_nodes_in_group("Ball"):
				ball.visible=true
				ball.linear_velocity=Vector3.ZERO
			advance_turn()
