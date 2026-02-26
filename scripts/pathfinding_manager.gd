class_name PathfindingManager
extends Node

var grid_manager: GridManager
var astar := AStarGrid2D.new()

func setup(in_grid_manager: GridManager) -> void:
	grid_manager = in_grid_manager
	rebuild()

func rebuild() -> void:
	astar.region = Rect2i(0, 0, grid_manager.GRID_WIDTH, grid_manager.GRID_HEIGHT)
	astar.cell_size = Vector2.ONE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()

	for blocked in grid_manager.blocked_cells.keys():
		astar.set_point_solid(blocked, true)

func has_path(start: Vector2i, goal: Vector2i) -> bool:
	rebuild()
	if astar.is_point_solid(start) or astar.is_point_solid(goal):
		return false
	return not astar.get_id_path(start, goal).is_empty()

func get_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	rebuild()
	return astar.get_id_path(start, goal)
