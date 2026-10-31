extends CharacterBody2D

const MOVE_SPEED: float = 280.0
const ACCELERATION: float = 1200.0
const JUMP_VELOCITY: float = -560.0
const GRAVITY: float = 1450.0

var controls_enabled: bool = false
var _w_key_was_down: bool = false
var _facing: float = 1.0
var _walk_phase: float = 0.0


func _ready() -> void:
	add_to_group("player")
	queue_redraw()


func compute_horizontal_velocity(current: float, axis: float, delta: float) -> float:
	var target: float = clampf(axis, -1.0, 1.0) * MOVE_SPEED
	var acceleration: float = ACCELERATION if not is_zero_approx(axis) else ACCELERATION * 1.3
	return move_toward(current, target, acceleration * delta)


func compute_vertical_velocity(current: float, delta: float, grounded: bool, jump_pressed: bool) -> float:
	if grounded:
		if jump_pressed:
			return JUMP_VELOCITY
		return minf(current, 0.0)
	return current + GRAVITY * delta


func _physics_process(delta: float) -> void:
	var axis: float = _read_horizontal_axis() if controls_enabled else 0.0
	var w_down: bool = Input.is_physical_key_pressed(KEY_W)
	var jump_pressed: bool = controls_enabled and (
		Input.is_action_just_pressed("ui_accept")
		or Input.is_action_just_pressed("ui_up")
		or (w_down and not _w_key_was_down)
	)
	_w_key_was_down = w_down

	velocity.x = compute_horizontal_velocity(velocity.x, axis, delta)
	velocity.y = compute_vertical_velocity(velocity.y, delta, is_on_floor(), jump_pressed)
	move_and_slide()

	if not is_zero_approx(axis):
		_facing = signf(axis)
	_walk_phase += absf(velocity.x) * delta / MOVE_SPEED
	queue_redraw()


func _read_horizontal_axis() -> float:
	var arrow_axis: float = Input.get_axis("ui_left", "ui_right")
	var left_down: bool = Input.is_physical_key_pressed(KEY_A)
	var right_down: bool = Input.is_physical_key_pressed(KEY_D)
	if left_down != right_down:
		return -1.0 if left_down else 1.0
	return arrow_axis


func _draw() -> void:
	var step: float = sin(_walk_phase * TAU) * 2.0 if absf(velocity.x) > 8.0 else 0.0
	draw_ellipse(Vector2(0, 2), 16.0, 4.0, Color(0.04, 0.06, 0.15, 0.45))
	# Shoes and legs.
	draw_rect(Rect2(-9.0, -13.0, 8.0, 12.0 + step), Color("202643"))
	draw_rect(Rect2(1.0, -13.0, 8.0, 12.0 - step), Color("202643"))
	draw_rect(Rect2(-11.0, -3.0 + step, 11.0, 4.0), Color("ff826e"))
	draw_rect(Rect2(0.0, -3.0 - step, 11.0, 4.0), Color("ff826e"))
	# Teal jacket and bright messenger bag.
	var bag_x: float = -17.0 if _facing > 0.0 else 8.0
	draw_rect(Rect2(bag_x, -31.0, 12.0, 18.0), Color("dc4caa"))
	draw_rect(Rect2(bag_x + 2.0, -28.0, 8.0, 2.0), Color("ffe18c"))
	draw_rect(Rect2(-12.0, -35.0, 24.0, 22.0), Color("40c8b2"))
	draw_rect(Rect2(-12.0, -16.0, 24.0, 3.0), Color("f7c45c"))
	# Face, hair, and a tiny reflective visor.
	draw_rect(Rect2(-9.0, -51.0, 18.0, 18.0), Color("ffd0a5"))
	var hair_x: float = -10.0 if _facing > 0.0 else -7.0
	draw_rect(Rect2(hair_x, -55.0, 18.0, 9.0), Color("25223f"))
	draw_rect(Rect2(1.0 * _facing, -45.0, 3.0, 3.0), Color("25223f"))
	draw_rect(Rect2(-12.0, -39.0, 24.0, 3.0), Color("e9f3f2"))
