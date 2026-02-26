class_name GameManager
extends Node2D

@onready var grid_manager: GridManager = $GridManager
@onready var pathfinding_manager: PathfindingManager = $PathfindingManager
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer

var base: Base
var enemies: Array[Enemy] = []
var towers: Array[Tower] = []
var is_game_over: bool = false

func _ready() -> void:
	pathfinding_manager.setup(grid_manager)
	_setup_camera()
	_spawn_base()
	enemy_spawn_timer.timeout.connect(_spawn_enemy)
	enemy_spawn_timer.start()

func _setup_camera() -> void:
	var camera := $Camera2D as Camera2D
	camera.position = Vector2(
		grid_manager.GRID_WIDTH * grid_manager.CELL_SIZE * 0.5,
		grid_manager.GRID_HEIGHT * grid_manager.CELL_SIZE * 0.5
	)

func _spawn_base() -> void:
	base = Base.new()
	add_child(base)
	base.setup(grid_manager.cell_to_center(grid_manager.base_cell))

func _spawn_enemy() -> void:
	if is_game_over:
		return
	var enemy := Enemy.new()
	add_child(enemy)
	enemy.setup(grid_manager.spawn_cell, grid_manager.cell_to_center(grid_manager.spawn_cell))
	enemy.reached_base.connect(_on_enemy_reached_base.bind(enemy))
	enemy.died.connect(_on_enemy_died)
	enemies.append(enemy)
	_repath_enemy(enemy)

func _input(event: InputEvent) -> void:
	if is_game_over:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var cell := grid_manager.world_to_cell(event.position)
		try_build_tower(cell)

func try_build_tower(cell: Vector2i) -> void:
	if not grid_manager.is_cell_buildable(cell):
		return

	grid_manager.set_blocked(cell, true)
	var path_exists := pathfinding_manager.has_path(grid_manager.spawn_cell, grid_manager.base_cell)
	if not path_exists:
		grid_manager.set_blocked(cell, false)
		return

	var tower := Tower.new()
	add_child(tower)
	tower.setup(cell, grid_manager, func() -> Array[Enemy]: return enemies)
	towers.append(tower)
	_repath_all_enemies()

func _repath_all_enemies() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			_repath_enemy(enemy)

func _repath_enemy(enemy: Enemy) -> void:
	var start := grid_manager.world_to_cell(enemy.global_position)
	var new_path := pathfinding_manager.find_path(start, grid_manager.base_cell)
	enemy.set_path(new_path, grid_manager)

func _on_enemy_died(enemy: Enemy) -> void:
	enemies.erase(enemy)

func _on_enemy_reached_base(enemy: Enemy) -> void:
	if is_game_over:
		return
	if is_instance_valid(enemy):
		enemy.queue_free()
	enemies.erase(enemy)
	base.hit()
	if base.hp <= 0:
		trigger_game_over()

func trigger_game_over() -> void:
	is_game_over = true
	enemy_spawn_timer.stop()
	get_tree().paused = true
	print("Game Over")
