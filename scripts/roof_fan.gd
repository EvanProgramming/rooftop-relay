extends Area2D

signal touched

var _blade_angle: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_blade_angle += delta * 4.5
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2(0.0, 0.0), 27.0, Color(0.95, 0.43, 0.39, 0.16))
	draw_rect(Rect2(-27.0, -9.0, 54.0, 25.0), Color("222b47"))
	draw_rect(Rect2(-27.0, -9.0, 54.0, 4.0), Color("ff806e"))
	draw_rect(Rect2(-21.0, 12.0, 42.0, 6.0), Color("10182e"))
	draw_circle(Vector2(0.0, -8.0), 15.0, Color("40c8b2"))
	for blade in range(3):
		var angle: float = _blade_angle + float(blade) * TAU / 3.0
		var tip: Vector2 = Vector2(cos(angle), sin(angle)) * 13.0
		draw_line(Vector2.ZERO + Vector2(0.0, -8.0), tip + Vector2(0.0, -8.0), Color("fff0b6"), 4.0)
	draw_circle(Vector2(0.0, -8.0), 3.0, Color("dc4caa"))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		touched.emit()
