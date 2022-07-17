extends Node2D

enum State {
	AIMING
	ROLLING
	GUTTER_ROLLING
	RANDOMNESS
	PLACE_BALL
	NEXT_PLACE_BALL
}

enum Players {
	ONE
	TWO
}

var player_two_is_bot = true
var whose_turn = Players.ONE
var game_state = State.AIMING

func p1wins():
	$Win.add_child(load("res://HUD/qtip.tscn").instance())

func p2wins():
	$Win.add_child(load("res://HUD/victoria.tscn").instance())

func _ready():
	player_two_is_bot = Global.cpu

func _on_Hole_entered(body):
	if body is StaticBody:
		return
	if body.is_in_group("WhiteBall"):
		print("The white ball has entered a hole!")
		game_state = State.GUTTER_ROLLING
	if body.is_in_group("EightBall"):
		print("The 8-ball has entered a hole!")
		# The 8-ball is always a game ender!
		get_tree().paused = true
		if whose_turn == Players.ONE:
			if $CanvasLayer/TextureRect/Control/Player1Balls.get_child_count()==0:
				p1wins()
			else:
				p2wins()
		else:
			if $CanvasLayer/TextureRect/Control/Player2Balls.get_child_count()==0:
				p2wins()
			else:
				p1wins()
	if body.is_in_group("ColorBall"):
		print("Color ball ", body, " has entered a hole!")
		body.queue_free()
		if int(body.name.substr(4))<8:
			$"Q-T1p/AnimationPlayer".play("Happy")
			get_node("CanvasLayer/TextureRect/Control/Player1Balls/"+body.name).queue_free()
		else:
			$"Vic2ria/AnimationPlayer".play("Happy")
			get_node("CanvasLayer/TextureRect/Control/Player2Balls/"+body.name).queue_free()
	if body.is_in_group("Ball"):
		$Socket.stop()
		$Socket.play()

func advance_turn():
	if whose_turn == Players.ONE:
		whose_turn = Players.TWO
		$CanvasLayer/TextureRect/Control/Turn.text = "Vic2ria's turn"
	elif whose_turn == Players.TWO:
		whose_turn = Players.ONE
		$CanvasLayer/TextureRect/Control/Turn.text = "Q-T1p's turn"
	else:
		assert(false) # What
	reset_turn_state()

func rand():
	return (randf()-0.5)*2

func reset_turn_state():
	game_state = State.AIMING
	$PoolCue/AnimationPlayer.play("Appear")
	$ViewportView/Viewport/ThreeD/WhiteBall.move_cue = true
	if player_two_is_bot and whose_turn == Players.TWO:
		$ViewportView/Viewport/ThreeD/WhiteBall.rotate_cue = false
	else:
		$ViewportView/Viewport/ThreeD/WhiteBall.rotate_cue = true
	$ViewportView/Viewport/ThreeD/WhiteBall.effect = ""
	$CanvasLayer/TextureRect/Control/EffectIsText.show()
	$CanvasLayer/TextureRect/Control/ActualEffect.text = "None"
	$ViewportView.material.set("shader_param/bw", false)
	$FLEffect.hide()

func apply_effect(effect):
	var effectname = "None"
	if effect == 1:
		$FLEffect.show()
		effectname = "Flashlight"
	if effect == 2:
		game_state = State.PLACE_BALL
		if whose_turn == Players.ONE:
			effectname = "Q-T1p places ball"
		elif whose_turn == Players.TWO:
			effectname = "Vic2ria places ball"
	if effect == 3:
		effectname = "Wonky aim"
		$ViewportView/Viewport/ThreeD/WhiteBall.effect = "Wonky"
	if effect == 4:
		effectname = "Spin"
		$ViewportView/Viewport/ThreeD/WhiteBall.effect = "Spin"
	if effect == 5:
		effectname = "Colorblind"
		$ViewportView.material.set("shader_param/bw", true)
	if effect == 6:
		effectname = "Weak shot"
		$ViewportView/Viewport/ThreeD/WhiteBall.effect = "Weak"
	$CanvasLayer/TextureRect/Control/EffectIsText.show()
	$CanvasLayer/TextureRect/Control/ActualEffect.show()
	$CanvasLayer/TextureRect/Control/ActualEffect.text = "("+str(effect)+") "+effectname

func get_random_safe_mouse_position():
	return Vector2(960+(rand()*704), 534.5+(rand()*278.5))

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene("res://HUD/Mainmenu.tscn")
	if game_state == State.AIMING:
		if player_two_is_bot and whose_turn == Players.TWO:
			var to
			if $FLEffect.visible:
				to = get_random_safe_mouse_position()
			else:
				var dist = 1000
				var targetball
				for ball in get_tree().get_nodes_in_group("Ball"):
					if $CanvasLayer/TextureRect/Control/Player2Balls.get_child_count()>0: # If there are balls left
						if !$ViewportView.material.get("shader_param/bw"): # If we're not colorblind
							if ball.is_in_group("ColorBall"): # If it's a color ball
								if int(ball.name.substr(4))<8: # If it's p1's ball, don't
									continue
							else:
								continue
					else:
						if !ball.is_in_group("EightBall"): # If it's not the 8-ball, don't
							continue
					print("checking ball ", ball)
					for hole in get_tree().get_nodes_in_group("Hole"):
						var d = ball.global_transform.origin.distance_to(hole.global_transform.origin)
						print("checking ball ", ball, " against hole ", hole, ", ", d)
						if d < dist:
							print(d)
							targetball = ball
							dist = d
				to = $ViewportView/Viewport/ThreeD/Camera.unproject_position(targetball.translation)
			var mp = to
			mp.y = 1069 - mp.y
			$PoolCue.look_at(mp)
			$ViewportView/Viewport/ThreeD/WhiteBall.shoot_towards(to)
			game_state = State.ROLLING
			$ViewportView/Viewport/ThreeD/WhiteBall.move_cue = false
			$PoolCue/AnimationPlayer.play("Hit")
		else:
			if Input.is_action_just_pressed("Click"):
				$ViewportView/Viewport/ThreeD/WhiteBall.shoot_towards_mouse()
				game_state = State.ROLLING
				$ViewportView/Viewport/ThreeD/WhiteBall.move_cue = false
				$PoolCue/AnimationPlayer.play("Hit")
	if game_state == State.ROLLING or game_state == State.GUTTER_ROLLING:
		var still = true
		for ball in get_tree().get_nodes_in_group("Ball"):
			if ball.linear_velocity.length_squared()>0.02 or ball.angular_velocity.length_squared()>0.02:
				still = false
		if still:
			for ball in get_tree().get_nodes_in_group("Ball"):
				ball.linear_velocity=Vector3.ZERO
				if game_state == State.ROLLING:
					game_state = State.RANDOMNESS
				elif game_state == State.GUTTER_ROLLING:
					game_state = State.NEXT_PLACE_BALL
					$CanvasLayer/TextureRect/Control/ActualEffect.show()
					if whose_turn == Players.ONE:
						$CanvasLayer/TextureRect/Control/ActualEffect.text = "Vic2ria places ball"
					elif whose_turn == Players.TWO:
						$CanvasLayer/TextureRect/Control/ActualEffect.text = "Q-T1p places ball"
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
		var effect = table[opts.max()]
		print(effect)
		if effect != 2:
			# Game state PLACE BALL does this
			advance_turn()
		apply_effect(effect)
	if game_state == State.PLACE_BALL or game_state == State.NEXT_PLACE_BALL:
		var place = false
		var pos : Vector2
		$ViewportView/Viewport/ThreeD/WhiteBall.mode = RigidBody.MODE_KINEMATIC
		if (game_state == State.PLACE_BALL and whose_turn == Players.TWO and player_two_is_bot) or (game_state == State.NEXT_PLACE_BALL and whose_turn == Players.ONE and player_two_is_bot):
			# Random spot
			$ViewportView/Viewport/ThreeD/WhiteBall.translation = $ViewportView/Viewport/ThreeD/Camera.project_position(get_random_safe_mouse_position(), 1)
			place = true
		else:
			var mp = get_global_mouse_position()
			mp.y = 1069 - mp.y
			mp.x = clamp(mp.x, 256, 1664) # 1920-256
			mp.y = clamp(mp.y, 256, 813) # 1069-256
			$ViewportView/Viewport/ThreeD/WhiteBall.translation = $ViewportView/Viewport/ThreeD/Camera.project_position(mp, 1)
			if Input.is_action_just_released("Click"):
				place = true
		if place:
			$ViewportView/Viewport/ThreeD/WhiteBall.translation.y = 0
			$ViewportView/Viewport/ThreeD/WhiteBall.mode = RigidBody.MODE_RIGID
			advance_turn()
