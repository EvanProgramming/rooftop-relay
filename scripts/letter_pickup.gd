extends Area2D

signal collected

var _base_position: Vector2
var _phase: float = 0.0
var _is_collected: bool = false


func _ready() -> void:
	_base_position = position
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _is_collected:
		return
	_phase += delta
	position.y = _base_position.y + sin(_phase * 3.0) * 5.0
	rotation = sin(_phase * 1.8) * 0.08


func reset_pickup() -> void:
	_is_collected = false
	visible = true
	monitoring = true
	position = _base_position
	rotation = 0.0
	_phase = 0.0


func _draw() -> void:
	draw_rect(Rect2(-15.0, -10.0, 30.0, 20.0), Color("fff0b6"))
	draw_rect(Rect2(-15.0, -10.0, 30.0, 3.0), Color("f3bc63"))
	draw_line(Vector2(-14.0, -8.0), Vector2(0.0, 1.0), Color("e87867"), 2.0)
	draw_line(Vector2(14.0, -8.0), Vector2(0.0, 1.0), Color("e87867"), 2.0)
	draw_line(Vector2(-14.0, 8.0), Vector2(0.0, -1.0), Color("e87867"), 2.0)
	draw_line(Vector2(14.0, 8.0), Vector2(0.0, -1.0), Color("e87867"), 2.0)
	draw_circle(Vector2(0.0, -17.0), 3.0, Color("fff0b6"))


func _on_body_entered(body: Node2D) -> void:
	if _is_collected or not body.is_in_group("player"):
		return
	_is_collected = true
	set_deferred("monitoring", false)
	visible = false
	collected.emit()
