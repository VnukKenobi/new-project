class_name Enemy
extends Node2D

signal reached_base
signal died(enemy: Enemy)

var current_cell: Vector2i
var move_speed: float = 120.0
var max_hp: int = 3
var hp: int = 3

var _path: Array[Vector2i] = []
var _path_index: int = 0
var _is_dying: bool = false

func setup(start_cell: Vector2i, world_pos: Vector2) -> void:
	current_cell = start_cell
	global_position = world_pos
	hp = max_hp

func set_path(path: Array[Vector2i], grid_manager: GridManager) -> void:
	_path = path
	_path_index = 1
	if _path.is_empty():
		return
	current_cell = grid_manager.world_to_cell(global_position)

func take_damage(amount: int) -> void:
	if _is_dying:
		return
	hp -= amount
	if hp <= 0:
		play_death()

func play_death() -> void:
	_is_dying = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.12)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.16)
	tween.finished.connect(func() -> void:
		died.emit(self)
		queue_free()
	)

func _process(delta: float) -> void:
	if _is_dying:
		return
	if _path_index >= _path.size():
		reached_base.emit()
		return

	var target_cell: Vector2i = _path[_path_index]
	var target_pos := Vector2(target_cell) * GridManager.CELL_SIZE + Vector2.ONE * (GridManager.CELL_SIZE * 0.5)
	global_position = global_position.move_toward(target_pos, move_speed * delta)
	if global_position.distance_to(target_pos) <= 0.1:
		global_position = target_pos
		current_cell = target_cell
		_path_index += 1

func _draw() -> void:
	draw_ellipse(Vector2(0, 18), Vector2(14, 6), Color(0, 0, 0, 0.2))
	draw_circle(Vector2.ZERO, 12, Color.WHITE)
	draw_rect(Rect2(Vector2(-7, -20), Vector2(14, 20)), Color.WHITE, true)
