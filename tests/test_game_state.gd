extends SceneTree

var failed: bool = false


func _initialize() -> void:
	var state_script = load("res://scripts/game_state.gd")
	_expect(state_script != null and state_script.can_instantiate(), "the game state script loads and parses")
	if state_script == null or not state_script.can_instantiate():
		quit(1)
		return
	_test_start_state()
	_test_mailbox_requires_every_letter()
	_test_hazards_and_restart()
	if failed:
		quit(1)
	else:
		print("All game state checks passed.")
		quit(0)


func _test_start_state() -> void:
	var state = load("res://scripts/game_state.gd").new()
	_expect(state.letters_collected == 0, "the level starts with no letters")
	_expect(state.hearts == 3, "the player starts with three hearts")
	_expect(not state.finished and not state.game_over, "the level starts active")


func _test_mailbox_requires_every_letter() -> void:
	var state = load("res://scripts/game_state.gd").new()
	_expect(not state.try_finish(), "the mailbox stays locked before all letters")
	_expect(state.collect_letter(), "a letter can be collected")
	_expect(state.collect_letter(), "a second letter can be collected")
	_expect(state.collect_letter(), "the final letter can be collected")
	_expect(not state.collect_letter(), "the letter count cannot exceed three")
	_expect(state.try_finish(), "the mailbox accepts all three letters")
	_expect(state.finished, "finishing updates the game state")
	_expect(not state.take_hit(), "finished levels do not accept hazard hits")


func _test_hazards_and_restart() -> void:
	var state = load("res://scripts/game_state.gd").new()
	state.collect_letter()
	_expect(state.take_hit(), "a hazard consumes a heart")
	_expect(state.hearts == 2, "the heart count decreases once per hit")
	_expect(state.letters_collected == 1, "a hit does not erase collected letters")
	state.take_hit()
	state.take_hit()
	_expect(state.hearts == 0 and state.game_over, "the last hit ends the attempt")
	_expect(not state.take_hit(), "game over ignores further hazard hits")
	state.reset()
	_expect(state.hearts == 3 and state.letters_collected == 0, "restart restores the level")
	_expect(not state.game_over and not state.finished, "restart returns to active play")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: " + message)
		failed = true
	else:
		print("PASS: " + message)
