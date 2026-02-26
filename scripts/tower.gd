class_name Tower
extends Node2D

var range_cells: int = 3
var damage: int = 1
var fire_cooldown: float = 1.0

var grid_manager: GridManager
var enemies_provider: Callable
var _cooldown_left: float = 0.0

func setup(cell: Vector2i, in_grid: GridManager, in_enemies_provider: Callable) -> void:
	grid_manager = in_grid
	enemies_provider = in_enemies_provider
	global_position = grid_manager.cell_to_center(cell)

func _process(delta: float) -> void:
	_cooldown_left = max(0.0, _cooldown_left - delta)
	if _cooldown_left > 0.0:
		return

	var enemies: Array = enemies_provider.call()
	var best_enemy: Enemy = null
	var best_dist := INF
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist_cells := global_position.distance_to(enemy.global_position) / float(GridManager.CELL_SIZE)
		if dist_cells <= range_cells and dist_cells < best_dist:
			best_dist = dist_cells
			best_enemy = enemy

	if best_enemy != null:
		fire(best_enemy)
		_cooldown_left = fire_cooldown

func fire(enemy: Enemy) -> void:
	enemy.take_damage(damage)
	var bullet := Line2D.new()
	bullet.default_color = Color(1.0, 0.9, 0.1, 0.9)
	bullet.width = 3.0
	bullet.add_point(Vector2.ZERO)
	bullet.add_point(to_local(enemy.global_position))
	add_child(bullet)
	var tween := create_tween()
	tween.tween_interval(0.05)
	tween.finished.connect(func() -> void:
		bullet.queue_free()
	)

func _draw() -> void:
	draw_ellipse(Vector2(0, 18), Vector2(16, 6), Color(0, 0, 0, 0.2))
	draw_rect(Rect2(Vector2(-14, -8), Vector2(28, 16)), Color(1.0, 0.9, 0.1), true)
	draw_rect(Rect2(Vector2(8, -3), Vector2(18, 6)), Color(1.0, 0.9, 0.1), true)
