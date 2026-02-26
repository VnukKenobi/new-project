class_name GridManager
extends Node2D

const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 10
const CELL_SIZE: int = 80

const EMPTY_COLOR := Color(0.12, 0.12, 0.12, 1.0)
const LINE_COLOR := Color(0.3, 0.3, 0.3, 1.0)
const BLOCK_COLOR := Color(0.25, 0.17, 0.05, 0.9)

var blocked_cells: Dictionary = {}

@onready var spawn_cell: Vector2i = Vector2i(GRID_WIDTH / 2, 0)
@onready var base_cell: Vector2i = Vector2i(GRID_WIDTH / 2, GRID_HEIGHT - 1)

func _draw() -> void:
	var board_size := Vector2(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
	draw_rect(Rect2(Vector2.ZERO, board_size), EMPTY_COLOR, true)

	for cell in blocked_cells.keys():
		var rect := Rect2(cell_to_world(cell), Vector2.ONE * CELL_SIZE)
		draw_rect(rect, BLOCK_COLOR, true)

	for x in range(GRID_WIDTH + 1):
		var x_pos := float(x * CELL_SIZE)
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, board_size.y), LINE_COLOR, 1.0)

	for y in range(GRID_HEIGHT + 1):
		var y_pos := float(y * CELL_SIZE)
		draw_line(Vector2(0, y_pos), Vector2(board_size.x, y_pos), LINE_COLOR, 1.0)

func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_WIDTH and cell.y < GRID_HEIGHT

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / CELL_SIZE), int(world_pos.y / CELL_SIZE))

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

func cell_to_center(cell: Vector2i) -> Vector2:
	return cell_to_world(cell) + Vector2.ONE * (CELL_SIZE * 0.5)

func is_cell_blocked(cell: Vector2i) -> bool:
	return blocked_cells.has(cell)

func set_blocked(cell: Vector2i, value: bool) -> void:
	if value:
		blocked_cells[cell] = true
	else:
		blocked_cells.erase(cell)
	queue_redraw()

func is_cell_buildable(cell: Vector2i) -> bool:
	if not is_inside(cell):
		return false
	if cell == spawn_cell or cell == base_cell:
		return false
	return not is_cell_blocked(cell)
