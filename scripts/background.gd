extends Node2D

var world_width: float = 2700.0


func _draw() -> void:
	# A stepped dusk-to-night sky keeps the look crisp at the game's 960 x 540 canvas.
	for band in range(20):
		var blend: float = float(band) / 19.0
		var sky_color: Color = Color("111433").lerp(Color("493267"), blend)
		draw_rect(Rect2(0.0, float(band) * 27.0, world_width, 28.0), sky_color)

	# Stars and moon.
	for index in range(58):
		var star_x: float = fposmod(float(index * 197 + 43), world_width)
		var star_y: float = float((index * 71 + 29) % 180)
		var size: float = 2.0 if index % 5 == 0 else 1.0
		draw_rect(Rect2(star_x, star_y, size, size), Color("d9dcff"))
	draw_circle(Vector2(330.0, 118.0), 34.0, Color("ffe1a0"))
	draw_circle(Vector2(342.0, 108.0), 34.0, Color("493267"))

	# Distant hills soften the skyline's lower edge.
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0.0, 390.0), Vector2(220.0, 300.0), Vector2(430.0, 390.0),
			Vector2(690.0, 282.0), Vector2(940.0, 390.0), Vector2(1230.0, 295.0),
			Vector2(1510.0, 390.0), Vector2(1780.0, 300.0), Vector2(2080.0, 390.0),
			Vector2(2350.0, 285.0), Vector2(world_width, 390.0),
			Vector2(world_width, 540.0), Vector2(0.0, 540.0)
		]),
		Color("22284c")
	)

	# Dense high-rise silhouettes with warm lit windows.
	for index in range(45):
		var x: float = float(index * 64 - 20)
		var width: float = float(42 + (index * 19) % 24)
		var height: float = float(115 + (index * 53) % 185)
		var top: float = 355.0 - height
		var building_color: Color = Color("171f3d").lerp(Color("29264d"), float(index % 4) * 0.12)
		draw_rect(Rect2(x, top, width, height + 185.0), building_color)
		draw_rect(Rect2(x, top, width, 4.0), Color("4a456f"))
		for row in range(5):
			for column in range(3):
				if (index + row * 3 + column * 5) % 4 == 0:
					continue
				var window_x: float = x + 7.0 + float(column) * 12.0
				var window_y: float = top + 16.0 + float(row) * 24.0
				var window_color: Color = Color("ffd46e") if (index + row) % 3 == 0 else Color("66d7d1")
				draw_rect(Rect2(window_x, window_y, 5.0, 8.0), window_color)

	# A few recognizable stepped towers give the city a Shenzhen skyline rhythm.
	_draw_tower(Vector2(780.0, 150.0), 62.0, 215.0, Color("1d2850"), Color("49c6d1"))
	_draw_tower(Vector2(1510.0, 92.0), 84.0, 275.0, Color("202850"), Color("ff8b73"))
	_draw_tower(Vector2(2190.0, 175.0), 70.0, 195.0, Color("222b53"), Color("dc62bb"))


func _draw_tower(origin: Vector2, width: float, height: float, body_color: Color, accent_color: Color) -> void:
	var points := PackedVector2Array([
		origin + Vector2(width * 0.5, 0.0),
		origin + Vector2(width, 30.0),
		origin + Vector2(width, height),
		origin + Vector2(0.0, height),
		origin + Vector2(0.0, 30.0)
	])
	draw_colored_polygon(points, body_color)
	draw_line(origin + Vector2(width * 0.5, 0.0), origin + Vector2(width * 0.5, height), accent_color, 3.0)
	for row in range(7):
		draw_rect(Rect2(origin.x + 12.0, origin.y + 46.0 + float(row) * 27.0, width - 24.0, 4.0), accent_color)
