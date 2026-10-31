extends Area2D

signal reached


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _draw() -> void:
	draw_rect(Rect2(-19.0, 19.0, 38.0, 24.0), Color("f2bd61"))
	draw_rect(Rect2(-24.0, -25.0, 48.0, 47.0), Color("e44f68"))
	draw_rect(Rect2(-18.0, -18.0, 36.0, 30.0), Color("ff796e"))
	draw_rect(Rect2(-15.0, -12.0, 30.0, 5.0), Color("352749"))
	draw_line(Vector2(-14.0, -3.0), Vector2(0.0, 8.0), Color("fff0b6"), 3.0)
	draw_line(Vector2(14.0, -3.0), Vector2(0.0, 8.0), Color("fff0b6"), 3.0)
	draw_rect(Rect2(16.0, -34.0, 4.0, 13.0), Color("f2bd61"))
	draw_rect(Rect2(20.0, -34.0, 12.0, 7.0), Color("fff0b6"))
	draw_circle(Vector2(0.0, -37.0), 33.0, Color(1.0, 0.69, 0.34, 0.12))


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		reached.emit()
