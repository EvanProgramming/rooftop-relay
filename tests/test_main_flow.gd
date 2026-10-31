extends SceneTree

var failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	_expect(main.screen_state == "title" and main.overlay.visible, "the game opens on its title screen")

	main._start_run()
	_expect(main.screen_state == "playing" and main.player.controls_enabled, "starting enables player controls")
	for pickup in main.pickups:
		pickup._on_body_entered(main.player)
		await process_frame
	_expect(not main.pickups[0].monitoring, "a collected letter defers collision shutdown safely")
	_expect(main.game_state.letters_collected == 3, "the HUD flow accepts all three letters")
	main._on_mailbox_reached()
	_expect(main.screen_state == "finished" and main.overlay.visible, "the mailbox completes a full delivery")

	main._start_run()
	main.checkpoint_position = Vector2(1012.0, 440.0)
	main._on_hazard_touched()
	_expect(main.game_state.hearts == 2, "a fan hit removes one heart")
	_expect(main.player.global_position == main.checkpoint_position, "a fan hit returns the player to the checkpoint")
	main._on_hazard_touched()
	main._on_hazard_touched()
	_expect(main.screen_state == "game_over" and main.overlay.visible, "losing all hearts opens the retry screen")
	main._on_overlay_button_pressed()
	_expect(main.screen_state == "playing" and main.game_state.hearts == 3, "retry restores the level and all hearts")
	_expect(main.game_state.letters_collected == 0, "retry resets collected letters")

	main.queue_free()
	await process_frame
	if failed:
		quit(1)
	else:
		print("All main game flow checks passed.")
		quit(0)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: " + message)
		failed = true
	else:
		print("PASS: " + message)
