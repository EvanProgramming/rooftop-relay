extends Node2D

const GameStateScript = preload("res://scripts/game_state.gd")
const PlayerScript = preload("res://scripts/player.gd")
const BackgroundScript = preload("res://scripts/background.gd")
const LetterPickupScript = preload("res://scripts/letter_pickup.gd")
const RoofFanScript = preload("res://scripts/roof_fan.gd")
const MailboxScript = preload("res://scripts/mailbox.gd")

const WORLD_WIDTH: float = 2680.0
const START_POSITION: Vector2 = Vector2(92.0, 440.0)
const CHECKPOINT_X: float = 1000.0

var game_state
var player: CharacterBody2D
var pickups: Array[Area2D] = []
var checkpoint_position: Vector2 = START_POSITION
var checkpoint_reached: bool = false
var screen_state: String = "title"
var overlay_action: String = "start"

var hud_letters: Label
var hud_hearts: Label
var overlay: Control
var overlay_title: Label
var overlay_body: Label
var overlay_button: Button
var notice_label: Label
var notice_timer: Timer


func _ready() -> void:
	game_state = GameStateScript.new()
	_build_level()
	_build_player()
	_build_pickups()
	_build_hazards()
	_build_mailbox()
	_build_ui()
	_update_hud()
	_show_overlay(
		"ROOFTOP RELAY",
		"Shenzhen, 23:41. Three letters missed the last delivery. Run, jump, and carry them to the glowing mailbox.",
		"START RUN",
		"start"
	)


func _process(_delta: float) -> void:
	if screen_state != "playing" or checkpoint_reached:
		return
	if player.global_position.x >= CHECKPOINT_X and player.is_on_floor():
		checkpoint_reached = true
		checkpoint_position = Vector2(CHECKPOINT_X + 12.0, 440.0)
		_show_notice("CHECKPOINT REACHED — your letters are safe.")


func _unhandled_input(event: InputEvent) -> void:
	if screen_state in ["finished", "game_over"] and event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_R:
			_start_run()


func _build_level() -> void:
	var background = BackgroundScript.new()
	background.world_width = WORLD_WIDTH
	add_child(background)

	_add_roof(-170.0, 440.0, 580.0, 150.0, Color("27324e"))
	_add_roof(500.0, 385.0, 260.0, 205.0, Color("26304a"))
	_add_roof(830.0, 440.0, 330.0, 150.0, Color("2b344f"))
	_add_roof(1200.0, 350.0, 310.0, 240.0, Color("26304b"))
	_add_roof(1550.0, 405.0, 280.0, 185.0, Color("2c3550"))
	_add_roof(1870.0, 445.0, 760.0, 145.0, Color("27324d"))

	_add_rooftop_detail(Vector2(180.0, 440.0), Color("3b4560"))
	_add_rooftop_detail(Vector2(960.0, 440.0), Color("35415b"))
	_add_rooftop_detail(Vector2(2080.0, 445.0), Color("35415b"))


func _build_player() -> void:
	player = PlayerScript.new()
	player.position = START_POSITION
	var collision := CollisionShape2D.new()
	var body_shape := RectangleShape2D.new()
	body_shape.size = Vector2(22.0, 42.0)
	collision.shape = body_shape
	collision.position = Vector2(0.0, -21.0)
	player.add_child(collision)

	var camera := Camera2D.new()
	camera.position = Vector2(0.0, -110.0)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_right = int(WORLD_WIDTH)
	camera.limit_top = 0
	camera.limit_bottom = 540
	player.add_child(camera)
	add_child(player)


func _build_pickups() -> void:
	_add_pickup(Vector2(280.0, 334.0))
	_add_pickup(Vector2(650.0, 272.0))
	_add_pickup(Vector2(1325.0, 234.0))


func _add_pickup(at: Vector2) -> void:
	var pickup = LetterPickupScript.new()
	pickup.position = at
	pickup.collected.connect(_on_letter_collected)
	var collision := CollisionShape2D.new()
	var sensor := CircleShape2D.new()
	sensor.radius = 23.0
	collision.shape = sensor
	pickup.add_child(collision)
	add_child(pickup)
	pickups.append(pickup)


func _build_hazards() -> void:
	_add_hazard(655.0, 365.0)
	_add_hazard(1665.0, 385.0)


func _add_hazard(x: float, y: float) -> void:
	var fan = RoofFanScript.new()
	fan.position = Vector2(x, y)
	fan.touched.connect(_on_hazard_touched)
	var collision := CollisionShape2D.new()
	var danger_zone := CircleShape2D.new()
	danger_zone.radius = 23.0
	collision.shape = danger_zone
	fan.add_child(collision)
	add_child(fan)


func _build_mailbox() -> void:
	var mailbox = MailboxScript.new()
	mailbox.position = Vector2(2410.0, 400.0)
	mailbox.reached.connect(_on_mailbox_reached)
	var collision := CollisionShape2D.new()
	var sensor := RectangleShape2D.new()
	sensor.size = Vector2(56.0, 72.0)
	collision.shape = sensor
	mailbox.add_child(collision)
	add_child(mailbox)


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var hud := PanelContainer.new()
	hud.position = Vector2(20.0, 18.0)
	hud.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.07, 0.16, 0.88), Color("57c9b3"), 2))
	_set_panel_margins(hud, 12, 12, 7, 7)
	var hud_row := HBoxContainer.new()
	hud_row.add_theme_constant_override("separation", 24)
	hud.add_child(hud_row)
	hud_letters = Label.new()
	hud_letters.add_theme_font_size_override("font_size", 18)
	hud_letters.add_theme_color_override("font_color", Color("fff0b6"))
	hud_row.add_child(hud_letters)
	hud_hearts = Label.new()
	hud_hearts.add_theme_font_size_override("font_size", 18)
	hud_hearts.add_theme_color_override("font_color", Color("ff8295"))
	hud_row.add_child(hud_hearts)
	layer.add_child(hud)

	notice_label = Label.new()
	notice_label.position = Vector2(110.0, 481.0)
	notice_label.size = Vector2(740.0, 38.0)
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notice_label.add_theme_font_size_override("font_size", 18)
	notice_label.add_theme_color_override("font_color", Color("fff0b6"))
	notice_label.visible = false
	layer.add_child(notice_label)
	notice_timer = Timer.new()
	notice_timer.one_shot = true
	notice_timer.wait_time = 1.8
	notice_timer.timeout.connect(_hide_notice)
	add_child(notice_timer)

	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	layer.add_child(overlay)

	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.12, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(550.0, 315.0)
	card.add_theme_stylebox_override("panel", _panel_style(Color("17203d"), Color("ed65ba"), 3))
	_set_panel_margins(card, 28, 28, 24, 24)
	center.add_child(card)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 15)
	card.add_child(content)
	overlay_title = Label.new()
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 31)
	overlay_title.add_theme_color_override("font_color", Color("fff0b6"))
	content.add_child(overlay_title)
	overlay_body = Label.new()
	overlay_body.custom_minimum_size = Vector2(470.0, 92.0)
	overlay_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_body.add_theme_font_size_override("font_size", 17)
	overlay_body.add_theme_color_override("font_color", Color("d9e2ff"))
	content.add_child(overlay_body)
	overlay_button = Button.new()
	overlay_button.custom_minimum_size = Vector2(250.0, 52.0)
	overlay_button.add_theme_font_size_override("font_size", 19)
	overlay_button.add_theme_color_override("font_color", Color("171d39"))
	overlay_button.add_theme_stylebox_override("normal", _panel_style(Color("57d1b6"), Color("9ef1d9"), 2))
	overlay_button.add_theme_stylebox_override("hover", _panel_style(Color("79e2c8"), Color("fff0b6"), 2))
	overlay_button.add_theme_stylebox_override("pressed", _panel_style(Color("35aa9a"), Color("fff0b6"), 2))
	overlay_button.pressed.connect(_on_overlay_button_pressed)
	content.add_child(overlay_button)


func _add_roof(start_x: float, surface_y: float, width: float, depth: float, roof_color: Color) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(start_x + width * 0.5, surface_y + depth * 0.5)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, depth)
	collision.shape = shape
	body.add_child(collision)
	var face := Polygon2D.new()
	face.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -depth * 0.5), Vector2(width * 0.5, -depth * 0.5),
		Vector2(width * 0.5, depth * 0.5), Vector2(-width * 0.5, depth * 0.5)
	])
	face.color = roof_color
	body.add_child(face)
	var neon_edge := Polygon2D.new()
	neon_edge.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -depth * 0.5), Vector2(width * 0.5, -depth * 0.5),
		Vector2(width * 0.5, -depth * 0.5 + 7.0), Vector2(-width * 0.5, -depth * 0.5 + 7.0)
	])
	neon_edge.color = Color("55d4bd")
	body.add_child(neon_edge)
	var coral_trim := Polygon2D.new()
	coral_trim.polygon = PackedVector2Array([
		Vector2(-width * 0.5, -depth * 0.5 + 7.0), Vector2(width * 0.5, -depth * 0.5 + 7.0),
		Vector2(width * 0.5, -depth * 0.5 + 11.0), Vector2(-width * 0.5, -depth * 0.5 + 11.0)
	])
	coral_trim.color = Color("e77773")
	body.add_child(coral_trim)
	add_child(body)


func _add_rooftop_detail(at: Vector2, panel_color: Color) -> void:
	var detail := Node2D.new()
	detail.position = at
	var unit := Polygon2D.new()
	unit.polygon = PackedVector2Array([
		Vector2(-22.0, 0.0), Vector2(22.0, 0.0), Vector2(22.0, -28.0),
		Vector2(12.0, -36.0), Vector2(-18.0, -36.0), Vector2(-22.0, -28.0)
	])
	unit.color = panel_color
	detail.add_child(unit)
	var grille := Polygon2D.new()
	grille.polygon = PackedVector2Array([
		Vector2(-15.0, -23.0), Vector2(15.0, -23.0), Vector2(15.0, -20.0), Vector2(-15.0, -20.0)
	])
	grille.color = Color("74d8d0")
	detail.add_child(grille)
	add_child(detail)


func _panel_style(background: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(9)
	return style


func _set_panel_margins(panel: Control, left: int, right: int, top: int, bottom: int) -> void:
	panel.add_theme_constant_override("margin_left", left)
	panel.add_theme_constant_override("margin_right", right)
	panel.add_theme_constant_override("margin_top", top)
	panel.add_theme_constant_override("margin_bottom", bottom)


func _update_hud() -> void:
	if hud_letters == null or hud_hearts == null:
		return
	hud_letters.text = "LETTERS  %d / 3" % game_state.letters_collected
	hud_hearts.text = "HEARTS  %d / 3" % game_state.hearts


func _show_overlay(title: String, body: String, button_text: String, action: String) -> void:
	if overlay == null:
		return
	overlay_title.text = title
	overlay_body.text = body
	overlay_button.text = button_text
	overlay_action = action
	overlay.visible = true
	player.controls_enabled = false


func _on_overlay_button_pressed() -> void:
	if overlay_action in ["start", "restart"]:
		_start_run()


func _start_run() -> void:
	game_state.reset()
	checkpoint_position = START_POSITION
	checkpoint_reached = false
	player.global_position = START_POSITION
	player.velocity = Vector2.ZERO
	for pickup in pickups:
		if is_instance_valid(pickup):
			pickup.reset_pickup()
	_update_hud()
	overlay.visible = false
	notice_label.visible = false
	notice_timer.stop()
	screen_state = "playing"
	player.controls_enabled = true


func _on_letter_collected() -> void:
	if not game_state.collect_letter():
		return
	_update_hud()
	_show_notice("LETTER SECURED — %d / 3" % game_state.letters_collected)


func _on_hazard_touched() -> void:
	if not game_state.take_hit():
		return
	_update_hud()
	player.velocity = Vector2.ZERO
	if game_state.game_over:
		screen_state = "game_over"
		_show_overlay("ROUTE LOST", "The roof fans used up all your hearts. Your letters are waiting for another run.", "TRY AGAIN", "restart")
		return
	player.global_position = checkpoint_position
	_show_notice("ROOF FAN! Back to the last safe rooftop.")


func _on_mailbox_reached() -> void:
	if game_state.try_finish():
		screen_state = "finished"
		_show_overlay("DELIVERY COMPLETE", "All three letters made it across the Shenzhen skyline.", "RUN IT AGAIN", "restart")
	else:
		_show_notice("THE MAILBOX NEEDS ALL THREE LETTERS.")


func _show_notice(message: String) -> void:
	notice_label.text = message
	notice_label.visible = true
	notice_timer.start()


func _hide_notice() -> void:
	notice_label.visible = false
