class_name Base
extends Node2D

var hp: int = 1

func setup(world_pos: Vector2) -> void:
	global_position = world_pos

func hit() -> void:
	hp -= 1

func _draw() -> void:
	draw_ellipse(Vector2(0, 18), 18.0, 7.0, Color(0, 0, 0, 0.2))
	draw_rect(Rect2(Vector2(-20, -14), Vector2(40, 28)), Color.WHITE, true)
	draw_rect(Rect2(Vector2(-10, -24), Vector2(20, 10)), Color.WHITE, true)
