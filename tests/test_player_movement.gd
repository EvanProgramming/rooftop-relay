extends SceneTree

var failed: bool = false

func _initialize() -> void:
	var player_script = load("res://scripts/player.gd")
	_expect(player_script != null and player_script.can_instantiate(), "the player script loads and parses")
	if player_script == null or not player_script.can_instantiate():
		quit(1)
		return
	var player = player_script.new()
	_expect(is_equal_approx(player.compute_horizontal_velocity(0.0, 1.0, 0.25), player_script.MOVE_SPEED), "right input reaches the run speed")
	_expect(is_equal_approx(player.compute_horizontal_velocity(0.0, -1.0, 0.1), -120.0), "left input accelerates left")
	_expect(is_equal_approx(player.compute_horizontal_velocity(250.0, 0.0, 0.1), 94.0), "neutral input slows the player")
	_expect(is_equal_approx(player.compute_vertical_velocity(0.0, 0.016, true, true), player_script.JUMP_VELOCITY), "grounded jump applies the jump impulse")
	_expect(is_equal_approx(player.compute_vertical_velocity(20.0, 0.1, false, false), 165.0), "gravity accelerates a falling player")
	_expect(is_equal_approx(player.compute_vertical_velocity(20.0, 0.1, true, false), 0.0), "ground contact clears downward velocity")
	player.free()
	if failed:
		quit(1)
	else:
		print("All player movement checks passed.")
		quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: " + message)
		failed = true
	else:
		print("PASS: " + message)
